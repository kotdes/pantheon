--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local notices = scope:Value(true)
	local ui = scope:Value(false)
	local master = scope:Value(0.6)
	local notifications = scope:Value(1)
	local appearance = scope:Value("auto")

	return scope:ScrollArea({
		Size = UDim2.fromScale(1, 1),
		ContentPadding = 16,
		ListPadding = 16,
		Children = {
			scope:DataList({
				Children = {
					scope:DataToggle({
						Icon = "bell",
						Title = "Notification sounds",
						Summary = "Play a sound when a message, success, warning or error appears.",
						Value = notices,
					}),
					scope:DataToggle({
						Icon = "volume-2",
						Title = "Interface sounds",
						Summary = "Play a sound when you toggle a setting or open the command bar.",
						Value = ui,
					}),
				},
			}),
			scope:DataList({
				Heading = "Volume",
				Children = {
					scope:DataSlider({ Title = "Master", Value = master }),
					scope:DataSlider({ Title = "Notifications", Value = notifications }),
				},
			}),
			scope:DataList({
				Heading = "Appearance",
				Children = {
					scope:DataSegmented({
						Icon = "sun-moon",
						Title = "Mode",
						Summary = "Which theme to show.",
						Value = appearance,
						Options = {
							{ Value = "auto", Label = "Auto" },
							{ Value = "light", Label = "Light" },
							{ Value = "dark", Label = "Dark" },
						},
						OnChanged = function(value: string)
							appearance:set(value)
						end,
					}),
					scope:DataLink({
						Icon = "type",
						Title = "Font",
						Value = "Montserrat",
						OnClick = function() end,
					}),
					scope:DataRow({
						Icon = "info",
						Title = "A row with no action",
						Summary = "It has no hover state, because it does nothing when pressed.",
					}),
				},
			}),
			scope:DataList({
				Heading = "A list of ListItem rows",
				Children = {
					scope:ListItem({
						Title = "kick",
						PaddingX = ctx.theme.Metrics.SpaceXl,
						Subtitle = "Remove a player",
						OnClick = function() end,
					}),
					scope:ListItem({
						Title = "ban",
						PaddingX = ctx.theme.Metrics.SpaceXl,
						Subtitle = "Ban a player",
						OnClick = function() end,
					}),
				},
			}),
		},
	})
end)
