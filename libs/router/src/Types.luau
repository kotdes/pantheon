--!strict
local Path = require(script.Parent.Path)

export type Params = Path.Params

export type TargetTable = {
	Name: string?,
	Path: string?,
	Params: Params?,
	Query: Params?,
}

export type Target = string | TargetTable

export type GuardResult = boolean | Target | nil

export type Guard = (to: Route, from: Route?) -> GuardResult

export type Direction = "Initial" | "Forward" | "Back" | "Replace"

export type RouteRecord = {
	Name: string?,

	Path: string?,
	Render: ((scope: any, context: RouteContext) -> Instance?)?,
	Children: { [any]: any }?,
	Redirect: Target?,
	Load: ((context: RouteContext) -> any)?,
	Pending: ((scope: any, context: RouteContext) -> Instance?)?,
	Error: ((scope: any, context: RouteContext, err: any) -> Instance?)?,
	Key: ((route: Route) -> any)?,
	BeforeEnter: Guard?,
	BeforeLeave: Guard?,
	Meta: { [string]: any }?,
}

export type Route = {
	Path: string,
	Url: string,
	Name: string?,
	Params: Params,
	Query: Params,
	Matched: { RouteRecord },
	Direction: Direction,
}

export type RouteContext = {
	Router: Router,
	Initial: Route,
	Route: any,
	Params: any,
	Query: any,
	Param: (name: string) -> any,
	Data: any,
	Outlet: (props: OutletProps?) -> Instance,
}

export type OutletProps = {
	Size: UDim2?,
	Position: UDim2?,
	LayoutOrder: number?,
	ZIndex: number?,
	ClipsDescendants: boolean?,
}

export type TransitionInfo = {
	Entering: Instance,
	Leaving: Instance,
	Direction: Direction,
	From: Route?,
	To: Route,
	Finish: () -> (),
}

export type Transition = (info: TransitionInfo) -> ()

export type RouterOptions = {
	Routes: { [any]: any },
	Initial: Target?,
	BeforeEach: Guard?,
	OnChanged: ((to: Route, from: Route?) -> ())?,
	HistoryLimit: number?,
}

export type Router = {
	Route: any,
	CanGoBack: any,
	CanGoForward: any,
	Push: (self: Router, target: Target) -> boolean,
	Replace: (self: Router, target: Target) -> boolean,
	Back: (self: Router) -> boolean,
	Forward: (self: Router) -> boolean,
	Go: (self: Router, delta: number) -> boolean,
	Resolve: (self: Router, target: Target) -> Route?,
	Href: (self: Router, target: Target) -> string?,
	Active: (self: Router, target: Target, exact: boolean?) -> any,
	Link: (self: Router, target: Target) -> () -> (),
}

export type RouteViewProps = {
	Router: Router,
	Depth: number?,
	NotFound: ((scope: any, context: RouteContext) -> Instance?)?,
	Pending: ((scope: any, context: RouteContext) -> Instance?)?,
	Error: ((scope: any, context: RouteContext, err: any) -> Instance?)?,
	Transition: Transition?,
	Size: UDim2?,
	Position: UDim2?,
	LayoutOrder: number?,
	ZIndex: number?,
	ClipsDescendants: boolean?,
}

return {}
