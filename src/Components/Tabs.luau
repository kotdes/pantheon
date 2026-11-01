--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Chip = require(script.Parent.Chip)
local ScrollArea = require(script.Parent.ScrollArea)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local UNDERLINE = 2

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
		if props.Variant == "Underline" then
			table.insert(
				nodes,
				scope:Frame({
					Name = "Inset",
					BackgroundTransparency = 1,
					Size = UDim2.new(0, theme.Metrics.SpaceMd, 1, 0),
					LayoutOrder = 0,
				})
			)
		end
		for i, item in props.Items do
			table.insert(
				nodes,
				if props.Variant == "Underline"
					then scope:TextButton({
						Name = item.Id,
						Text = "",
						AutoButtonColor = false,
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 1, 0),
						AutomaticSize = Enum.AutomaticSize.X,
						LayoutOrder = i,
						[OnEvent("Activated")] = function()
							selected:set(item.Id)
							if props.OnChanged then
								props.OnChanged(item.Id)
							end
						end,
						[Children] = {
							scope:Frame({
								Name = "Label",
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(0, 1),
								AutomaticSize = Enum.AutomaticSize.X,
								Padding = { 0, theme.Metrics.SpaceXl },
								[Children] = {
									scope:TextLabel({
										BackgroundTransparency = 1,
										FontFace = theme.Typography.Title.Font,
										TextSize = theme.Typography.Body.Size,
										TextColor3 = if item.Id == current
											then theme.Colors.OnSurface
											else theme.Colors.OnSurfaceVariant,
										Text = item.Label,
										AnchorPoint = Vector2.new(0, 0.5),
										Position = UDim2.fromScale(0, 0.5),
										AutomaticSize = Enum.AutomaticSize.XY,
									}),
								},
							}),
							scope:Frame({
								Name = "Underline",
								BackgroundColor3 = theme.Colors.OnSurface,
								AnchorPoint = Vector2.new(0, 1),
								Position = UDim2.fromScale(0, 1),
								Size = UDim2.new(1, 0, 0, UNDERLINE),
								Visible = item.Id == current,
							}),
						},
					})
					else Chip(scope, {
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
		Size = if props.Variant == "Underline"
			then UDim2.fromScale(1, 1)
			else props.Size or UDim2.new(1, 0, 0, 44),
		LayoutOrder = if props.Variant == "Underline" then 0 else props.LayoutOrder or 0,
		Orientation = "Horizontal",
		ContentLayout = "List",
		ContentPadding = 0,
		ListPadding = theme.Metrics.SpaceXs,
		ContentInset = if props.Variant == "Underline" then 0 else nil,
		ScrollBarHidden = props.Variant == "Underline",
		ScrollBarThickness = 4,
		ScrollBarPadding = 4,
		ScrollBarRailBackground = false,
		ScrollButtons = false,
		AutoHideScrollBar = true,
		Children = chips,
	})
	tabs.Name = "Tabs"
	if props.Variant ~= "Underline" then
		return tabs
	end
	tabs.ZIndex = 2
	return scope:Frame({
		Name = "Tabs",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(1, 0, 0, 48),
		LayoutOrder = props.LayoutOrder or 0,
		[Children] = {
			tabs,
			scope:Frame({
				Name = "Divider",
				ZIndex = 1,
				BackgroundColor3 = theme.Colors.OutlineVariant,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 1),
			}),
		},
	})
end
