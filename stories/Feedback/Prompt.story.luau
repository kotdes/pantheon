--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local open = scope:Value(false)
	scope:Prompt({
		Layer = ctx.overlayLayer,
		Title = "Discard changes?",
		Body = "Your edits will be lost. This action cannot be undone.",
		Icon = "triangle-alert",
		Open = open,
		ConfirmText = "Discard",
		Destructive = true,
		OnClose = function()
			open:set(false)
		end,
		OnConfirm = function()
			open:set(false)
		end,
	})
	return scope:Button({
		Text = "Open prompt",
		Variant = "Outlined",
		OnClick = function()
			open:set(true)
		end,
	})
end)
