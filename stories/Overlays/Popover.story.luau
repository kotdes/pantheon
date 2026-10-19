--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local open = scope:Value(false)
	local trigger = scope:Button({
		Text = "Open popover",
		Variant = "Tonal",
		OnClick = function()
			open:set(true)
		end,
	})
	scope:Popover({
		Layer = ctx.overlayLayer,
		Open = open,
		Target = trigger,
		Placement = "Bottom",
		OnClose = function()
			open:set(false)
		end,
		Items = {
			{
				Text = "Action A",
				OnClick = function()
					open:set(false)
				end,
			},
			{
				Text = "Action B",
				OnClick = function()
					open:set(false)
				end,
			},
			{ Text = "Disabled", Disabled = true },
		} :: { any },
	})
	return trigger
end)
