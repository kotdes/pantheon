--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

-- Drag a keypoint. Double click the plot to add one, press Delete on a focused one to remove it.
return StoryUtil.story(function(scope)
	local curve = scope:Value(NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.4, 0.8, 0.1),
		NumberSequenceKeypoint.new(1, 0.2),
	}))
	return scope:CurveEditor({ Value = curve, ShowEnvelope = true })
end)
