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
			Padding = 12,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},
		[Children] = {
			scope:Icon({ Name = "sparkles", IconSize = 28 }),
			scope:Icon({ Name = "bell", IconSize = 28 }),
			scope:Icon({ Name = "home", IconSize = 28 }),
			scope:Icon({ Name = "settings", IconSize = 28 }),
		},
	})
end)
