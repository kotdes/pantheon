--!strict
--[[
	Kind "M3Morph" of LoadingIndicator: shape-morphing loading indicator (Material 3 Expressive).

	A solid shape spins while it morphs through a cycle of shapes. Roblox UI has no
	polygon primitive, so every shape is a polygon rasterised into horizontal
	strips (two spans per strip, so concave notches and lobes survive). Morphing
	interpolates each strip's span edges; strips share one colour so they read as a
	single silhouette, and the whole stack rotates as one.

	Shapes (pass names via `Shapes`, default is the Material 3 sequence):
	  Oval, Pill, Triangle, Arrow, Fan, Diamond, Clamshell, Pentagon, Gem,
	  Sunny, VerySunny, SoftBurst, Cookie4, Cookie6, Cookie7, Cookie9, Cookie12,
	  Burst
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme

local Children = Fusion.Children
local peek = Fusion.peek
local RunService = game:GetService("RunService")

type Point = { x: number, y: number }
type Polygon = { Point }
--- Per strip: x0, x1 (first span) and x2, x3 (second span), in box units (-0.5..0.5).
type Row = { number }

-- Strips have rounded (anti-aliased) ends. They're spaced on a grid that bunches
-- toward the top and bottom, where an outline runs nearly flat and a uniform grid
-- would leave big sideways steps between rows.
local STRIP_PITCH = 0.9 -- px, roughly, at the middle of the shape
local MIN_STRIPS, MAX_STRIPS = 24, 64
local GRID_BUNCH = 0.7 -- 0 = uniform rows, 1 = fully cosine-spaced
local STRIP_OVERLAP = 2.0
local MIN_STRIP_PX = 1.3
local PERIOD = 0.7 -- seconds per shape
local MORPH = 0.5 -- fraction of the period spent morphing (rest is a hold)
local SPIN = 120 -- degrees per second
local TARGET_AREA = math.pi * 0.36 * 0.36
local DEFAULT_SEQUENCE = { "SoftBurst", "Cookie9", "Pentagon", "Pill", "Sunny", "Cookie4", "Oval" }

-- Polygon builders
local function polar(samples: number, radius: (theta: number) -> number): Polygon
	local pts: Polygon = {}
	for i = 0, samples - 1 do
		local theta = i / samples * math.pi * 2
		local r = radius(theta)
		-- theta 0 = 12 o'clock, clockwise (y points down)
		table.insert(pts, { x = math.sin(theta) * r, y = -math.cos(theta) * r })
	end
	return pts
end

local function regular(n: number, radius: number, rotationDeg: number?): Polygon
	local rot = math.rad(rotationDeg or 0)
	local pts: Polygon = {}
	for i = 0, n - 1 do
		local theta = rot + i / n * math.pi * 2
		table.insert(pts, { x = math.sin(theta) * radius, y = -math.cos(theta) * radius })
	end
	return pts
end

local function poly(coords: { number }): Polygon
	local pts: Polygon = {}
	for i = 1, #coords, 2 do
		table.insert(pts, { x = coords[i], y = coords[i + 1] })
	end
	return pts
end

--- Chaikin corner cutting: rounds a polygon's corners.
local function round(pts: Polygon, iterations: number): Polygon
	for _ = 1, iterations do
		local out: Polygon = {}
		for i = 1, #pts do
			local a, b = pts[i], pts[i % #pts + 1]
			table.insert(out, { x = a.x * 0.75 + b.x * 0.25, y = a.y * 0.75 + b.y * 0.25 })
			table.insert(out, { x = a.x * 0.25 + b.x * 0.75, y = a.y * 0.25 + b.y * 0.75 })
		end
		pts = out
	end
	return pts
end

local function ellipse(a: number, b: number, rotationDeg: number, exponent: number?): Polygon
	local rot = math.rad(rotationDeg)
	local e = exponent or 2
	local pts: Polygon = {}
	local samples = 72
	for i = 0, samples - 1 do
		local t = i / samples * math.pi * 2
		local c, s = math.cos(t), math.sin(t)
		-- superellipse: |x/a|^e + |y/b|^e = 1
		local x = a * math.sign(c) * math.abs(c) ^ (2 / e)
		local y = b * math.sign(s) * math.abs(s) ^ (2 / e)
		table.insert(pts, {
			x = x * math.cos(rot) - y * math.sin(rot),
			y = x * math.sin(rot) + y * math.cos(rot),
		})
	end
	return pts
end

local function fract(x: number): number
	return x - math.floor(x)
end

--- Recentre on the bounding box and scale to a common visual weight (and within the box).
local function normalise(pts: Polygon): Polygon
	local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
	for _, p in pts do
		minX, maxX = math.min(minX, p.x), math.max(maxX, p.x)
		minY, maxY = math.min(minY, p.y), math.max(maxY, p.y)
	end
	local cx, cy = (minX + maxX) / 2, (minY + maxY) / 2
	local area = 0
	for i = 1, #pts do
		local a, b = pts[i], pts[i % #pts + 1]
		area += a.x * b.y - b.x * a.y
	end
	area = math.abs(area) / 2
	local maxR = 0
	for _, p in pts do
		maxR = math.max(maxR, math.sqrt((p.x - cx) ^ 2 + (p.y - cy) ^ 2))
	end
	local s = math.min(math.sqrt(TARGET_AREA / math.max(area, 1e-6)), 0.5 / math.max(maxR, 1e-6))
	local out: Polygon = {}
	for _, p in pts do
		table.insert(out, { x = (p.x - cx) * s, y = (p.y - cy) * s })
	end
	return out
end

local BUILDERS: { [string]: () -> Polygon } = {
	Oval = function()
		return ellipse(0.5, 0.33, 40)
	end,
	Pill = function()
		return ellipse(0.48, 0.4, 30, 2.7)
	end,
	Triangle = function()
		return round(poly({ 0, -0.5, 0.5, 0.4, -0.5, 0.4 }), 3)
	end,
	Arrow = function()
		return round(poly({ 0, -0.5, 0.46, 0.42, 0, 0.16, -0.46, 0.42 }), 3)
	end,
	Fan = function()
		local pts: Polygon = { { x = -0.42, y = -0.42 } }
		for i = 0, 18 do
			local t = math.rad(i / 18 * 90)
			table.insert(pts, { x = -0.42 + 0.86 * math.cos(t), y = -0.42 + 0.86 * math.sin(t) })
		end
		return round(pts, 2)
	end,
	Diamond = function()
		return round(poly({ 0, -0.5, 0.38, 0, 0, 0.5, -0.38, 0 }), 3)
	end,
	Clamshell = function()
		return round(
			poly({ -0.5, 0, -0.28, -0.32, 0.28, -0.32, 0.5, 0, 0.28, 0.32, -0.28, 0.32 }),
			3
		)
	end,
	Pentagon = function()
		return round(regular(5, 0.5, 0), 3)
	end,
	Gem = function()
		return round(regular(6, 0.5, 15), 3)
	end,
	-- Scalloped bumps with sharp notches between them.
	Sunny = function()
		return polar(160, function(theta)
			return 0.3 + 0.2 * math.abs(math.cos(theta * 4))
		end)
	end,
	VerySunny = function()
		return polar(200, function(theta)
			return 0.28 + 0.22 * math.abs(math.cos(theta * 5))
		end)
	end,
	SoftBurst = function()
		return polar(160, function(theta)
			return 0.4 + 0.07 * math.cos(theta * 10)
		end)
	end,
	Cookie4 = function()
		return polar(120, function(theta)
			return 0.38 + 0.1 * math.cos(theta * 4)
		end)
	end,
	Cookie6 = function()
		return polar(120, function(theta)
			return 0.4 + 0.06 * math.cos(theta * 6)
		end)
	end,
	Cookie7 = function()
		return polar(140, function(theta)
			return 0.4 + 0.055 * math.cos(theta * 7)
		end)
	end,
	Cookie9 = function()
		return polar(180, function(theta)
			return 0.41 + 0.045 * math.cos(theta * 9)
		end)
	end,
	Cookie12 = function()
		return polar(240, function(theta)
			return 0.42 + 0.035 * math.cos(theta * 12)
		end)
	end,
	-- Spiky star: zig-zag radius.
	Burst = function()
		return polar(240, function(theta)
			local t = fract(theta / (math.pi * 2) * 12)
			return 0.3 + 0.2 * (1 - math.abs(2 * t - 1))
		end)
	end,
}

--- Scan a polygon with horizontal lines; returns up to two spans per strip.
--- Row centres (box units, -0.5..0.5) and heights for a bunched strip grid.
local function stripGrid(strips: number): ({ number }, { number })
	local ys: { number } = {}
	for k = 1, strips do
		local t = (k - 0.5) / strips
		ys[k] = (t - 0.5) * (1 - GRID_BUNCH) + -0.5 * math.cos(math.pi * t) * GRID_BUNCH
	end
	local hs: { number } = {}
	for k = 1, strips do
		local above = ys[k - 1] or (ys[k] - (ys[k + 1] - ys[k]))
		local below = ys[k + 1] or (ys[k] + (ys[k] - ys[k - 1]))
		hs[k] = (below - above) / 2 * STRIP_OVERLAP
	end
	return ys, hs
end

local function rasterise(pts: Polygon, ys: { number }): { Row }
	local rows: { Row } = {}
	for k = 1, #ys do
		local y = ys[k]
		local xs: { number } = {}
		for i = 1, #pts do
			local a, b = pts[i], pts[i % #pts + 1]
			if (a.y <= y and b.y > y) or (b.y <= y and a.y > y) then
				table.insert(xs, a.x + (y - a.y) / (b.y - a.y) * (b.x - a.x))
			end
		end
		table.sort(xs)
		local row: Row
		if #xs < 2 then
			row = { 0, 0, 0, 0 }
		elseif #xs < 4 then
			local mid = (xs[1] + xs[2]) / 2
			row = { xs[1], xs[2], mid, mid }
		else
			-- First span, then everything else merged into the second span.
			row = { xs[1], xs[2], xs[3], xs[#xs] }
		end
		table.insert(rows, row)
	end
	return rows
end

local compiled: { [string]: { Row } } = {}
local function shapeRows(name: string, strips: number): { Row }
	local key = `{name}:{strips}`
	local cached = compiled[key]
	if cached then
		return cached
	end
	local build = BUILDERS[name] or BUILDERS.Oval
	local rows = rasterise(normalise(build()), (stripGrid(strips)))
	compiled[key] = rows
	return rows
end

-- Motion
-- Ease with a small overshoot.
local function easeOutBack(t: number): number
	local c1 = 1.2
	local c3 = c1 + 1
	local x = t - 1
	return 1 + c3 * x * x * x + c1 * x * x
end

--- Fractional shape index: whole part = shape, fraction = morph progress.
local function shapeIndex(t: number): number
	local k = math.floor(t / PERIOD)
	local u = t / PERIOD - k
	return k + easeOutBack(math.clamp(u / MORPH, 0, 1))
end

return function(scope: Types.Scope, props: Types.LoadingIndicatorProps): Frame
	local theme = resolveTheme(props)
	local diameter = props.SizePx or 48
	local contained = props.Contained == true
	-- Contained: shape sits inside a round container, like the M3 spec (38 in 48).
	local box = if contained then diameter * 0.66 else diameter

	local strips = math.clamp(math.floor(box / STRIP_PITCH), MIN_STRIPS, MAX_STRIPS)
	local sequence: { { Row } } = {}
	local shapes: { string } = props.Shapes or DEFAULT_SEQUENCE
	for _, name in shapes do
		table.insert(sequence, shapeRows(name, strips))
	end
	if #sequence == 0 then
		table.insert(sequence, shapeRows("Oval", strips))
	end
	local count = #sequence

	local clock = scope:Value(0)
	table.insert(
		scope,
		RunService.RenderStepped:Connect(function(dt: number)
			clock:set(peek(clock) + dt)
		end)
	)

	-- Equal values don't propagate, so strips are only rewritten while morphing.
	local index = scope:Computed(function(use)
		return shapeIndex(use(clock))
	end)

	local shapeColor = if contained then theme.Colors.OnPrimaryContainer else theme.Colors.Primary
	-- Overlapping, fully rounded strips: the ends are anti-aliased, which smooths the
	-- staircase a hard-edged rectangle would leave (especially once rotated).
	local ys, hs = stripGrid(strips)
	for k = 1, strips do
		hs[k] = math.max(hs[k], MIN_STRIP_PX / box)
	end

	-- A row only needs a second span if some shape in the cycle has two on that row.
	local needsSecond: { boolean } = {}
	for k = 1, strips do
		for _, rows in sequence do
			local r = rows[k]
			if r[4] - r[3] > 0.002 and r[3] - r[2] > 0.002 then
				needsSecond[k] = true
			end
		end
	end

	local frames: { { Frame? } } = {}
	local kids: { any } = {}
	for k = 1, strips do
		local pair: { Frame? } = {}
		for span = 1, if needsSecond[k] then 2 else 1 do
			local f = scope:New("Frame")({
				Name = `Strip{k}_{span}`,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = shapeColor,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0, hs[k]),
				Position = UDim2.fromScale(0.5, 0.5 + ys[k]),
				[Children] = { scope:New("UICorner")({ CornerRadius = UDim.new(0.5, 0) }) },
			}) :: Frame
			pair[span] = f
			table.insert(kids, f)
		end
		frames[k] = pair
	end

	local function update(i: number)
		local base = math.floor(i)
		local t = i - base
		local a = sequence[base % count + 1]
		local b = sequence[(base + 1) % count + 1]
		for k = 1, strips do
			local ra, rb = a[k], b[k]
			local y = 0.5 + ys[k]
			local height = hs[k]
			for span = 1, if needsSecond[k] then 2 else 1 do
				local o = span * 2 - 1
				local x0 = ra[o] + (rb[o] - ra[o]) * t
				local x1 = ra[o + 1] + (rb[o + 1] - ra[o + 1]) * t
				local f = frames[k][span] :: Frame
				-- Rounded ends eat ~half a strip height each side; widen to compensate.
				local w = x1 - x0
				f.Size = UDim2.fromScale(if w > 0.0005 then w + height * 0.5 else 0, height)
				f.Position = UDim2.fromScale(0.5 + (x0 + x1) / 2, y)
			end
		end
	end
	update(peek(index))
	table.insert(
		scope,
		scope:Observer(index):onChange(function()
			update(peek(index))
		end)
	)

	local shape = scope:New("Frame")({
		Name = "Shape",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(box, box),
		BackgroundTransparency = 1,
		Rotation = scope:Computed(function(use)
			return ((use(clock) :: number) * SPIN) % 360
		end),
		[Children] = kids,
	})

	return scope:New("Frame")({
		Name = "LoadingIndicator",
		Size = props.Size or UDim2.fromOffset(diameter, diameter),
		BackgroundColor3 = theme.Colors.PrimaryContainer,
		BackgroundTransparency = if contained then 0 else 1,
		BorderSizePixel = 0,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
			shape,
		},
	}) :: Frame
end
