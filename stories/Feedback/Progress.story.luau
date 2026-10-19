--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	local Children = StoryUtil.Fusion.Children
	return scope:Frame({
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		Layout = { Kind = "List", Padding = 12 },
		[Children] = {
			scope:Progress({ Value = 0.55, Mode = "Determinate" }),
			scope:Progress({ Mode = "Indeterminate" }),
			scope:Progress({ Value = 0.3, Buffer = 0.65, Mode = "Buffering" }),
		},
	})
end)
