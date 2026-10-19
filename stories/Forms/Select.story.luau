--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	return scope:Select({
		Label = "Role",
		Layer = ctx.overlayLayer,
		Options = {
			{ Value = "mod", Label = "Moderator" },
			{ Value = "admin", Label = "Admin" },
		},
	})
end)
