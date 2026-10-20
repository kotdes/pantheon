--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:ListItem({
		Title = "Notifications",
		Subtitle = "Push & email",
		OnClick = function() end,
	})
end)
