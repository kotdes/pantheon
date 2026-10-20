--!nocheck
local Router = require(script.Parent.Parent.src.Router)
local Controller = require(script.Parent.Parent.src.Controller)

local Helpers = {}

function Helpers.stubScope()
	local scope = {}
	function scope:Value(initial: any)
		local state = { value = initial }
		function state:set(value: any)
			self.value = value
		end
		return state
	end
	function scope:Computed(compute: (any) -> any)
		return { compute = compute }
	end
	return scope
end

function Helpers.use(state: any): any
	return state.value
end

function Helpers.read(computed: any): any
	return computed.compute(Helpers.use)
end

function Helpers.instance(name: string)
	return {
		Name = name,
		Parent = nil,
		Destroyed = false,
		Destroy = function(self: any)
			self.Destroyed = true
		end,
	}
end

function Helpers.makeRouter(extra: any?)
	local log = {}
	local options = {
		Routes = {
			{ Name = "root", Path = "/", Redirect = "/today" },
			{ Name = "today", Path = "/today" },
			{ Name = "project", Path = "/project/:id" },
			{ Name = "newProject", Path = "/project/new" },
			{
				Name = "settings",
				Path = "/settings",
				Redirect = "/settings/appearance",
				Children = {
					{ Name = "appearance", Path = "appearance" },
					{ Name = "sort", Path = "sort" },
				},
			},
			{ Name = "files", Path = "/files/*" },
		},
		Initial = "/today",
		OnChanged = function(to: any, from: any)
			table.insert(log, `{from and from.Url or "-"} -> {to.Url}`)
		end,
	}
	for key, value in extra or {} do
		options[key] = value
	end
	return Router.new(Helpers.stubScope(), options), log
end

function Helpers.harness(routes: any, viewProps: any?, initial: string?)
	local scope = Helpers.stubScope()
	local options = if routes.Routes ~= nil
		then routes
		else { Routes = routes, Initial = initial or "/" }
	local router = Router.new(scope, options)
	local state = {
		router = router,
		cleaned = {},
		warnings = {},
		threads = {},
		provided = 0,
		nested = {},
		transitions = {},
	}
	state.container = { Name = "container" }

	local deps
	deps = {
		innerScope = function()
			return Helpers.stubScope()
		end,
		cleanup = function(inner: any)
			table.insert(state.cleaned, inner)
		end,
		provide = function(_, render: () -> any)
			state.provided += 1
			return render()
		end,
		spawn = function(fn: any, ...: any)
			local thread = coroutine.create(fn)
			table.insert(state.threads, thread)
			local ok, err = coroutine.resume(thread, ...)
			if not ok then
				error(err)
			end
		end,
		warn = function(message: string)
			table.insert(state.warnings, message)
		end,
		createView = function(scope2: any, p: any)
			local container = { Name = "nested container" }
			local controller = Controller.new(scope2, p, container, deps)
			controller.Show(router.Route.value)
			table.insert(state.nested, controller)
			return container
		end,
	}
	local props = { Router = router }
	for key, value in viewProps or {} do
		props[key] = value
	end
	state.controller = Controller.new(scope, props, state.container, deps)
	function state.show()
		state.controller.Show(router.Route.value)
	end
	return state
end

return Helpers
