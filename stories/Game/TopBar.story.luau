--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)
local Fusion = StoryUtil.Fusion

local Children = Fusion.Children
local peek = Fusion.peek

return StoryUtil.story(function(scope, _, ctx)
	local Game = ctx.Pantheon.Game
	local unread = scope:Value(3)
	local chatOpen = scope:Value(false)
	return scope:New("Frame")({
		Name = "Stage",
		Size = UDim2.new(1, 0, 0, 160),
		BackgroundColor3 = Color3.fromRGB(46, 62, 88),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(0, 8) }),
			Game.TopBar(scope, {
				Left = {
					{ Id = "menu", Text = "≡" },
					{
						Id = "chat",
						Text = "…",
						Badge = unread,
						Active = chatOpen,
						OnClick = function()
							chatOpen:set(not peek(chatOpen))
							unread:set(0)
						end,
					},
				},
				Right = {
					{
						Id = "notify",
						Text = "!",
						OnClick = function()
							unread:set(peek(unread) + 1)
						end,
					},
				},
			}),
		},
	})
end)
