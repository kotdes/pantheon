--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:RangeSlider({
		Label = "Price",
		Min = 0,
		Max = 100,
		Step = 1,
		Value = NumberRange.new(20, 60),
	})
end)
