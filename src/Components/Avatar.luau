--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme

local Children = Fusion.Children

return function(scope: Types.Scope, props: Types.AvatarProps): Instance
	local theme = resolveTheme(props)
	local size = props.AvatarSize or 40
	return scope:Frame({
		Name = "Avatar",
		BackgroundColor3 = theme.Colors.PrimaryContainer,
		Size = props.Size or UDim2.fromOffset(size, size),
		LayoutOrder = props.LayoutOrder or 0,
		CornerRadius = theme.Metrics.RadiusPill,
		[Children] = {
			if props.Image
				then scope:ImageLabel({
					BackgroundTransparency = 1,
					Image = props.Image,
					Size = UDim2.fromScale(1, 1),
					ScaleType = Enum.ScaleType.Crop,
					CornerRadius = theme.Metrics.RadiusPill,
				})
				else scope:TextLabel({
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					FontFace = theme.Fonts.Heading,
					TextSize = size * 0.4,
					TextColor3 = theme.Colors.OnPrimaryContainer,
					Text = props.Initials or "?",
				}),
		},
	}) :: Frame
end
