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
			scope:Text({ Text = "Variants", Variant = "Label", LayoutOrder = 0 }),
			scope:Button({
				Text = "Filled",
				Variant = "Filled",
				Color = "primary",
				LayoutOrder = 1,
			}),
			scope:Button({ Text = "Tonal", Variant = "Tonal", Color = "primary", LayoutOrder = 2 }),
			scope:Button({
				Text = "Outlined",
				Variant = "Outlined",
				Color = "primary",
				LayoutOrder = 3,
			}),
			scope:Text({ Text = "Material swatches", Variant = "Label", LayoutOrder = 4 }),
			scope:Button({
				Text = "Blue 500",
				Variant = "Filled",
				Color = "Blue 500",
				LayoutOrder = 5,
			}),
			scope:Button({
				Text = "Blue 700",
				Variant = "Filled",
				Color = "Blue 700",
				LayoutOrder = 6,
			}),
			scope:Button({
				Text = "Red A200",
				Variant = "Filled",
				Color = "Red A200",
				LayoutOrder = 7,
			}),
			scope:Button({
				Text = "Teal 400",
				Variant = "Tonal",
				Color = { Teal = 400 },
				LayoutOrder = 8,
			}),
			scope:Button({
				Text = "Grey 600",
				Variant = "Tonal",
				Color = "Grey 600",
				LayoutOrder = 9,
			}),
			scope:Button({
				Text = "DeepPurple 500",
				Variant = "Outlined",
				Color = "DeepPurple 500",
				LayoutOrder = 10,
			}),
			scope:Text({ Text = "Semantic", Variant = "Label", LayoutOrder = 11 }),
			scope:Button({
				Text = "Secondary",
				Variant = "Tonal",
				Color = "secondary",
				LayoutOrder = 12,
			}),
			scope:Button({ Text = "Error", Variant = "Filled", Color = "error", LayoutOrder = 13 }),
			scope:Button({ Text = "Disabled", Disabled = true, LayoutOrder = 14 }),
		},
	})
end)
