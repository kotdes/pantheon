--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local target = scope:IconButton({ Name = "moon" })
	scope:Tooltip({
		Layer = ctx.overlayLayer,
		Target = target,
		Text = "Switch theme",
		Placement = "Auto",
	})
	return target
end)
