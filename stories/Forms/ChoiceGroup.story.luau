--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:ChoiceGroup({
		Label = "Plan",
		Variant = "Segmented",
		Options = {
			{ Value = "free", Label = "Free" },
			{ Value = "pro", Label = "Pro" },
		},
	})
end)
