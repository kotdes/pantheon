--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:RadioGroup({
		Options = {
			{ Value = "a", Label = "Alpha" },
			{ Value = "b", Label = "Beta" },
		},
	})
end)
