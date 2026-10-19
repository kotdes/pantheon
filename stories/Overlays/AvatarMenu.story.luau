--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local open = scope:Value(false)
	local trigger = scope:Button({
		Text = "Avatar menu",
		Variant = "Outlined",
		OnClick = function()
			open:set(true)
		end,
	})
	scope:AvatarMenu({
		Layer = ctx.overlayLayer,
		Open = open,
		Target = trigger,
		Initials = "EU",
		Name = "Pantheon User",
		Subtitle = "you@game.com",
		OnClose = function()
			open:set(false)
		end,
		MaxHeight = 200,
		Sections = {
			{
				Title = "Account",
				Items = {
					{
						Text = "Profile",
						OnClick = function()
							open:set(false)
						end,
					},
					{
						Text = "Settings",
						OnClick = function()
							open:set(false)
						end,
					},
				},
			},
			{
				Title = "Session",
				Items = {
					{
						Text = "Sign out",
						OnClick = function()
							open:set(false)
						end,
					},
				},
			},
		},
	})
	return trigger
end)
