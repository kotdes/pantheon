--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:Card({
		Title = "Card",
		Subtitle = "Elevated surface",
	})
end)
