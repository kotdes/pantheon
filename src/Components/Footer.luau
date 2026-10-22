--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local EdgeFade = require(script.Parent.Parent.Internal.EdgeFade)

local Children = Fusion.Children

return function(scope: Types.Scope, props: Types.FooterProps): Instance
	local theme = resolveTheme(props)
	local gradient = props.Variant == "Gradient"
	local barHeight = props.Height or theme.Metrics.AppBarHeight
	local fadeHeight = if gradient then props.FadeHeight or 24 else 0

	local footer = scope:Frame({
		Name = "Footer",
		BackgroundColor3 = props.FadeTo or theme.Colors.SurfaceContainerHigh,
		CornerRadius = props.Radius or { 0, theme.Metrics.RadiusPanel },
		Size = props.Size or UDim2.new(1, 0, 0, barHeight + fadeHeight),
		LayoutOrder = props.LayoutOrder or 0,
		ZIndex = props.ZIndex or 10,
		[Children] = {
			scope:Frame({
				Name = "Divider",
				Visible = not gradient,
				BackgroundColor3 = theme.Colors.OutlineVariant,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 1),
				ZIndex = 2,
			}),
			if gradient then EdgeFade.gradient(scope, 270, barHeight, fadeHeight) else nil,
			scope:Frame({
				Name = "Row",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, barHeight),
				Padding = { 0, theme.Metrics.SpaceMd },
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = theme.Metrics.SpaceXs,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = props.Children,
			}),
		},
	}) :: Frame
	footer:SetAttribute(EdgeFade.HeightAttribute, barHeight + fadeHeight)
	footer:SetAttribute(EdgeFade.FadeAttribute, fadeHeight)
	return footer
end
