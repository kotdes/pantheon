--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local host = scope:SnackbarHost({ Layer = ctx.overlayLayer })
	return scope:Button({
		Text = "Show toast",
		OnClick = function()
			host.Show("Saved successfully")
		end,
	})
end)
