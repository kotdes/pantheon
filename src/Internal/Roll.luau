--!strict
local Fusion = require(script.Parent.Parent.Parent.Fusion)
local Types = require(script.Parent.Parent.Types)
local Motion = require(script.Parent.Motion)
local TextBlur = require(script.Parent.TextBlur)

local Children = Fusion.Children
local peek = Fusion.peek

--[[
	A label whose text rolls when it changes: the old text slides out and fades, and the new text
	slides in from the same side. The label is as wide as its current text.

	`order` says which way it rolls. When it goes up, the text rolls up, and when it goes down,
	it rolls down. The motion is a spring, so it follows the theme.
]]
local Roll = {}

export type Props = {
	Theme: Types.Theme,
	Text: any, -- a state of the text
	Order: any, -- a state of a number, which says which way the text moves
	Height: number,
	Font: Font,
	TextSize: number,
	Color: Color3,
	LayoutOrder: number?,
}

function Roll.label(scope: Types.Scope, props: Props): Instance
	local theme = props.Theme
	local height = props.Height
	local shown = scope:Value(peek(props.Text))
	local leaving = scope:Value("")
	local direction = scope:Value(1)
	local goal = scope:Value(1)
	local progress = Motion.spring(scope, goal, theme, "Smooth")
	local lastOrder = peek(props.Order) :: number

	table.insert(
		scope,
		scope:Observer(props.Text):onChange(function()
			local order = peek(props.Order) :: number
			leaving:set(peek(shown))
			shown:set(peek(props.Text))
			direction:set(if order >= lastOrder then 1 else -1)
			lastOrder = order
			-- Start again from the beginning, then go to the end.
			goal:set(0)
			progress:setPosition(0)
			goal:set(1)
		end)
	)

	-- `blur` is 0 when the text is in place and 1 when it has gone.
	local function label(
		text: any,
		offset: any,
		transparency: any,
		blur: any,
		name: string
	): Instance
		return scope:TextLabel({
			Name = name,
			BackgroundTransparency = 1,
			FontFace = props.Font,
			TextSize = props.TextSize,
			TextColor3 = props.Color,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = text,
			TextTransparency = transparency,
			Size = UDim2.new(1, 0, 0, height),
			Position = scope:Computed(function(use)
				return UDim2.fromOffset(0, use(offset))
			end),
			[Children] = { TextBlur.shadow(scope, props.TextSize, props.Color, blur) },
		})
	end

	return scope:Frame({
		Name = "Roll",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Size = UDim2.fromOffset(0, height),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = props.LayoutOrder or 0,
		[Children] = {
			-- Sets the width, and is not seen.
			scope:TextLabel({
				Name = "Width",
				BackgroundTransparency = 1,
				FontFace = props.Font,
				TextSize = props.TextSize,
				Text = shown,
				TextTransparency = 1,
				Size = UDim2.fromOffset(0, height),
				AutomaticSize = Enum.AutomaticSize.X,
			}),
			label(
				leaving,
				scope:Computed(function(use)
					return -use(direction) * use(progress) * height
				end),
				scope:Computed(function(use)
					return math.clamp(use(progress) :: number, 0, 1)
				end),
				scope:Computed(function(use)
					return math.clamp(use(progress) :: number, 0, 1)
				end),
				"Leaving"
			),
			label(
				shown,
				scope:Computed(function(use)
					return use(direction) * (1 - use(progress)) * height
				end),
				scope:Computed(function(use)
					return 1 - math.clamp(use(progress) :: number, 0, 1)
				end),
				scope:Computed(function(use)
					return 1 - math.clamp(use(progress) :: number, 0, 1)
				end),
				"Shown"
			),
		},
	})
end

return Roll
