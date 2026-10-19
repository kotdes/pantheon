--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local Children = StoryUtil.Fusion.Children
	local peek = StoryUtil.peek
	local open = scope:Value(true)
	local target = scope:Button({ Text = "New feature", Variant = "Tonal", LayoutOrder = 1 })
	scope:Coachmark({
		Layer = ctx.overlayLayer,
		Target = target,
		Open = open,
		Step = "1 of 3",
		Title = "Try this first",
		Text = "The coach mark points at a control and dims the rest.",
		OnDismiss = function()
			open:set(false)
		end,
	})
	return scope:Frame({
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Layout = { Kind = "List", Padding = 16 },
		[Children] = {
			target,
			scope:Button({
				Text = "Show again",
				LayoutOrder = 2,
				OnClick = function()
					open:set(not peek(open))
				end,
			}),
		},
	})
end)
