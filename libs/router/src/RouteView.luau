--!strict

local Packages = script.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Types)
local Controller = require(script.Parent.Controller)
local Context = require(script.Parent.Context)

local RouteView

local deps: Controller.Deps = {
	innerScope = Fusion.innerScope,
	cleanup = Fusion.doCleanup,
	provide = Context.provide,
	spawn = task.spawn,
	warn = warn,
	createView = function(scope: any, props: Types.RouteViewProps): Instance
		return RouteView(scope, props)
	end,
}

function RouteView(scope: any, props: Types.RouteViewProps): Instance
	local router = props.Router

	local container = scope:New("Frame")({
		Name = "RouteView",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = props.Size or UDim2.fromScale(1, 1),
		Position = props.Position,
		LayoutOrder = props.LayoutOrder,
		ZIndex = props.ZIndex,
		ClipsDescendants = props.ClipsDescendants == true,
	}) :: Frame

	local controller = Controller.new(scope, props, container, deps)

	table.insert(
		scope,
		scope:Observer(router.Route):onBind(function()
			controller.Show(Fusion.peek(router.Route))
		end)
	)
	table.insert(scope, controller.Destroy)

	return container
end

return RouteView
