--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

return function(scope: Types.Scope, props: Types.BreadcrumbsProps): Instance
	local theme = resolveTheme(props)
	local nodes = {}
	for i, item in props.Items do
		if i > 1 then
			table.insert(
				nodes,
				scope:TextLabel({
					BackgroundTransparency = 1,
					Text = "/",
					FontFace = theme.Fonts.Body,
					TextSize = theme.Typography.Label.Size,
					TextColor3 = theme.Colors.OnSurfaceVariant,
					AutomaticSize = Enum.AutomaticSize.XY,
					LayoutOrder = i * 2 - 1,
				})
			)
		end
		table.insert(
			nodes,
			scope:TextButton({
				BackgroundTransparency = 1,
				Text = item.Label,
				FontFace = theme.Fonts.Body,
				TextSize = theme.Typography.Label.Size,
				TextColor3 = if i == #props.Items
					then theme.Colors.OnSurface
					else theme.Colors.Primary,
				AutomaticSize = Enum.AutomaticSize.XY,
				AutoButtonColor = item.OnClick ~= nil,
				LayoutOrder = i * 2,
				[OnEvent("Activated")] = item.OnClick,
			})
		)
	end
	return scope:Frame({
		Name = "Breadcrumbs",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = props.LayoutOrder or 0,
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = theme.Metrics.SpaceXs,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},
		[Children] = nodes,
	}) :: Frame
end
