--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

-- Hue ring around the saturation/value square (needs conical gradients).
return StoryUtil.story(function(scope)
	return scope:ColorPicker({
		Area = "Wheel",
		Modes = { "Spectrum", "Sliders", "Grid" },
		Models = { "HSB", "LAB", "Hex" },
	})
end)
