--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local Children = StoryUtil.Fusion.Children
	return scope:Frame({
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromScale(1, 0),
		Layout = { Kind = "List", Padding = 12, SortOrder = Enum.SortOrder.LayoutOrder },
		[Children] = {
			scope:MultiSelect({
				LayoutOrder = 1,
				Layer = ctx.overlayLayer,
				Label = "Tags",
				Display = "Chips",
				Options = {
					{ Value = "a", Label = "Alpha" },
					{ Value = "b", Label = "Beta" },
					{ Value = "c", Label = "Gamma" },
				},
			}),
			scope:MultiSelect({
				LayoutOrder = 2,
				Layer = ctx.overlayLayer,
				Label = "Tags (count)",
				Display = "Count",
				Options = {
					{ Value = "a", Label = "Alpha" },
					{ Value = "b", Label = "Beta" },
					{ Value = "c", Label = "Gamma" },
				},
			}),
		},
	})
end)
