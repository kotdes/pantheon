--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Chip = require(script.Parent.Chip)
local ScrollArea = require(script.Parent.ScrollArea)

local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.TabsProps): Instance
	local theme = resolveTheme(props)
	local selected = Persist.value(
		scope,
		Persist.key("Tabs", typeof(props.Selected) == "table"),
		"selected",
		peek(props.Selected) or (props.Items[1] and props.Items[1].Id) or ""
	)
	Bind.link(scope, props.Selected, selected)

	local chips = scope:Computed(function(use)
		local current = use(selected)
		local nodes = {}
		for i, item in props.Items do
			table.insert(
				nodes,
				Chip(scope, {
					Theme = theme,
					Text = item.Label,
					Selected = item.Id == current,
					LayoutOrder = i,
					OnClick = function()
						selected:set(item.Id)
						if props.OnChanged then
							props.OnChanged(item.Id)
						end
					end,
				})
			)
		end
		return nodes
	end)

	local tabs = ScrollArea(scope, {
		Theme = theme,
		Size = props.Size or UDim2.new(1, 0, 0, 44),
		LayoutOrder = props.LayoutOrder or 0,
		Orientation = "Horizontal",
		ContentLayout = "List",
		ContentPadding = 0,
		ListPadding = theme.Metrics.SpaceXs,
		ScrollBarThickness = 4,
		ScrollBarPadding = 4,
		ScrollBarRailBackground = false,
		ScrollButtons = false,
		AutoHideScrollBar = true,
		Children = chips,
	})
	tabs.Name = "Tabs"
	return tabs
end
