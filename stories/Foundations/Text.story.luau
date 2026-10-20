--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	local Children = StoryUtil.Fusion.Children
	return scope:Frame({
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		Layout = { Kind = "List", Padding = 8, SortOrder = Enum.SortOrder.LayoutOrder },
		[Children] = {
			scope:Text({ Text = "Display", Variant = "Display", LayoutOrder = 1 }),
			scope:Text({ Text = "Headline", Variant = "Headline", LayoutOrder = 2 }),
			scope:Text({ Text = "Title", Variant = "Title", LayoutOrder = 3 }),
			scope:Text({
				Text = "Body copy for Cadence/Tithe surfaces.",
				Variant = "Body",
				LayoutOrder = 4,
			}),
			scope:Text({ Text = "Label", Variant = "Label", LayoutOrder = 5 }),
		},
	})
end)
