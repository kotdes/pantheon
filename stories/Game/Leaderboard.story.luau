--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

-- Hover a row to swap the display name for the username. Press a team header to fold it.
return StoryUtil.story(function(scope, _, ctx)
	local Game = ctx.Pantheon.Game
	local Children = StoryUtil.Fusion.Children
	local peek = StoryUtil.peek
	local teams = scope:Value({
		{
			Name = "Red",
			Color = Color3.fromRGB(196, 40, 28),
			Players = {
				{ Id = 1, Name = "ada_l", DisplayName = "Ada", UserId = 1, Value = 4200 },
				{ Id = 2, Name = "grace", DisplayName = "Grace H.", UserId = 156, Value = 3100 },
			},
		},
		{
			Name = "Blue",
			Color = Color3.fromRGB(13, 105, 172),
			Players = {
				{ Id = 3, Name = "you", DisplayName = "You", UserId = 261, Value = 5300 },
				{ Id = 4, Name = "linus", DisplayName = "Linus", UserId = 1234, Value = 900 },
			},
		},
	} :: { any })
	local nextId = 10
	local function join()
		nextId += 1
		local list = table.clone(peek(teams))
		local team = table.clone(list[math.random(1, #list)])
		local players = table.clone(team.Players)
		table.insert(players, {
			Id = nextId,
			Name = `player{nextId}`,
			DisplayName = `Player {nextId}`,
			UserId = nextId,
			Value = math.random(100, 6000),
		})
		team.Players = players
		for index, existing in list do
			if existing.Name == team.Name then
				list[index] = team
			end
		end
		teams:set(list)
	end
	return scope:Frame({
		BackgroundColor3 = Color3.fromRGB(46, 62, 88),
		Size = UDim2.new(1, 0, 0, 380),
		ClipsDescendants = true,
		CornerRadius = 8,
		[Children] = {
			Game.Leaderboard(
				scope,
				{ Teams = teams, Self = 3, Sort = "Value", Position = UDim2.new(1, -12, 0, 12) }
			),
			scope:Frame({
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(12, 12),
				AutomaticSize = Enum.AutomaticSize.XY,
				[Children] = scope:Button({
					Text = "A player joins",
					Variant = "Tonal",
					OnClick = join,
				}),
			}),
		},
	})
end)
