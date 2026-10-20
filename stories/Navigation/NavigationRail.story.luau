--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local rail = scope:NavigationRail({
		Orientation = "Horizontal",
		Layer = ctx.overlayLayer,
		Items = {
			{ Id = "home", Icon = "home", Label = "Home" },
			{ Id = "lib", Icon = "library", Label = "Lib" },
			{ Id = "set", Icon = "settings", Label = "Settings" },
		},
	})
	return StoryUtil.panel(
		scope,
		320,
		scope:Hydrate(rail)({
			Size = UDim2.new(1, 0, 0, 52),
		})
	)
end)
