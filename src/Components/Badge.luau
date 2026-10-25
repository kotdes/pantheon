--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme

local Children = Fusion.Children
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.BadgeProps): Instance
	local theme = resolveTheme(props)
	local count = peek(props.Count)
	local show = props.Dot == true or (typeof(count) == "number" and count > 0)

	return scope:Frame({
		Name = "Badge",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = props.Size,
		LayoutOrder = props.LayoutOrder or 0,
		[Children] = {
			props.Content,
			if show
				then scope:Frame({
					Name = "BadgeMark",
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, 4, 0, -4),
					Size = if props.Dot then UDim2.fromOffset(10, 10) else UDim2.fromOffset(18, 18),
					BackgroundColor3 = theme.Colors.Error,
					ZIndex = 2,
					CornerRadius = theme.Metrics.RadiusPill,
					[Children] = if props.Dot
						then nil
						else {
							scope:TextLabel({
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),
								FontFace = theme.Fonts.Body,
								TextSize = A.size(theme, 10),
								TextColor3 = theme.Colors.OnError,
								Text = tostring(math.min(count :: number, 99)),
							}),
						},
				})
				else nil,
		},
	}) :: Frame
end
