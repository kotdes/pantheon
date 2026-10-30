--!strict
local Fusion = require(script.Parent.Parent.Parent.Fusion)
local Types = require(script.Parent.Parent.Types)
local Motion = require(script.Parent.Motion)
local Presence = require(script.Parent.Presence)

local Children = Fusion.Children
local peek = Fusion.peek

--[[
	A panel that flows out of the control that opened it: a shape that starts as the control, with
	its position, size, colour and corners, and becomes the panel. Every part has a spring of its
	own, so the shape stretches and wobbles like a liquid and does not just scale.

	The shape draws the fill and the shadows. The group inside it clips the panel to the rounded
	corners, and would clip shadows too, so the shadows cannot be on the group.

	  local morph = Morph.create(scope, { Theme, Open, Content = panel, ZIndex })
	  -- when the panel has been placed:
	  morph.measure(from, layer, atInLayer, panelSize)
	  -- put `morph.Instance` in the layer, and use `morph.Presence` for the scrim and `Visible`.

	`from` is the element the shape grows out of. Components take it from their `MorphTarget`
	prop, and use their `Target` when that is not set.
]]
local Morph = {}

--- The springs of a morph. The width leads and wobbles, the height follows and stretches, and
--- the position takes a curved path because x and y move at different speeds.
export type Springs = {
	Presence: Presence.Result,
	X: any,
	Y: any,
	Width: any,
	Height: any,
	Shape: any,
	--- 0 at the two ends of the movement and 1 in the middle of it, as a stand-in for blur.
	Speed: any,
}

--- Where a morph starts: the position, size, corners and colour of the element it grows out of.
export type Origin = {
	Position: Vector2,
	Size: Vector2,
	Radius: number,
	Color: Color3?,
}

export type Morph = {
	Instance: Instance,
	Presence: Presence.Result,
	--- Tells the shape where it starts and where it ends. Call it whenever the panel is placed.
	measure: (from: GuiObject, layer: GuiObject, at: Vector2, size: Vector2) -> (),
}

type Props = {
	Theme: Types.Theme,
	Open: any,
	Content: GuiObject,
	ZIndex: number,
}

function Morph.mix(from: number, to: number, t: number): number
	return from + (to - from) * t
end

function Morph.springs(scope: Types.Scope, theme: Types.Theme, open: any): Springs
	-- The height is the slowest part, so the shape stays until it has finished closing.
	local presence = Presence.create(scope, open, theme, "LiquidHeight")
	local goal = scope:Computed(function(use)
		return if use(open) then 1 else 0
	end)
	local height = presence.Progress
	return {
		Presence = presence,
		X = Motion.spring(scope, goal, theme, "LiquidMove"),
		Y = Motion.spring(scope, goal, theme, "LiquidMove", 0.82),
		Width = Motion.spring(scope, goal, theme, "LiquidWidth"),
		Height = height,
		Shape = Motion.spring(scope, goal, theme, "LiquidShape"),
		Speed = scope:Computed(function(use)
			local t = math.clamp(use(height) :: number, 0, 1)
			return 4 * t * (1 - t)
		end),
	}
end

--- The position, size, corners and colour of `from`, with the position in the space of `base`.
function Morph.originOf(from: GuiObject, base: GuiObject): Origin
	local corner = from:FindFirstChildOfClass("UICorner")
	return {
		Position = from.AbsolutePosition - base.AbsolutePosition,
		Size = from.AbsoluteSize,
		Radius = if corner
			then math.min(corner.CornerRadius.Offset, from.AbsoluteSize.Y / 2)
			else 0,
		Color = if from.BackgroundTransparency < 1 then from.BackgroundColor3 else nil,
	}
end

local mix = Morph.mix

function Morph.create(scope: Types.Scope, props: Props): Morph
	local theme = props.Theme
	local fromPos = scope:Value(Vector2.zero)
	local fromSize = scope:Value(Vector2.zero)
	local fromRadius = scope:Value(0)
	-- A colour in the theme can be a state when the theme is reactive, so the value is read here.
	local fromColor = scope:Value(peek(theme.Colors.Surface))
	local toPos = scope:Value(Vector2.zero)
	local toSize = scope:Value(Vector2.zero)
	local toRadius = scope:Value(theme.Metrics.RadiusPanel)

	local springs = Morph.springs(scope, theme, props.Open)
	local moveX, moveY, grow, rise = springs.X, springs.Y, springs.Width, springs.Height
	local shape, speed = springs.Shape, springs.Speed

	local radius = scope:Computed(function(use)
		local t = math.clamp(use(shape) :: number, 0, 1)
		return UDim.new(0, mix(use(fromRadius) :: number, use(toRadius) :: number, t))
	end)
	local colour = scope:Computed(function(use)
		local t = math.clamp(use(shape) :: number, 0, 1)
		return (use(fromColor) :: Color3):Lerp(use(theme.Colors.Surface), t)
	end)
	-- The halo is the shape's colour pulled towards the ink, so it can be seen on a background
	-- that is close to the shape's own colour.
	local haze = scope:Computed(function(use)
		return (use(colour) :: Color3):Lerp(use(theme.Colors.OnSurface), 0.45)
	end)

	local shell = scope:Frame({
		Name = "Morph",
		BorderSizePixel = 0,
		BackgroundColor3 = colour,
		Position = scope:Computed(function(use)
			local a, b = use(fromPos) :: Vector2, use(toPos) :: Vector2
			return UDim2.fromOffset(
				mix(a.X, b.X, use(moveX) :: number),
				mix(a.Y, b.Y, use(moveY) :: number)
			)
		end),
		Size = scope:Computed(function(use)
			local a, b = use(fromSize) :: Vector2, use(toSize) :: Vector2
			return UDim2.fromOffset(
				math.max(mix(a.X, b.X, use(grow) :: number), 0),
				math.max(mix(a.Y, b.Y, use(rise) :: number), 0)
			)
		end),
		ZIndex = props.ZIndex,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = radius }),
			-- Depth.
			scope:New("UIShadow")({
				BlurRadius = UDim.new(0, 16),
				Color = Color3.new(0, 0, 0),
				Offset = UDim2.fromOffset(0, 6),
				Transparency = scope:Computed(function(use)
					return 1 - 0.16 * math.clamp(use(shape) :: number, 0, 1)
				end),
				ZIndex = -2,
			}),
			-- Blur. A wide soft edge that is strongest while the shape moves, so the shape looks
			-- smeared when it is fast and sharp when it has settled.
			scope:New("UIShadow")({
				BlurRadius = scope:Computed(function(use)
					return UDim.new(0, 6 + 36 * use(speed))
				end),
				Color = haze,
				Offset = UDim2.new(),
				Spread = scope:Computed(function(use)
					local grown = 10 * use(speed)
					return UDim2.fromOffset(grown, grown)
				end),
				Transparency = scope:Computed(function(use)
					return 1 - 0.6 * use(speed)
				end),
				ZIndex = -1,
			}),
			scope:New("CanvasGroup")({
				Name = "Clip",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				[Children] = {
					scope:New("UICorner")({ CornerRadius = radius }),
					props.Content,
				},
			}),
		},
	})

	local function measure(from: GuiObject, layer: GuiObject, at: Vector2, size: Vector2)
		local origin = Morph.originOf(from, layer)
		fromPos:set(origin.Position)
		fromSize:set(origin.Size)
		fromRadius:set(origin.Radius)
		fromColor:set(origin.Color or peek(theme.Colors.Surface))
		toPos:set(at)
		toSize:set(size)
		local to = props.Content:FindFirstChildOfClass("UICorner")
		if to and to.CornerRadius.Offset > 0 then
			toRadius:set(to.CornerRadius.Offset)
		end
	end

	return { Instance = shell, Presence = springs.Presence, measure = measure }
end

return Morph
