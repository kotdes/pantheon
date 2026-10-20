--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	local Children = StoryUtil.Fusion.Children
	return scope:Frame({
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = 8,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			scope:Chip({ Text = "Chip", Selected = true, LayoutOrder = 1 }),
			scope:Chip({ Text = "Filter", LeadingIcon = "filter", LayoutOrder = 2 }),
		},
	})
end)
