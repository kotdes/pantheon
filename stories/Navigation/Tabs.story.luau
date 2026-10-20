--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:Tabs({
		Items = {
			{ Id = "one", Label = "One" },
			{ Id = "two", Label = "Two" },
			{ Id = "three", Label = "Three" },
		},
	})
end)
