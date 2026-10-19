--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local open = scope:Value(false)
	scope:AppSheet({
		Layer = ctx.overlayLayer,
		Open = open,
		Title = "Quick sheet",
		OnClose = function()
			open:set(false)
		end,
		Children = {
			scope:Frame({
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = 8,
				},
				[scope.Children] = {
					scope:Hydrate(scope:Text({
						Text = "iOS-style app sheet with grabber + scrim.",
						Variant = "Body",
					}))({
						LayoutOrder = 1,
					}),
					scope:Hydrate(scope:StarRating({ Value = 5 }))({
						LayoutOrder = 2,
					}),
				},
			}) :: Frame,
		},
	})
	return scope:Button({
		Text = "Open app sheet",
		LeadingIcon = "panel-bottom",
		OnClick = function()
			open:set(true)
		end,
	})
end)
