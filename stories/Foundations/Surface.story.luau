--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:Surface({
		Size = UDim2.new(1, 0, 0, 120),
	})
end)
