--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

-- Drag a label sideways to scrub. Shift is x10, Alt is x0.1. The arrow keys step the value.
return StoryUtil.story(function(scope)
	local Children = StoryUtil.Fusion.Children
	local x = scope:Value(0)
	local opacity = scope:Value(0.5)
	return scope:Frame({
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Layout = { Kind = "List", Padding = 8 },
		[Children] = {
			scope:NumberField({ Label = "X", Value = x, Step = 1, Suffix = "px", LayoutOrder = 1 }),
			scope:NumberField({
				Label = "α",
				Value = opacity,
				Min = 0,
				Max = 1,
				Step = 0.01,
				LayoutOrder = 2,
			}),
			scope:NumberField({ Value = 12, Min = 0, Max = 99, Disabled = true, LayoutOrder = 3 }),
		},
	})
end)
