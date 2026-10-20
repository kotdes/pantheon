--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local Children = StoryUtil.Fusion.Children
	local snap = scope:Value(true)
	local progress = scope:Value(0.4)
	return scope:Frame({
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Layout = { Kind = "List", Padding = 16 },
		[Children] = {
			scope:Toolbar({
				Layer = ctx.overlayLayer,
				LayoutOrder = 1,
				Items = {
					{
						Id = "select",
						Icon = "mouse-pointer",
						Tooltip = "Select",
						Shortcut = "V",
						Toggle = true,
						Toggled = true,
					},
					{
						Id = "move",
						Icon = "move-3d",
						Tooltip = "Move",
						Shortcut = "W",
						Toggle = true,
					},
					{
						Id = "rotate",
						Icon = "rotate-3d",
						Tooltip = "Rotate",
						Shortcut = "E",
						Toggle = true,
					},
					{ Separator = true },
					{
						Id = "snap",
						Icon = "sliders-horizontal",
						Text = "Snap",
						Toggle = true,
						Toggled = snap,
					},
					{ Spacer = true },
					{ Id = "play", Icon = "play", Text = "Play", OnClick = function() end },
					{ Id = "off", Icon = "lock", Tooltip = "Disabled", Disabled = true },
				},
			}),
			scope:StatusBar({
				Layer = ctx.overlayLayer,
				LayoutOrder = 2,
				Start = {
					{ Icon = "check", Text = "Ready", Tone = "Success" },
					{ Text = "Workspace" },
				} :: { any },
				Middle = { { Busy = true, Text = "Saving", Progress = progress } },
				End = {
					{
						Icon = "triangle-alert",
						Text = "2 warnings",
						Tone = "Warning",
						Tooltip = "Open the output",
						OnClick = function() end,
					},
					{ Text = "Ln 42, Col 7" },
				} :: { any },
			}),
		},
	})
end)
