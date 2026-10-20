--!strict

local Path = require(script.Parent.Path)
local History = require(script.Parent.History)
local Define = require(script.Parent.Define)
local Types = require(script.Parent.Types)

type Route = Types.Route
type RouteRecord = Types.RouteRecord
type Target = Types.Target
type Params = Types.Params

type Entry = {
	Pattern: Path.Pattern,
	Chain: { RouteRecord },
}

type Location = {
	Path: string,
	Query: Params,
	Entry: Entry,
	Params: Params,
}

type Outcome = "allow" | "cancel" | "redirect"

local MAX_REDIRECTS = 10
local REDIRECT_LOOP = "too many redirects. Is there a loop?"

local Router = {}
Router.__index = Router

type RouterImpl = typeof(setmetatable(
	{} :: {
		Route: any,
		CanGoBack: any,
		CanGoForward: any,
		_scope: any,
		_entries: { Entry },
		_names: { [string]: Entry },
		_history: History.History,
		_route: Route,
		_ticket: number,
		_beforeEach: Types.Guard?,
		_onChanged: ((to: Route, from: Route?) -> ())?,
	},
	Router
))

local function complain(message: string)
	warn("Pantheon Router: " .. message)
end

local function fail(message: string): never
	error("Pantheon Router: " .. message, 0)
end

local function collect(
	records: { RouteRecord },
	prefix: string?,
	parents: { RouteRecord },
	entries: { Entry },
	names: { [string]: Entry }
)
	for _, record in records do
		local recordPath = record.Path :: string
		local full = if prefix then Path.join(prefix, recordPath) else Path.normalise(recordPath)
		local chain = table.clone(parents)
		table.insert(chain, record)
		local entry: Entry = { Pattern = Path.compile(full), Chain = chain }
		table.insert(entries, entry)
		if record.Name ~= nil then
			if names[record.Name] ~= nil then
				fail(`the route name "{record.Name}" is used twice`)
			end
			names[record.Name] = entry
		end
		if record.Children then
			collect(record.Children :: { RouteRecord }, full, chain, entries, names)
		end
	end
end

local function bestMatch(self: RouterImpl, path: string): (Entry?, Params?)
	local best: Entry? = nil
	local bestParams: Params? = nil
	for _, entry in self._entries do
		if best == nil or entry.Pattern.Score > best.Pattern.Score then
			local params = Path.match(entry.Pattern, path)
			if params ~= nil then
				best, bestParams = entry, params
			end
		end
	end
	return best, bestParams
end

local function locate(self: RouterImpl, target: Target, inherit: Params?): Location?
	local spec: Types.TargetTable
	if typeof(target) == "string" then
		spec = if string.sub(target, 1, 1) == "/" then { Path = target } else { Name = target }
	else
		spec = target
	end

	local path: string
	local query: Params
	if spec.Name ~= nil then
		local named = self._names[spec.Name]
		if named == nil then
			complain(`there is no route named "{spec.Name}"`)
			return nil
		end
		local built, message = Path.build(named.Pattern, spec.Params or inherit)
		if built == nil then
			complain(message :: string)
			return nil
		end
		path, query = built, {}
	elseif spec.Path ~= nil then
		path, query = Path.parse(spec.Path)
	else
		complain("a target needs a Name or a Path")
		return nil
	end
	local extra: Params = spec.Query or {}
	for key, value in extra do
		query[key] = value
	end

	local entry, params = bestMatch(self, path)
	if entry == nil or params == nil then
		return nil
	end
	return { Path = path, Query = query, Entry = entry, Params = params }
end

local function resolve(
	self: RouterImpl,
	target: Target,
	inherit: Params?,
	redirects: number
): Route?
	if redirects > MAX_REDIRECTS then
		complain(REDIRECT_LOOP)
		return nil
	end

	local location = locate(self, target, inherit)
	if location == nil then
		return nil
	end
	local chain = location.Entry.Chain
	local leaf = chain[#chain]
	if leaf.Redirect ~= nil then
		return resolve(self, leaf.Redirect, location.Params, redirects + 1)
	end
	return {
		Path = location.Path,
		Url = Path.format(location.Path, location.Query),
		Name = leaf.Name,
		Params = location.Params,
		Query = location.Query,
		Matched = chain,
		Direction = "Initial",
	}
end

local function guardsFor(self: RouterImpl, to: Route, from: Route): { Types.Guard }
	local guards: { Types.Guard } = {}
	for index = #from.Matched, 1, -1 do
		local record = from.Matched[index]
		if record.BeforeLeave and not table.find(to.Matched, record) then
			table.insert(guards, record.BeforeLeave)
		end
	end
	if self._beforeEach then
		table.insert(guards, self._beforeEach)
	end
	for _, record in to.Matched do
		if record.BeforeEnter and not table.find(from.Matched, record) then
			table.insert(guards, record.BeforeEnter)
		end
	end
	return guards
end

local function check(self: RouterImpl, to: Route): (Outcome, Target?)
	self._ticket += 1
	local ticket = self._ticket
	local from = self._route
	for _, guard in guardsFor(self, to, from) do
		local result = guard(to, from)
		if self._ticket ~= ticket then
			return "cancel", nil
		end
		if result == false then
			return "cancel", nil
		end
		if result ~= nil and result ~= true then
			return "redirect", result
		end
	end
	return "allow", nil
end

local function commit(self: RouterImpl, to: Route, direction: Types.Direction)
	local from = self._route
	to.Direction = direction
	self._route = to
	self.Route:set(to)
	self.CanGoBack:set(self._history:CanGo(-1))
	self.CanGoForward:set(self._history:CanGo(1))
	if self._onChanged then
		self._onChanged(to, from)
	end
end

local function navigate(
	self: RouterImpl,
	target: Target,
	mode: "Push" | "Replace",
	redirects: number
): boolean
	if redirects > MAX_REDIRECTS then
		complain(REDIRECT_LOOP)
		return false
	end
	local to = resolve(self, target, nil, 0)
	if to == nil then
		complain(`nothing matches {if typeof(target) == "string" then target else "the target"}`)
		return false
	end

	local outcome, redirect = check(self, to)
	if outcome == "cancel" then
		return false
	elseif outcome == "redirect" then
		return navigate(self, redirect :: Target, mode, redirects + 1)
	end

	if mode == "Push" and to.Url == self._route.Url then
		return false
	end
	if mode == "Push" then
		self._history:Push(to.Url)
	else
		self._history:Replace(to.Url)
	end
	commit(self, to, if mode == "Push" then "Forward" else "Replace")
	return true
end

function Router.new(scope: any, input: any): Types.Router
	local options: Types.RouterOptions = if input.Routes ~= nil then input else { Routes = input }
	local entries: { Entry } = {}
	local names: { [string]: Entry } = {}
	collect(Define.routes(options.Routes), nil, {}, entries, names)

	local self = setmetatable({
		_ticket = 0,
		_scope = scope,
		_entries = entries,
		_names = names,
		_beforeEach = options.BeforeEach,
		_onChanged = options.OnChanged,
	}, Router) :: any

	local initialTarget: Target = options.Initial or "/"
	local initial = resolve(self, initialTarget, nil, 0)
	if initial == nil then
		if options.Initial == nil then
			fail('add a "/" route, or set Initial to where to start')
		end
		local path, query = Path.parse(
			if typeof(initialTarget) == "string" then initialTarget else initialTarget.Path or "/"
		)
		initial = {
			Path = path,
			Url = Path.format(path, query),
			Params = {},
			Query = query,
			Matched = {},
			Direction = "Initial",
		}
	end

	self._history = History.new((initial :: Route).Url, options.HistoryLimit)
	self._route = initial
	self.Route = scope:Value(initial)
	self.CanGoBack = scope:Value(false)
	self.CanGoForward = scope:Value(false)
	return self
end

function Router.Push(self: RouterImpl, target: Target): boolean
	return navigate(self, target, "Push", 0)
end

function Router.Replace(self: RouterImpl, target: Target): boolean
	return navigate(self, target, "Replace", 0)
end

function Router.Go(self: RouterImpl, delta: number): boolean
	local url = self._history:Peek(delta)
	if url == nil then
		return false
	end
	local to = resolve(self, url, nil, 0)
	if to == nil then
		return false
	end
	local outcome, redirect = check(self, to)
	if outcome == "cancel" then
		return false
	end
	self._history:Go(delta)
	if outcome == "redirect" then
		return navigate(self, redirect :: Target, "Replace", 1)
	end
	commit(self, to, if delta < 0 then "Back" else "Forward")
	return true
end

function Router.Back(self: RouterImpl): boolean
	return self:Go(-1)
end

function Router.Forward(self: RouterImpl): boolean
	return self:Go(1)
end

function Router.Link(self: RouterImpl, target: Target): () -> ()
	return function()
		self:Push(target)
	end
end

function Router.Resolve(self: RouterImpl, target: Target): Route?
	return resolve(self, target, nil, 0)
end

function Router.Href(self: RouterImpl, target: Target): string?
	local route = resolve(self, target, nil, 0)
	return if route then route.Url else nil
end

function Router.Active(self: RouterImpl, target: Target, exact: boolean?): any
	local location = locate(self, target, nil)
	if location == nil then
		return self._scope:Computed(function()
			return false
		end)
	end
	local wanted = location.Path
	return self._scope:Computed(function(use: any)
		local current = (use(self.Route) :: Route).Path
		if current == wanted then
			return true
		end
		return exact ~= true
			and wanted ~= "/"
			and string.sub(current, 1, #wanted + 1) == wanted .. "/"
	end)
end

return Router
