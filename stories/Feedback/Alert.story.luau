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
			scope:Alert({ Title = "Info", Text = "Opaque MD3 alert.", Tone = "Info" }),
			scope:Alert({ Title = "Success", Text = "Saved.", Tone = "Success" }),
			scope:Alert({ Title = "Warning", Text = "Check this.", Tone = "Warning" }),
			scope:Alert({ Title = "Error", Text = "Something failed.", Tone = "Error" }),
		},
	})
end)
