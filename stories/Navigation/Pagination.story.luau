--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:Pagination({ PageCount = 5 })
end)
