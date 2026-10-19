--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

-- Hold Q, point at a choice and release. Or press the button and click one.
return StoryUtil.story(function(scope, _, ctx)
	local open = scope:Value(false)
	local last = scope:Value("nothing")
	scope:RadialMenu({
		Layer = ctx.overlayLayer,
		Open = open,
		Hotkey = Enum.KeyCode.Q,
		Title = "Emote",
		Items = {
			{ Id = "wave", Icon = "hand", Text = "Wave" },
			{ Id = "dance", Icon = "music", Text = "Dance" },
			{ Id = "cheer", Icon = "sparkles", Text = "Cheer" },
			{ Id = "sit", Icon = "armchair", Text = "Sit" },
			{ Id = "point", Icon = "crosshair", Text = "Point", Disabled = true },
			{ Id = "laugh", Icon = "smile", Text = "Laugh" },
		},
		OnSelect = function(id: string)
			last:set(id)
		end,
	})
	return scope:Frame({
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Layout = { Kind = "List", Padding = 12 },
		[StoryUtil.Fusion.Children] = {
			scope:Button({
				Text = "Open the ring",
				LayoutOrder = 1,
				OnClick = function()
					open:set(true)
				end,
			}),
			scope:Text({
				Text = scope:Computed(function(use)
					return "Last: " .. use(last)
				end),
				LayoutOrder = 2,
			}),
		},
	})
end)
