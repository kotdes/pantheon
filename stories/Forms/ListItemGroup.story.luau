--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

local FONTS = {
	{ Value = "montserrat", Label = "Montserrat" },
	{ Value = "inter", Label = "Inter" },
	{ Value = "roboto", Label = "Roboto" },
}

local MODES = {
	{ Value = "auto", Label = "Auto" },
	{ Value = "light", Label = "Light" },
	{ Value = "dark", Label = "Dark" },
}

return StoryUtil.story(function(scope, _, ctx)
	local layer = ctx.overlayLayer
	local notices = scope:Value(true)
	local ui = scope:Value(false)
	local remember = scope:Value(true)
	local master = scope:Value(0.6)
	local notifications = scope:Value(1)
	local range = scope:Value(40)
	local appearance = scope:Value("auto")
	local font = scope:Value("montserrat")
	local fontInline = scope:Value("inter")
	local fontSheet = scope:Value("roboto")
	local name = scope:Value("Ada")
	local notes = scope:Value("")
	local bio = scope:Value("")
	local amount = scope:Value(12)
	local accent = scope:Value(Color3.fromRGB(103, 80, 164))

	return scope:ScrollArea({
		Size = UDim2.fromScale(1, 1),
		ContentPadding = 16,
		ListPadding = 16,
		Children = {
			scope:ListItemGroup({
				Children = {
					scope:ItemSwitch({
						Icon = "bell",
						Title = "Notification sounds",
						Subtitle = "Play a sound when a message, success, warning or error appears.",
						Value = notices,
					}),
					scope:ItemSwitch({
						Icon = "volume-2",
						Title = "Interface sounds",
						Value = ui,
					}),
					scope:ItemCheckbox({
						Icon = "save",
						Title = "Remember my choices",
						Value = remember,
					}),
					scope:ListItem({
						Icon = "info",
						Title = "A row with no action",
						Subtitle = "It has no hover state, because it does nothing when pressed.",
					}),
					scope:ListItem({
						Icon = "type",
						Title = "A row with a chevron",
						Chevron = true,
						OnClick = function() end,
					}),
				},
			}),
			scope:ListItemGroup({
				Heading = "Sliders",
				Children = {
					scope:ItemSlider({ Title = "Master", Value = master }),
					scope:ItemSlider({ Title = "Notifications", Value = notifications }),
					scope:ItemSlider({
						Title = "Range",
						Value = range,
						Min = 0,
						Max = 100,
						Step = 1,
						Format = function(value: number)
							return `{math.floor(value)} px`
						end,
					}),
				},
			}),
			scope:ListItemGroup({
				Heading = "Choosing",
				Children = {
					scope:ItemSegmented({
						Icon = "sun-moon",
						Title = "Mode",
						Subtitle = "Which theme to show.",
						Value = appearance,
						Options = MODES,
					}),
					scope:ItemSelect({
						Icon = "type",
						Title = "Font (inline)",
						Layer = layer,
						Value = fontInline,
						Options = FONTS,
					}),
					scope:ItemSelect({
						Icon = "type",
						Title = "Font (accordion)",
						Mode = "Accordion",
						Value = font,
						Options = FONTS,
					}),
					scope:ItemSelect({
						Icon = "type",
						Title = "Font (sheet)",
						Mode = "Prompt",
						Layer = layer,
						Value = fontSheet,
						Options = FONTS,
					}),
					scope:ItemRadio({
						Icon = "type",
						Title = "Font (radio, inline)",
						Mode = "Inline",
						Value = font,
						Options = FONTS,
					}),
				},
			}),
			scope:ListItemGroup({
				Heading = "Typing",
				Children = {
					scope:ItemText({
						Icon = "user",
						Title = "Name",
						Placeholder = "Your name",
						Value = name,
					}),
					scope:ItemText({
						Icon = "notebook-pen",
						Title = "Notes",
						Mode = "Accordion",
						Placeholder = "Notes",
						Multiline = true,
						Value = notes,
					}),
					scope:ItemText({
						Icon = "file-text",
						Title = "Bio",
						Mode = "Prompt",
						Layer = layer,
						Multiline = true,
						Value = bio,
					}),
					scope:ItemNumber({
						Icon = "hash",
						Title = "Amount",
						Min = 0,
						Max = 100,
						Value = amount,
					}),
					scope:ItemNumber({
						Icon = "hash",
						Title = "Amount (sheet)",
						Mode = "Prompt",
						Layer = layer,
						Min = 0,
						Max = 100,
						Value = amount,
					}),
				},
			}),
			scope:ListItemGroup({
				Heading = "Colour",
				Children = {
					scope:ItemColour({
						Icon = "palette",
						Title = "Accent (sheet)",
						Layer = layer,
						Value = accent,
					}),
					scope:ItemColour({
						Icon = "palette",
						Title = "Accent (accordion)",
						Mode = "Accordion",
						Value = accent,
					}),
				},
			}),
		},
	})
end)
