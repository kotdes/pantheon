--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:Badge({
		Count = 3,
		Content = scope:IconButton({ Name = "bell" }),
	})
end)
