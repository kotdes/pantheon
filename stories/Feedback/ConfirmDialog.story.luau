--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local open = scope:Value(false)
	scope:ConfirmDialog({
		Layer = ctx.overlayLayer,
		Title = "Delete item?",
		Body = "This cannot be undone.",
		Icon = "triangle-alert",
		Open = open,
		ConfirmText = "Delete",
		OnClose = function()
			open:set(false)
		end,
		OnConfirm = function()
			open:set(false)
		end,
	})
	return scope:Button({
		Text = "Open confirm dialog",
		Variant = "Outlined",
		OnClick = function()
			open:set(true)
		end,
	})
end)
