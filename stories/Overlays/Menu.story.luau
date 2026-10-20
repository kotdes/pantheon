--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local open = scope:Value(false)
	local notifyOn = scope:Value(true)
	local function close()
		open:set(false)
	end
	local trigger = scope:Button({
		Text = "Open menu",
		Variant = "Tonal" :: "Tonal",
		OnClick = function()
			open:set(true)
		end,
	})
	scope:Menu({
		Layer = ctx.overlayLayer,
		Open = open,
		OnClose = close,
		MaxHeight = 280,
		RootPage = "root",
		Children = {
			scope:MenuPage({
				Id = "root",
				LayoutOrder = 1,
				Children = {
					scope:MenuSection({
						Title = "File",
						Icon = "folder",
						LayoutOrder = 1,
						Children = {
							scope:MenuButton({
								Text = "New",
								Leading = "file-plus",
								OnClose = close,
								LayoutOrder = 1,
							}),
							scope:MenuButton({
								Text = "Open",
								Leading = "folder-open",
								OnClose = close,
								LayoutOrder = 2,
							}),
							scope:MenuButton({
								Text = "Save",
								Leading = "save",
								Trailing = "corner-down-left",
								OnClose = close,
								LayoutOrder = 3,
							}),
						},
					}),
					scope:MenuSection({
						Title = "Edit",
						Icon = "pencil",
						Collapsible = true,
						Expanded = true,
						LayoutOrder = 2,
						Children = {
							scope:MenuButton({
								Text = "Cut",
								Leading = "scissors",
								OnClose = close,
								LayoutOrder = 1,
							}),
							scope:MenuButton({
								Text = "Copy",
								Leading = "copy",
								OnClose = close,
								LayoutOrder = 2,
							}),
							scope:MenuButton({
								Text = "Paste",
								Leading = "clipboard",
								OnClose = close,
								LayoutOrder = 3,
							}),
							scope:MenuButton({
								Text = "Disabled",
								Leading = "ban",
								Disabled = true,
								LayoutOrder = 4,
							}),
						},
					}),
					scope:MenuSection({
						Title = "Account",
						Icon = "user",
						LayoutOrder = 3,
						Children = {
							scope:MenuButton({
								Text = "Settings",
								Leading = "settings",
								Trailing = "chevron-right",
								Page = "settings",
								LayoutOrder = 1,
							}),
							scope:MenuButton({
								Text = "Sign out",
								Leading = "log-out",
								Color = "error",
								OnClose = close,
								LayoutOrder = 2,
							}),
						},
					}),
				},
			}),
			scope:MenuPage({
				Id = "settings",
				Title = "Settings",
				LayoutOrder = 2,
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
						OnClose = close,
						LayoutOrder = 2,
					}),
				},
			}),
		},
	})
	return trigger
end)
