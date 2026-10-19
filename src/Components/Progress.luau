--!strict
--[[
	Linear / circular progress.
	Indeterminate linear: ping-pong bounce with mid-travel stretch.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Arc = require(script.Parent.Parent.Internal.Arc)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local LoadingMorph = require(script.Parent.Parent.Internal.LoadingMorph)

local Children = Fusion.Children
local peek = Fusion.peek
local RunService = game:GetService("RunService")

local function clamp01(x: number): number
	return math.clamp(x, 0, 1)
end

local function smooth(t: number): number
	t = clamp01(t)
	return t * t * t * (t * (t * 6 - 15) + 10)
end

--[[
	macOS-style bounce, timed from a frame-by-frame measurement of the real thing.
	One pass (left→right, then right→left) takes HALF seconds and moves like a snake:
	the head sprints across first, the tail starts a beat later and catches up
	(both ease out), then the pill rests collapsed at the end before turning back.
	Returns (left, right, rightward) as fractions of the track.
]]
local HALF = 0.77
local HEAD_DUR = 0.66
local TAIL_DELAY = 0.144
local TAIL_DUR = 0.516 -- tail lands exactly as the head does, so the pill collapses on arrival
local FADE = 0.25 -- trailing fade length, as a fraction of the track
local DEFAULT_BAR_HEIGHT = 4

-- Head: fast start with a strong ease-out.
local function easeHead(u: number): number
	return 1 - (1 - clamp01(u)) ^ 3
end

-- Tail: lags behind, then eases in-out. Together the pill stretches and then snaps shut.
local function easeTail(u: number): number
	u = clamp01(u)
	if u < 0.5 then
		return 4 * u * u * u
	end
	return 1 - (-2 * u + 2) ^ 3 / 2
end

--- (a, b) are the pill's edges in 0..1 "travel space"; a == b means collapsed. The pill is
--- always at least one bar-height wide (a circle), so travel space is the track minus that.
local function bounceGeometry(phase: number): (number, number, boolean)
	local cycle = phase * 2 -- 0..2
	local rightward = cycle % 2 < 1
	local tau = (cycle % 1) * HALF
	local head = easeHead(tau / HEAD_DUR)
	local tail = easeTail((tau - TAIL_DELAY) / TAIL_DUR)
	if rightward then
		return tail, head, true
	end
	return 1 - head, 1 - tail, false
end

--- Trailing fade, in the pill's own 0..1 space; short pills stay solid so the
--- direction change at each end is seamless.
local function bounceFade(left: number, right: number, rightward: boolean): NumberSequence
	local w = math.max(right - left, 0) + 0.03
	local strength = 0.92 * clamp01((w - 0.03) / 0.2)
	local fade = math.clamp(FADE / w, 0.05, 0.999)
	if rightward then
		return NumberSequence.new({
			NumberSequenceKeypoint.new(0, strength),
			NumberSequenceKeypoint.new(fade, 0),
			NumberSequenceKeypoint.new(1, 0),
		})
	end
	return NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1 - fade, 0),
		NumberSequenceKeypoint.new(1, strength),
	})
end

--[[
	Indeterminate arc spinner. The head runs ahead for the first half of each cycle,
	then the tail catches up, so the arc grows ~10° → ~280° and shrinks back while the
	ring spins. Returns (from, to) in degrees.
]]
local CYCLE = 1.333
local SPIN = 360 / 1.568
local MIN_SWEEP = 10
local STEP = 270

local function indeterminateArc(t: number): (number, number)
	local k = math.floor(t / CYCLE)
	local u = t / CYCLE - k
	local head = smooth(math.min(1, u / 0.5))
	local tail = smooth(math.max(0, (u - 0.5) / 0.5))
	local spin = t * SPIN
	return k * STEP + STEP * tail + spin, k * STEP + STEP * head + MIN_SWEEP + spin
end

--[[
	A radial cut only exists for fills from 12 o'clock, so a free arc [a, b] is drawn as:
	  no wrap (b <= 360): fill to b, then erase [0, a] in the background colour;
	  wrap    (b >  360): fill to b - 360 plus fill from a to 360 (nothing to erase).
	The erase layer needs `props.Background` to match whatever is behind the spinner.
]]
local function arcSpinner(
	scope: Types.Scope,
	props: Types.ProgressProps,
	theme: Types.Theme
): Instance
	local diameter = props.SizePx or 40
	local thickness = props.Thickness or 3
	-- Erase colour: explicit, else follows the nearest opaque ancestor (see below).
	-- A plain Color3: it is compared and copied, so a theme state is read once here.
	local background = scope:Value(props.Background or peek(theme.Colors.Surface))

	local clock = scope:Value(0)
	table.insert(
		scope,
		RunService.RenderStepped:Connect(function(dt: number)
			clock:set(peek(clock) + dt)
		end)
	)
	if Arc.supportsFreeArc() then
		-- Conical gradient available: one exact arc with round caps, nothing to erase.
		local fromAngle = scope:Computed(function(use)
			return (indeterminateArc(use(clock)))
		end)
		local toAngle = scope:Computed(function(use)
			local _, head = indeterminateArc(use(clock))
			return head
		end)
		return scope:New("Frame")({
			Name = "ProgressCircular",
			BackgroundTransparency = 1,
			Size = props.Size or UDim2.fromOffset(diameter, diameter),
			LayoutOrder = props.LayoutOrder or 0,
			[Children] = {
				scope:New("Frame")({
					Name = "Center",
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(diameter, diameter),
					BackgroundTransparency = 1,
					[Children] = {
						Arc(scope, {
							Name = "Arc",
							Diameter = diameter,
							Thickness = thickness,
							Color = theme.Colors.Primary,
							From = fromAngle,
							To = toAngle,
							Caps = true,
						}),
					},
				}),
			},
		}) :: Frame
	end

	-- (a, b) with a wrapped into 0..360 and b = a + sweep.
	local span = scope:Computed(function(use)
		local from, to = indeterminateArc(use(clock))
		local a = from % 360
		return { a = a, b = a + (to - from) }
	end)
	local fillAngle = scope:Computed(function(use)
		local sp = use(span)
		return if sp.b <= 360 then sp.b else sp.b - 360
	end)
	local eraseAngle = scope:Computed(function(use)
		local sp = use(span)
		return if sp.b <= 360 then sp.a else 0
	end)
	local wrapAngle = scope:Computed(function(use)
		local sp = use(span)
		return if sp.b <= 360 then 360 else sp.a
	end)

	local function layer(name: string, mode: "Head" | "Tail", color: any, angle: any, z: number)
		return Arc(scope, {
			Name = name,
			Mode = mode,
			Diameter = diameter,
			Thickness = thickness,
			Color = color,
			Angle = angle,
			ZIndex = z,
		})
	end

	local root = scope:New("Frame")({
		Name = "ProgressCircular",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.fromOffset(diameter, diameter),
		LayoutOrder = props.LayoutOrder or 0,
		[Children] = {
			scope:New("Frame")({
				Name = "Center",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(diameter, diameter),
				BackgroundTransparency = 1,
				[Children] = {
					layer("Fill", "Head", theme.Colors.Primary, fillAngle, 1),
					layer("Erase", "Head", background, eraseAngle, 2),
					layer("Wrap", "Tail", theme.Colors.Primary, wrapAngle, 3),
				},
			}),
		},
	}) :: Frame

	if props.Background == nil then
		local watching: RBXScriptConnection? = nil
		local function follow()
			if watching then
				watching:Disconnect()
				watching = nil
			end
			local inst = root.Parent
			while inst do
				if inst:IsA("GuiObject") and inst.BackgroundTransparency < 0.5 then
					local source = inst
					background:set(source.BackgroundColor3)
					watching = source
						:GetPropertyChangedSignal("BackgroundColor3")
						:Connect(function()
							background:set(source.BackgroundColor3)
						end)
					return
				end
				inst = inst.Parent
			end
		end
		table.insert(scope, root.AncestryChanged:Connect(follow))
		table.insert(scope, function()
			if watching then
				watching:Disconnect()
			end
		end)
		task.defer(follow)
	end
	return root
end

local function circular(
	scope: Types.Scope,
	props: Types.ProgressProps,
	theme: Types.Theme,
	mode: Types.ProgressMode
): Instance
	if mode == "Indeterminate" or mode == "Buffering" then
		if props.Indicator == "Arc" then
			return arcSpinner(scope, props, theme)
		end
		-- Default: the shape-morphing loading indicator.
		return LoadingMorph(scope, {
			Theme = props.Theme,
			SizePx = props.SizePx,
			Size = props.Size,
			LayoutOrder = props.LayoutOrder,
			Visible = props.Visible,
			ZIndex = props.ZIndex,
		})
	end

	local style: Types.ProgressStyle = props.Style or "Standard"
	local classic = style == "Classic"
	local diameter = props.SizePx or 40
	local thickness = props.Thickness or if classic then 3 else 4
	local midR = (diameter - thickness) / 2
	-- Visual gap (degrees) between the active arc and its track so round caps don't touch.
	local gap = if classic then 0 else math.deg((thickness * 1.6) / math.max(midR, 1))

	local target = scope:Computed(function(use)
		local v = props.Value
		if v == nil then
			return 0
		end
		return math.clamp((if typeof(v) == "table" then use(v) else v) :: number, 0, 1)
	end)
	local value = scope:Spring(target, theme.Motion.SpringSpeed * 0.5, 1)

	local headAngle = scope:Computed(function(use)
		local v = use(value) :: number
		if v <= 0.001 then
			return 0
		end
		return if v >= 0.999 then 360 else math.max(v * 360 - gap * 0.5, 0)
	end)
	local tailAngle = scope:Computed(function(use)
		local v = use(value) :: number
		return if v >= 0.999 then 360 else v * 360 + gap * 0.5
	end)

	local trackColor = Interaction.trackColor(theme)
	local kids: { any } = {
		Arc(scope, {
			Name = "Track",
			Mode = "Tail" :: "Tail",
			Diameter = diameter,
			Thickness = thickness,
			Color = trackColor,
			Angle = tailAngle,
			Caps = not classic,
		}),
		Arc(scope, {
			Name = "Indicator",
			Mode = "Head" :: "Head",
			Diameter = diameter,
			Thickness = thickness,
			Color = theme.Colors.Primary,
			Angle = headAngle,
			Caps = not classic,
			ZIndex = 2,
		}),
	}

	return scope:New("Frame")({
		Name = "ProgressCircular",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.fromOffset(diameter, diameter),
		LayoutOrder = props.LayoutOrder or 0,
		[Children] = {
			scope:New("Frame")({
				Name = "Center",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(diameter, diameter),
				BackgroundTransparency = 1,
				[Children] = kids,
			}),
		},
	}) :: Frame
end

return function(scope: Types.Scope, props: Types.ProgressProps): Instance
	local theme = resolveTheme(props)
	local variant: Types.ProgressVariant = props.Variant or "Linear"
	local mode: Types.ProgressMode = props.Mode
		or (if props.Value == nil then "Indeterminate" else "Determinate")
	local phase = scope:Value(0)

	if variant ~= "Circular" and (mode == "Indeterminate" or mode == "Buffering") then
		table.insert(
			scope,
			RunService.RenderStepped:Connect(function(dt: number)
				-- ~1.4s per full bounce round-trip
				phase:set((peek(phase) + dt / (2 * HALF)) % 1)
			end)
		)
	end

	if variant == "Circular" then
		return circular(scope, props, theme, mode)
	end

	local kids: { any } = {
		scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
	}

	if mode == "Buffering" or mode == "Determinate" then
		local bufferW = scope:Computed(function(use)
			if mode ~= "Buffering" then
				return 0
			end
			local b = props.Buffer
			if b == nil then
				return 0.7
			end
			return math.clamp((if typeof(b) == "table" then use(b) else b) :: number, 0, 1)
		end)
		table.insert(
			kids,
			scope:New("Frame")({
				Name = "Buffer",
				BackgroundColor3 = theme.Colors.PrimaryContainer,
				Size = scope:Computed(function(use)
					return UDim2.new(use(bufferW), 0, 1, 0)
				end),
				BorderSizePixel = 0,
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
				},
			})
		)
	end

	local barHeight = DEFAULT_BAR_HEIGHT
	if typeof(props.Size) == "UDim2" and (props.Size :: UDim2).Y.Offset > 0 then
		barHeight = (props.Size :: UDim2).Y.Offset
	end

	if mode == "Indeterminate" then
		table.insert(
			kids,
			scope:New("Frame")({
				Name = "Indeterminate",
				BackgroundColor3 = theme.Colors.Primary,
				BorderSizePixel = 0,
				Position = scope:Computed(function(use)
					local a = bounceGeometry(use(phase))
					return UDim2.new(a, -a * barHeight, 0, 0)
				end),
				Size = scope:Computed(function(use)
					local a, b = bounceGeometry(use(phase))
					local len = b - a
					-- Width = len of the (track - bar height) travel space + bar height,
					-- so a collapsed pill is exactly a circle as wide as the bar is tall.
					return UDim2.new(len, barHeight * (1 - len), 1, 0)
				end),
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
					-- Solid head, long trailing fade (as macOS does).
					scope:New("UIGradient")({
						Transparency = scope:Computed(function(use)
							return bounceFade(bounceGeometry(use(phase)))
						end),
					}),
				},
			})
		)
	else
		local fill = scope:Computed(function(use)
			local v = props.Value
			if v == nil then
				return 0
			end
			return math.clamp((if typeof(v) == "table" then use(v) else v) :: number, 0, 1)
		end)
		table.insert(
			kids,
			scope:New("Frame")({
				Name = "Fill",
				BackgroundColor3 = theme.Colors.Primary,
				Size = scope:Computed(function(use)
					return UDim2.new(use(fill), 0, 1, 0)
				end),
				BorderSizePixel = 0,
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
				},
			})
		)
	end

	return scope:New("Frame")({
		Name = "ProgressLinear",
		BackgroundColor3 = Interaction.trackColor(theme),
		Size = props.Size or UDim2.new(1, 0, 0, DEFAULT_BAR_HEIGHT),
		LayoutOrder = props.LayoutOrder or 0,
		ClipsDescendants = true,
		[Children] = kids,
	}) :: Frame
end
