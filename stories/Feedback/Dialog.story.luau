--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local open = scope:Value(false)
	scope:Dialog({
		Layer = ctx.overlayLayer,
		Title = "Dialog",
		Body = "Centered modal with actions.",
		Open = open,
		OnClose = function()
			open:set(false)
		end,
		Actions = {
			{
				Text = "Cancel",
				OnClick = function()
					open:set(false)
				end,
			},
			{
				Text = "OK",
				Variant = "Primary",
				OnClick = function()
					open:set(false)
				end,
			},
		},
	})
	return scope:Button({
		Text = "Open dialog",
		OnClick = function()
			open:set(true)
		end,
	})
end)
