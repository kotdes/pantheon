--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	local Children = StoryUtil.Fusion.Children
	return scope:Frame({
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		Layout = { Kind = "List", Padding = 0 },
		[Children] = {
			scope:Text({ Text = "Before spacer", Variant = "Body" }),
			scope:Spacer({ Size = UDim2.new(1, 0, 0, 24) }),
			scope:Text({ Text = "After spacer", Variant = "Body" }),
		},
	})
end)
