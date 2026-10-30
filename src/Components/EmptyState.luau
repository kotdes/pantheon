--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Button = require(script.Parent.Button)

local Children = Fusion.Children

return function(scope: Types.Scope, props: Types.EmptyStateProps): Instance
	local theme = resolveTheme(props)
	return scope:Frame({
		Name = "EmptyState",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(1, 0, 0, 160),
		LayoutOrder = props.LayoutOrder or 0,
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.SpaceLg,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			scope:Frame({
				Name = "Labels",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 0,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = theme.Metrics.Space2xs,
				},
				[Children] = {
					scope:TextLabel({
						BackgroundTransparency = 1,
						FontFace = theme.Fonts.Heading,
						TextSize = theme.Typography.Title.Size,
						TextColor3 = theme.Colors.OnSurface,
						Text = props.Title,
						AutomaticSize = Enum.AutomaticSize.XY,
						LayoutOrder = 1,
					}),
					if props.Subtitle
						then scope:TextLabel({
							BackgroundTransparency = 1,
							FontFace = theme.Fonts.Body,
							TextSize = theme.Typography.Label.Size,
							TextColor3 = theme.Colors.OnSurfaceVariant,
							Text = props.Subtitle,
							AutomaticSize = Enum.AutomaticSize.XY,
							LayoutOrder = 2,
						})
						else nil,
				},
			}),
			if props.Action then Button(scope, props.Action) else nil,
		},
	}) :: Frame
end
