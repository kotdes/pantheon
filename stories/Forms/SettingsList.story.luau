--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:SettingsList({
		Header = "Account",
		Items = {
			{
				Title = "Profile",
				Subtitle = "Name, email, avatar",
				Icon = "user",
				OnClick = function() end,
			},
			{
				Title = "Notifications",
				Subtitle = "Push & email",
				Icon = "bell",
				OnClick = function() end,
			},
			{
				Title = "Dark mode",
				Subtitle = "Appearance",
				Icon = "moon",
				Trailing = scope:Switch({ Checked = false }),
				ShowChevron = false,
			},
		} :: { any },
	})
end)
