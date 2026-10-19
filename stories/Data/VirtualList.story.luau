--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	return StoryUtil.panel(
		scope,
		220,
		scope:VirtualList({
			ItemCount = 1000,
			ItemHeight = 28,
			Size = UDim2.fromScale(1, 1),
			RenderItem = function(rowScope, index)
				return rowScope:TextLabel({
					BackgroundColor3 = ctx.theme.Colors.SurfaceContainer,
					Text = "Virtual row " .. index,
					TextColor3 = ctx.theme.Colors.OnSurface,
					FontFace = ctx.theme.Fonts.Body,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					Padding = { 4 },
				})
			end,
		})
	)
end)
