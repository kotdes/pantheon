--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:SegmentedControl({
		Items = {
			{ Id = "day", Label = "Day" },
			{ Id = "week", Label = "Week" },
			{ Id = "month", Label = "Month" },
		},
	})
end)
