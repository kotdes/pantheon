--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	local Children = StoryUtil.Fusion.Children
	return scope:Frame({
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = 24,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},
		[Children] = {
			scope:LoadingIndicator({ SizePx = 48, LayoutOrder = 1 }),
			scope:LoadingIndicator({ SizePx = 56, Contained = true, LayoutOrder = 2 }),
			scope:LoadingIndicator({ SizePx = 96, Contained = true, LayoutOrder = 3 }),
		},
	})
end)
