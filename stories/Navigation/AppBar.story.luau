--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:AppBar({
		Title = "pantheon catalog",
		Leading = scope:IconButton({ Name = "menu" }),
		Actions = {
			scope:IconButton({ Name = "moon" }),
		},
	})
end)
