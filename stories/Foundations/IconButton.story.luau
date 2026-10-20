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
			Padding = 8,
		},
		[Children] = {
			scope:IconButton({ Name = "menu" }),
			scope:IconButton({ Name = "moon" }),
			scope:IconButton({ Name = "bell" }),
		},
	})
end)
