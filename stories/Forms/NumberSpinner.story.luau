--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	local Children = StoryUtil.Fusion.Children
	local peek = StoryUtil.peek
	local count = scope:Value(1280)
	local function nudge(amount: number)
		count:set(math.max(0, peek(count) + amount))
	end
	return scope:Frame({
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Layout = { Kind = "List", Padding = 16 },
		[Children] = {
			scope:NumberSpinner({
				Value = count,
				Prefix = "$",
				Decimals = 2,
				TextSize = 36,
				LayoutOrder = 1,
			}),
			-- "Roll" turns every digit in between, like an odometer.
			scope:NumberSpinner({ Value = count, Style = "Roll", TextSize = 28, LayoutOrder = 2 }),
			scope:Frame({
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 3,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = 8,
				},
				[Children] = {
					scope:Button({
						Text = "+7",
						LayoutOrder = 1,
						OnClick = function()
							nudge(7)
						end,
					}),
					scope:Button({
						Text = "+1,234",
						LayoutOrder = 2,
						OnClick = function()
							nudge(1234)
						end,
					}),
					scope:Button({
						Text = "−500",
						LayoutOrder = 3,
						OnClick = function()
							nudge(-500)
						end,
					}),
				},
			}),
		},
	})
end)
