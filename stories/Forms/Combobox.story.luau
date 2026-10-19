--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	return scope:Combobox({
		Label = "Filterable role",
		Layer = ctx.overlayLayer,
		Options = {
			{ Value = "mod", Label = "Moderator" },
			{ Value = "admin", Label = "Admin" },
			{ Value = "user", Label = "User" },
		},
	})
end)
