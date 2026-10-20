--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local Children = StoryUtil.Fusion.Children
	return scope:Frame({
		Size = UDim2.new(1, 0, 0, 200),
		BackgroundColor3 = ctx.theme.Colors.Surface,
		ClipsDescendants = true,
		CornerRadius = ctx.theme.Metrics.RadiusMd,
		[Children] = {
			scope:Text({
				Text = "Content under scrim",
				Variant = "Body",
				Position = UDim2.fromOffset(16, 16),
			}),
			scope:Overlay({
				Size = UDim2.fromScale(1, 1),
				OnClick = function() end,
			}),
		},
	})
end)
