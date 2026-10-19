--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

local KINDS: { any } = { "Beachball", "Dots", "Bars", "Ripple", "Orbit", "Gnome" }
local MOTIONS: { any } = { "Spin", "Pulse", "Bounce", "Flip", "Wiggle" }

return StoryUtil.story(function(scope)
	local Children = StoryUtil.Fusion.Children
	local items: { any } = {}
	for index, kind in KINDS do
		table.insert(items, scope:Loader({ Kind = kind, SizePx = 40, LayoutOrder = index }))
	end
	-- The icon loader takes a Lucide icon and a motion preset.
	for index, motion in MOTIONS do
		table.insert(
			items,
			scope:Loader({
				Kind = "Icon",
				Icon = "loader",
				Motion = motion,
				SizePx = 40,
				LayoutOrder = #KINDS + index,
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
