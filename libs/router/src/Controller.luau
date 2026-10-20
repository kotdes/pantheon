--!strict

local Types = require(script.Parent.Types)

export type Deps = {
	innerScope: (scope: any) -> any,
	cleanup: (scope: any) -> (),
	provide: (router: Types.Router, render: () -> Instance?) -> Instance?,
	spawn: (task: (...any) -> (), ...any) -> (),
	warn: (message: string) -> (),
	createView: (scope: any, props: Types.RouteViewProps) -> Instance,
}

export type Controller = {
	Show: (route: Types.Route) -> (),
	Destroy: () -> (),
}

type View = {
	Key: string,
	Scope: any,
	Instance: Instance?,
	RouteState: any,
	Pending: { Scope: any, Instance: Instance? }?,
	Dead: boolean,
}

local Controller = {}

local NO_ROUTE = "!"

local function paramsKey(params: Types.Params): string
	local keys = {}
	for key in params do
		table.insert(keys, key)
	end
	table.sort(keys)
	local parts = {}
	for _, key in keys do
		table.insert(parts, `{key}={params[key]}`)
	end
	return table.concat(parts, "&")
end

local function keyFor(record: Types.RouteRecord?, route: Types.Route): string
	if record == nil then
		return NO_ROUTE
	end
	local base = tostring(record)
	if record.Key ~= nil then
		return `{base}#{tostring(record.Key(route))}`
	elseif record.Load ~= nil then
		return `{base}?{paramsKey(route.Params)}`
	end
	return base
end

function Controller.new(
	scope: any,
	props: Types.RouteViewProps,
	container: any,
	deps: Deps
): Controller
	local router = props.Router
	local depth = props.Depth or 0

	local shown: View? = nil
	local lastRoute: Types.Route? = nil
	local leaving: { () -> () } = {}

	local function flush()
		local list = leaving
		leaving = {}
		for _, finish in list do
			finish()
		end
	end

	local function removePending(view: View)
		local pending = view.Pending
		if pending then
			view.Pending = nil
			deps.cleanup(pending.Scope)
			if pending.Instance then
				pending.Instance:Destroy()
			end
		end
	end

	local function removeView(view: View)
		view.Dead = true
		removePending(view)
		deps.cleanup(view.Scope)
		if view.Instance then
			view.Instance:Destroy()
		end
	end

	local function mountInto(label: string, render: () -> Instance?): Instance?
		local ok, result = xpcall(function()
			return deps.provide(router, render)
		end, debug.traceback)
		if not ok then
			deps.warn(`Pantheon Router: {label} failed.\n{result}`)
			return nil
		end
		local made = result :: Instance?
		if made then
			made.Parent = container
		end
		return made
	end

	local function makeContext(inner: any, routeState: any, route: Types.Route): Types.RouteContext
		local paramStates: { [string]: any } = {}
		return {
			Router = router,
			Initial = route,
			Route = routeState,
			Params = inner:Computed(function(use: any)
				return use(routeState).Params
			end),
			Query = inner:Computed(function(use: any)
				return use(routeState).Query
			end),
			Param = function(name: string)
				local state = paramStates[name]
				if state == nil then
					state = inner:Computed(function(use: any)
						return use(routeState).Params[name]
					end)
					paramStates[name] = state
				end
				return state
			end,
			Data = nil,
			Outlet = function(outletProps: Types.OutletProps?)
				local own = outletProps or {}
				return deps.createView(inner, {
					Router = router,
					Depth = depth + 1,
					Transition = props.Transition,
					Pending = props.Pending,
					Error = props.Error,
					Size = own.Size,
					Position = own.Position,
					LayoutOrder = own.LayoutOrder,
					ZIndex = own.ZIndex,
					ClipsDescendants = own.ClipsDescendants,
				})
			end,
		}
	end

	local function show(route: Types.Route)
		local record = route.Matched[depth + 1]
		local key = keyFor(record, route)
		local current = shown
		if current and current.Key == key then
			current.RouteState:set(route)
			lastRoute = route
			return
		end
		flush()

		local previous = current
		local from = lastRoute
		lastRoute = route

		local inner = deps.innerScope(scope)
		local routeState = inner:Value(route)
		local view: View = {
			Key = key,
			Scope = inner,
			Instance = nil,
			RouteState = routeState,
			Pending = nil,
			Dead = false,
		}
		shown = view
		local context = makeContext(inner, routeState, route)

		local render = if record
			then record.Render
			elseif depth == 0 and #route.Matched == 0 then props.NotFound
			else nil

		local retired = false
		local function retirePrevious(entering: Instance?)
			if retired or previous == nil then
				return
			end
			retired = true
			local old = previous
			local done = false
			local function finish()
				if not done then
					done = true
					removeView(old)
				end
			end
			if props.Transition and entering and old.Instance then
				table.insert(leaving, finish)
				props.Transition({
					Entering = entering,
					Leaving = old.Instance,
					Direction = route.Direction,
					From = from,
					To = route,
					Finish = finish,
				})
			else
				finish()
			end
		end

		local function build(): Instance?
			if render == nil then
				return nil
			end
			return mountInto("a route", function()
				return render(inner, context)
			end)
		end

		if record and record.Load then
			local load = record.Load
			local pendingRender = record.Pending or props.Pending
			local entering: Instance? = nil
			if pendingRender then
				local pendingScope = deps.innerScope(scope)
				entering = mountInto("a pending view", function()
					return pendingRender(pendingScope, context)
				end)
				view.Pending = { Scope = pendingScope, Instance = entering }
				retirePrevious(entering)
			elseif previous then
				table.insert(leaving, function()
					retirePrevious(nil)
				end)
			end

			deps.spawn(function()
				local ok, result = pcall(load, context)
				if view.Dead then
					return
				end
				removePending(view)
				if ok then
					context.Data = result
					view.Instance = build()
				else
					local errorRender = record.Error or props.Error
					if errorRender then
						view.Instance = mountInto("an error view", function()
							return errorRender(inner, context, result)
						end)
					else
						deps.warn(`Pantheon Router: loading a route failed.\n{result}`)
					end
				end
				retirePrevious(view.Instance)
			end)
			return
		end

		view.Instance = build()
		retirePrevious(view.Instance)
	end

	local function destroy()
		flush()
		local current = shown
		shown = nil
		if current then
			removeView(current)
		end
	end

	return { Show = show, Destroy = destroy }
end

return Controller
