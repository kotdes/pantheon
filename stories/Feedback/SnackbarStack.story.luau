--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

-- Toasts stack, newest in front. Move the pointer over the stack to spread it out.
return StoryUtil.story(function(scope, _, ctx)
	local toasts = scope:SnackbarHost({ Layer = ctx.overlayLayer })
	local count = 0
	return scope:Frame({
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Layout = { Kind = "List", FillDirection = Enum.FillDirection.Horizontal, Padding = 8 },
		[StoryUtil.Fusion.Children] = {
			scope:Button({
				Text = "Plain toast",
				LayoutOrder = 1,
				OnClick = function()
					count += 1
					toasts.Show(`Saved draft {count}`)
				end,
			}),
			scope:Button({
				Text = "With action and close",
				Variant = "Tonal",
				LayoutOrder = 2,
				OnClick = function()
					count += 1
					toasts.Show(`Message {count} archived`, "Undo", nil, {
						Icon = "archive",
						Dismissible = true,
						Duration = 6,
					})
				end,
			}),
			scope:Button({
				Text = "Custom element",
				Variant = "Outlined",
				LayoutOrder = 3,
				OnClick = function()
					toasts.Show("Uploading", nil, nil, {
						Duration = math.huge,
						Dismissible = true,
						Trailing = function(inner)
							return inner:Spinner({ SizePx = 18 })
						end,
					})
				end,
			}),
		},
	})
end)
