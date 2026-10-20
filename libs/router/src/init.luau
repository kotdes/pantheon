--!strict

local Path = require(script.Path)
local History = require(script.History)
local Router = require(script.Router)
local RouteView = require(script.RouteView)
local Context = require(script.Context)
local Transitions = require(script.Transitions)
local Types = require(script.Types)

export type Target = Types.Target
export type Params = Types.Params
export type Guard = Types.Guard
export type GuardResult = Types.GuardResult
export type Direction = Types.Direction
export type Route = Types.Route
export type RouteRecord = Types.RouteRecord
export type RouteContext = Types.RouteContext
export type Router = Types.Router
export type RouterOptions = Types.RouterOptions
export type RouteViewProps = Types.RouteViewProps
export type Transition = Types.Transition
export type TransitionInfo = Types.TransitionInfo

local function mount(
	scope: any,
	routes: { [any]: any },
	viewProps: Types.RouteViewProps?
): (Instance, Types.Router)
	local router = Router.new(scope, routes)
	local props: any = if viewProps then table.clone(viewProps) else {}
	props.Router = router
	return RouteView(scope, props), router
end

return {
	new = Router.new,
	mount = mount,
	RouteView = RouteView,
	use = Context.use,
	Transitions = Transitions,
	Path = Path,
	History = History,
	Version = { major = 0, minor = 1, isRelease = true },
}
