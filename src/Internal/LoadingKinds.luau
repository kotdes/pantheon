--!strict
--[[
	The non-Material kinds of LoadingIndicator (picked by its `Kind`).

	  Beachball  macOS-style spinning rainbow pinwheel
	  Dots       three bouncing dots (typing / "thinking")
	  Bars       equalizer bars
	  Ripple     rings expanding from a centre dot
	  Orbit      dots chasing each other round a circle
	  Gnome      thin ring with a small dot (and fading trail) circling it
	  Icon       any Lucide icon with a motion preset (Spin, Pulse, Bounce, Flip, Wiggle)

	All kinds are square (`SizePx`, default 32) so they drop into the same layouts.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Arc = require(script.Parent.Parent.Internal.Arc)
local Icon = require(script.Parent.Parent.Components.Icon)
local Features = require(script.Parent.Parent.Internal.Features)
local Flags = require(script.Parent.Parent.Internal.Flags)

local Children = Fusion.Children
local peek = Fusion.peek
local RunService = game:GetService("RunService")

local TAU = math.pi * 2

local BEACHBALL_COLORS = {
	Color3.fromRGB(255, 59, 48), -- red
	Color3.fromRGB(255, 149, 0), -- orange
	Color3.fromRGB(255, 204, 0), -- yellow
	Color3.fromRGB(52, 199, 89), -- green
	Color3.fromRGB(90, 200, 250), -- cyan
	Color3.fromRGB(0, 122, 255), -- blue
	Color3.fromRGB(175, 82, 222), -- purple
	Color3.fromRGB(255, 45, 85), -- pink
}

local function fract(x: number): number
	return x - math.floor(x)
end

local function circleDot(scope: Types.Scope, name: string, color: Color3, size: number): Frame
	return scope:New("Frame")({
		Name = name,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		[Children] = { scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }) },
	}) :: Frame
end

local function onCircle(radius: number, angle: number): UDim2
	return UDim2.fromScale(0.5 + radius * math.sin(angle), 0.5 - radius * math.cos(angle))
end

-- Each builder returns (children, update(t)); `update` writes properties directly,
-- which is cheaper than a computed per property for a handful of frames.
type Built = { children: { any }, update: ((t: number) -> ())? }

local function dots(scope: Types.Scope, px: number, color: Color3): Built
	local items: { Frame } = {}
	local d = px * 0.2
	for i = 1, 3 do
		local f = circleDot(scope, `Dot{i}`, color, d)
		f.Position = UDim2.fromScale(0.5 + (i - 2) * 0.3, 0.5)
		items[i] = f
	end
	return {
		children = items,
		update = function(t)
			for i, f in items do
				local wave = 0.5 - 0.5 * math.cos(TAU * fract(t / 0.9 - (i - 1) * 0.16))
				local size = d * (0.8 + 0.3 * wave)
				f.Size = UDim2.fromOffset(size, size)
				f.Position = UDim2.new(0.5 + (i - 2) * 0.3, 0, 0.5, -wave * px * 0.2)
				f.BackgroundTransparency = 0.5 * (1 - wave)
			end
		end,
	}
end

local function bars(scope: Types.Scope, px: number, color: Color3): Built
	local items: { Frame } = {}
	local speeds = { 1.1, 1.7, 1.3, 1.9, 1.5 }
	local offsets = { 0, 1.2, 2.1, 0.6, 1.8 }
	for i = 1, 5 do
		items[i] = scope:New("Frame")({
			Name = `Bar{i}`,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5 + (i - 3) * 0.17, 0.5),
			Size = UDim2.new(0, math.max(px * 0.1, 2), 0.3, 0),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			[Children] = { scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }) },
		}) :: Frame
	end
	return {
		children = items,
		update = function(t)
			for i, f in items do
				local wave = 0.5 + 0.5 * math.sin(TAU * speeds[i] * t * 0.6 + offsets[i] * 2)
				f.Size = UDim2.new(0, math.max(px * 0.1, 2), 0.25 + 0.7 * wave, 0)
			end
		end,
	}
end

local function ripple(scope: Types.Scope, px: number, color: Color3): Built
	local rings: { Frame } = {}
	local strokes: { UIStroke } = {}
	for i = 1, 2 do
		local stroke = scope:New("UIStroke")({
			Color = color,
			Thickness = math.max(px * 0.06, 1.5),
			Transparency = 1,
		}) :: UIStroke
		strokes[i] = stroke
		rings[i] = scope:New("Frame")({
			Name = `Ring{i}`,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.15, 0.15),
			BackgroundTransparency = 1,
			[Children] = { scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }), stroke },
		}) :: Frame
	end
	local center = circleDot(scope, "Center", color, px * 0.14)
	local kids: { any } = { center }
	for _, r in rings do
		table.insert(kids, r)
	end
	return {
		children = kids,
		update = function(t)
			for i, ring in rings do
				local u = fract(t / 1.6 + (i - 1) / 2)
				local eased = 1 - (1 - u) ^ 2
				local s = 0.15 + 0.8 * eased
				ring.Size = UDim2.fromScale(s, s)
				strokes[i].Transparency = u ^ 0.8
			end
		end,
	}
end

local function orbit(scope: Types.Scope, px: number, color: Color3): Built
	local items: { Frame } = {}
	for i = 1, 3 do
		items[i] = circleDot(scope, `Dot{i}`, color, px * 0.2 * (1 - 0.2 * (i - 1)))
	end
	return {
		children = items,
		update = function(t)
			local u = fract(t / 1.3)
			-- Ease so the leader surges and the others catch up each lap.
			local lead = u + 0.14 * math.sin(TAU * u)
			for i, f in items do
				f.Position = onCircle(0.36, TAU * lead - (i - 1) * 0.5)
			end
		end,
	}
end

local function gnome(scope: Types.Scope, px: number, color: Color3): Built
	local thickness = math.max(px * 0.07, 1.5)
	local ring = scope:New("Frame")({
		Name = "Track",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.86, 0, 0.86, 0),
		BackgroundTransparency = 1,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
			scope:New("UIStroke")({ Color = color, Thickness = thickness, Transparency = 0.8 }),
		},
	}) :: Frame
	local trail: { Frame } = {}
	local kids: { any } = { ring }
	for i = 1, 6 do
		local f = circleDot(scope, `Dot{i}`, color, px * (0.2 - 0.022 * (i - 1)))
		trail[i] = f
		table.insert(kids, f)
	end
	return {
		children = kids,
		update = function(t)
			local lead = TAU * fract(t / 1.0)
			for i, f in trail do
				f.Position = onCircle(0.46, lead - (i - 1) * 0.22)
				f.BackgroundTransparency = (i - 1) / 7
			end
		end,
	}
end

local function iconLoader(
	scope: Types.Scope,
	px: number,
	color: Color3,
	props: Types.LoadingIndicatorProps
): Built
	local icon = Icon(scope, {
		Theme = props.Theme,
		Name = props.Icon or "loader",
		IconSize = px,
		Color = color,
	}) :: ImageLabel
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	local motion = props.Motion or "Spin"
	return {
		children = { icon },
		update = function(t)
			if motion == "Spin" then
				icon.Rotation = (t * 360 / 1.0) % 360
			elseif motion == "Pulse" then
				local wave = 0.5 - 0.5 * math.cos(TAU * t / 1.2)
				icon.Size = UDim2.fromOffset(px * (0.8 + 0.2 * wave), px * (0.8 + 0.2 * wave))
				icon.ImageTransparency = 0.55 * (1 - wave)
			elseif motion == "Bounce" then
				local u = fract(t / 0.8)
				icon.Position = UDim2.new(0.5, 0, 0.5, -math.sin(u * math.pi) * px * 0.25)
			elseif motion == "Flip" then
				-- Half-turn with a hold, like an hourglass flipping over.
				local u = fract(t / 1.6)
				local turn = math.clamp((u - 0.1) / 0.5, 0, 1)
				local eased = turn * turn * (3 - 2 * turn)
				icon.Rotation = (math.floor(t / 1.6) * 180 + eased * 180) % 360
			else -- Wiggle
				local u = fract(t / 1.4)
				local envelope = math.max(0, 1 - u * 1.6)
				icon.Rotation = 18 * envelope * math.sin(TAU * 3 * u)
			end
		end,
	}
end

--- Conical gradient: the whole ball is one disc whose Rotation spins the 8 wedges.
local function conicalBeachball(scope: Types.Scope, px: number, clock: any): Built
	local keys: { ColorSequenceKeypoint } = {}
	local count = #BEACHBALL_COLORS
	local eps = 1e-4
	for i, c in BEACHBALL_COLORS do
		local a, b = (i - 1) / count, i / count
		table.insert(keys, ColorSequenceKeypoint.new(if i == 1 then 0 else a + eps, c))
		table.insert(keys, ColorSequenceKeypoint.new(if i == count then 1 else b, c))
	end
	local disc = scope:New("Frame")({
		Name = "Ball",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(px, px),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
			scope:New("UIGradient")({
				Type = "Conical",
				Color = ColorSequence.new(keys),
				Rotation = scope:Computed(function(use)
					return Flags.ConicalRotation
						+ (if Flags.ConicalClockwise then 1 else -1)
							* (((use(clock) :: number) * 360 / 1.1) % 360)
				end),
			}),
		},
	}) :: Frame
	return { children = { disc }, update = nil }
end

local function beachball(scope: Types.Scope, px: number, clock: any): Built
	if Features.gradientTypes() then
		return conicalBeachball(scope, px, clock)
	end
	-- Wedge i spans [theta + 45i, theta + 45(i+1)). Painting "fill from angle to 12
	-- o'clock" discs in ascending order, each over the last, leaves exactly those
	-- wedges. theta splits into a whole-wedge colour shift and a 0..45° offset, so
	-- paint order stays fixed while the ball spins.
	local degrees = scope:Computed(function(use)
		return ((use(clock) :: number) * 360 / 1.1) % 360
	end)
	local offset = scope:Computed(function(use)
		return (use(degrees) :: number) % 45
	end)
	local shift = scope:Computed(function(use)
		return math.floor((use(degrees) :: number) / 45) % 8
	end)
	local radius = px / 2 - 1

	local function disc(name: string, color: any, angle: any, z: number)
		return Arc(scope, {
			Name = name,
			Mode = "Tail" :: "Tail",
			Diameter = px,
			Thickness = radius,
			Color = color,
			Angle = angle,
			ZIndex = z,
		})
	end

	local layers: { any } = {
		disc(
			"Base",
			scope:Computed(function(use)
				return BEACHBALL_COLORS[(-1 - (use(shift) :: number)) % 8 + 1]
			end),
			0,
			1
		),
	}
	for j = 0, 7 do
		table.insert(
			layers,
			disc(
				`Wedge{j}`,
				scope:Computed(function(use)
					return BEACHBALL_COLORS[(j - (use(shift) :: number)) % 8 + 1]
				end),
				scope:Computed(function(use)
					return (use(offset) :: number) + 45 * j
				end),
				j + 2
			)
		)
	end
	return { children = layers, update = nil }
end

return function(scope: Types.Scope, props: Types.LoadingIndicatorProps): Frame
	local theme = resolveTheme(props)
	local px = props.SizePx or 32
	local kind = props.Kind or "Dots"
	local color = props.Color or theme.Colors.Primary

	local clock = scope:Value(0)
	local built: Built
	if kind == "Beachball" then
		built = beachball(scope, px, clock)
	elseif kind == "Bars" then
		built = bars(scope, px, color)
	elseif kind == "Ripple" then
		built = ripple(scope, px, color)
	elseif kind == "Orbit" then
		built = orbit(scope, px, color)
	elseif kind == "Gnome" then
		built = gnome(scope, px, color)
	elseif kind == "Icon" then
		built = iconLoader(scope, px, color, props)
	else
		built = dots(scope, px, color)
	end

	local update = built.update
	table.insert(
		scope,
		RunService.RenderStepped:Connect(function(dt: number)
			local t = peek(clock) + dt
			clock:set(t)
			if update then
				update(t)
			end
		end)
	)
	if update then
		update(0)
	end

	local content: any = built.children
	if kind == "Beachball" then
		-- Arc layers are fixed-pixel squares; centre them in the (possibly larger) box.
		content = {
			scope:New("Frame")({
				Name = "Center",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(px, px),
				BackgroundTransparency = 1,
				[Children] = built.children,
			}),
		}
	end

	return scope:New("Frame")({
		Name = `LoadingIndicator{kind}`,
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.fromOffset(px, px),
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		[Children] = content,
	}) :: Frame
end
