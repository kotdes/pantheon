--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme

local Children = Fusion.Children

return function(scope: Types.Scope, props: Types.CardProps): Instance
	local theme = resolveTheme(props)
	return scope:Frame({
		Name = "Card",
		BackgroundColor3 = theme.Colors.SurfaceContainer,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		CornerRadius = theme.Metrics.RadiusPanel,
		Padding = { theme.Metrics.SpaceMd },
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.SpaceSm,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			if props.Title
				then scope:TextLabel({
					BackgroundTransparency = 1,
					FontFace = theme.Fonts.Heading,
					TextSize = A.size(theme, 16),
					TextColor3 = theme.Colors.OnSurface,
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = props.Title,
					Size = UDim2.new(1, 0, 0, 22),
					LayoutOrder = 1,
				})
				else nil,
			if props.Subtitle
				then scope:TextLabel({
					BackgroundTransparency = 1,
					FontFace = theme.Fonts.Body,
					TextSize = A.size(theme, 13),
					TextColor3 = theme.Colors.OnSurfaceVariant,
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = props.Subtitle,
					Size = UDim2.new(1, 0, 0, 18),
					LayoutOrder = 2,
				})
				else nil,
			props.Children,
		},
	}) :: Frame
end
