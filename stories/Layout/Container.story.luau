--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:Container({
		MaxWidth = 480,
		Size = UDim2.new(1, 0, 0, 160),
		Children = {
			scope:Text({ Text = "Constrained container content.", Variant = "Body" }),
			scope:Button({ Text = "Action", Variant = "Tonal" }),
		},
	})
end)
