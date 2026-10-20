--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

local KINDS: { any } = {
	"M3Morph",
	"M2Spinner",
	"Beachball",
	"Dots",
	"Bars",
	"Ripple",
	"Orbit",
	"Gnome",
}
local MOTIONS: { any } = { "Spin", "Pulse", "Bounce", "Flip", "Wiggle" }

return StoryUtil.story(function(scope)
	local Children = StoryUtil.Fusion.Children
	local items: { any } = {}
	for index, kind in KINDS do
		table.insert(
			items,
			scope:LoadingIndicator({ Kind = kind, SizePx = 40, LayoutOrder = index })
		)
	end
	-- The Material 3 shape can sit in a round container.
	table.insert(
		items,
		scope:LoadingIndicator({
			Kind = "M3Morph",
			SizePx = 56,
			Contained = true,
			LayoutOrder = #KINDS + 1,
		})
	)
	-- The icon kind takes a Lucide icon and a motion preset.
	for index, motion in MOTIONS do
		table.insert(
			items,
			scope:LoadingIndicator({
				Kind = "Icon",
				Icon = "loader",
				Motion = motion,
				SizePx = 40,
				LayoutOrder = #KINDS + 1 + index,
			})
		)
	end
	return scope:Frame({
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			Wraps = true,
			Padding = 24,
		},
		[Children] = items,
	})
end)
