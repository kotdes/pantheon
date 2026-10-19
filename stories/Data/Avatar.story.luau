--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:Avatar({ Initials = "EU" })
end)
