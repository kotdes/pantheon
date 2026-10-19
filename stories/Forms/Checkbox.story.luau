--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	local Children = StoryUtil.Fusion.Children
	return scope:Frame({
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		Layout = { Kind = "List", Padding = 8 },
		[Children] = {
			scope:Checkbox({ Label = "Accept" }),
			scope:Checkbox({ Label = "Disabled", Disabled = true }),
		},
	})
end)
