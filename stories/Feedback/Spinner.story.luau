--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	local Children = StoryUtil.Fusion.Children
	return scope:Frame({
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = 16,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},
		[Children] = {
			scope:Spinner({ SizePx = 22 }),
			scope:Spinner({ SizePx = 36 }),
			scope:Text({ Text = "Loading…", Variant = "Label" }),
		},
	})
end)
