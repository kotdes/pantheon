--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local open = scope:Value(false)
	local notifyOn = scope:Value(true)
	local function close()
		open:set(false)
	end
	scope:NavigationDrawer({
		Layer = ctx.overlayLayer,
		Open = open,
		Title = "Cadence",
		Subtitle = "pantheon catalog",
		AvatarInitials = "EU",
		Inset = 4,
		CornerRadius = ctx.theme.Metrics.RadiusPanel + 4,
		OnClose = close,
		InitialPage = "root",
		Sections = {
			{
				Items = {
					{ Text = "Home", Leading = "home", OnClick = close },
					{ Text = "Library", Leading = "library", OnClick = close },
					{ Text = "Search", Leading = "search", OnClick = close },
				},
			},
			{
				Title = "Account",
				Icon = "user",
				Collapsible = true,
				DefaultExpanded = true,
				Items = {
					{ Text = "Profile", Leading = "circle-user", OnClick = close },
					{
						Text = "Settings",
						Leading = "settings",
						Trailing = "chevron-right",
						Page = "settings",
					},
					{ Text = "Sign out", Leading = "log-out", Color = "error", OnClick = close },
				} :: { any },
			},
		},
		Children = {
			scope:MenuPage({
				Id = "settings",
				Title = "Settings",
				Children = {
					scope:MenuButton({
						Text = "Notifications",
						Leading = "bell",
						Trailing = scope:Switch({ Checked = notifyOn }),
						LayoutOrder = 1,
					}),
					scope:MenuButton({
						Text = "Appearance",
						Leading = "moon",
						Trailing = "chevron-right",
						OnClick = close,
						LayoutOrder = 2,
					}),
				},
			}),
		},
	})
	return scope:Button({
		Text = "Open drawer",
		LeadingIcon = "menu",
		OnClick = function()
			open:set(true)
		end,
	})
end)
