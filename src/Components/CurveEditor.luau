--!strict
--[[
	Editor for a NumberSequence: a plot with draggable keypoints, and number fields for the
	selected keypoint. See docs/Components/Pickers/CurveEditor.md.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Focus = require(script.Parent.Parent.Internal.Focus)
local ScrollInput = require(script.Parent.Parent.Internal.ScrollInput)
local NumberField = require(script.Parent.NumberField)
local IconButton = require(script.Parent.IconButton)

local TweenService = game:GetService("TweenService")

local Children = Fusion.Children
local peek = Fusion.peek

local HANDLE = 14
local DOUBLE_CLICK = 0.35
local EPSILON = 0.001
local PAD = 12

type Manual = { inX: number, inY: number, outX: number, outY: number }
type Point = { time: number, value: number, envelope: number, manual: Manual? }

local MAX_KEYS = 20
local STEPS = 28

local function fromSequence(sequence: NumberSequence): { Point }
	local list: { Point } = {}
	for _, key in sequence.Keypoints do
		table.insert(list, { time = key.Time, value = key.Value, envelope = key.Envelope })
	end
	return list
end

local function slope(a: Point, b: Point): number
	return (b.value - a.value) / math.max(b.time - a.time, 1e-9)
end

local function handlesOf(list: { Point }, index: number): (number, number, number, number)
	local point = list[index]
	local prev, next = list[index - 1], list[index + 1]
	local reachIn = if prev then point.time - prev.time else 0
	local reachOut = if next then next.time - point.time else 0
	local manual = point.manual
	if manual then
		return math.clamp(manual.inX, -reachIn, 0),
			manual.inY,
			math.clamp(manual.outX, 0, reachOut),
			manual.outY
	end
	local before = if prev then slope(prev, point) else nil
	local after = if next then slope(point, next) else nil
	local m = 0
	if before and after then
		m = if before * after <= 0 then 0 else (before + after) / 2
	elseif before then
		m = before
	elseif after then
		m = after
	end
	return -reachIn / 3, -m * reachIn / 3, reachOut / 3, m * reachOut / 3
end

local function bezier(a: number, b: number, c: number, d: number, u: number): number
	local v = 1 - u
	return v * v * v * a + 3 * v * v * u * b + 3 * v * u * u * c + u * u * u * d
end

local function segmentOf(list: { Point }, index: number): { number }
	local a, b = list[index], list[index + 1]
	local _, _, outX, outY = handlesOf(list, index)
	local inX, inY = handlesOf(list, index + 1)
	return {
		a.time,
		a.value,
		a.time + outX,
		a.value + outY,
		b.time + inX,
		b.value + inY,
		b.time,
		b.value,
	}
end

local function isStraight(c: { number }): boolean
	local dt, dv = c[7] - c[1], c[8] - c[2]
	for _, k in { 3, 5 } do
		local expected = c[2] + dv * (if dt > 0 then (c[k] - c[1]) / dt else 0)
		if math.abs(c[k + 1] - expected) > 1e-6 then
			return false
		end
	end
	return true
end

local function toSequence(list: { Point }): NumberSequence
	local count = #list
	local curved = 0
	local segments: { { number } } = {}
	for index = 1, count - 1 do
		segments[index] = segmentOf(list, index)
		if not isStraight(segments[index]) then
			curved += 1
		end
	end
	local extra = if curved > 0 then math.max(math.floor((MAX_KEYS - count) / curved), 0) else 0
	local keys: { NumberSequenceKeypoint } = {}
	local lastTime = -1
	local function push(time: number, value: number, envelope: number)
		if time > lastTime + 1e-6 and time <= 1 then
			table.insert(keys, NumberSequenceKeypoint.new(time, value, envelope))
			lastTime = time
		end
	end
	for index, point in list do
		push(point.time, point.value, point.envelope)
		local c = segments[index]
		if c and extra > 0 and not isStraight(c) then
			local nextPoint = list[index + 1]
			for k = 1, extra do
				local u = k / (extra + 1)
				push(
					bezier(c[1], c[3], c[5], c[7], u),
					bezier(c[2], c[4], c[6], c[8], u),
					point.envelope + (nextPoint.envelope - point.envelope) * u
				)
			end
		end
	end
	return NumberSequence.new(keys)
end

local function sameSequence(a: NumberSequence, b: NumberSequence): boolean
	local x, y = a.Keypoints, b.Keypoints
	if #x ~= #y then
		return false
	end
	for index, key in x do
		local other = y[index]
		if
			math.abs(key.Time - other.Time) > 1e-6
			or math.abs(key.Value - other.Value) > 1e-6
			or math.abs(key.Envelope - other.Envelope) > 1e-6
		then
			return false
		end
	end
	return true
end

local function sameManual(a: Manual?, b: Manual?): boolean
	if a == nil or b == nil then
		return a == b
	end
	return math.abs(a.inX - b.inX) < 1e-6
		and math.abs(a.inY - b.inY) < 1e-6
		and math.abs(a.outX - b.outX) < 1e-6
		and math.abs(a.outY - b.outY) < 1e-6
end

local function samePoints(a: { Point }, b: { Point }): boolean
	if #a ~= #b then
		return false
	end
	for index, point in a do
		local other = b[index]
		if
			math.abs(point.time - other.time) > 1e-6
			or math.abs(point.value - other.value) > 1e-6
			or math.abs(point.envelope - other.envelope) > 1e-6
			or not sameManual(point.manual, other.manual)
		then
			return false
		end
	end
	return true
end

return function(scope: Types.Scope, props: Types.CurveEditorProps): Instance
	local theme = resolveTheme(props)
	local minValue = props.Min or 0
	local maxValue = props.Max or 1
	local span = math.max(maxValue - minValue, 1e-9)
	local height = props.Height or 180
	local disabled = peek(props.Disabled) == true
	local showEnvelope = props.ShowEnvelope == true

	local initial = if peek(props.Value)
		then fromSequence(peek(props.Value) :: NumberSequence)
		else {
			{ time = 0, value = minValue, envelope = 0 },
			{ time = 1, value = maxValue, envelope = 0 },
		}
	local persistKey = Persist.key("CurveEditor", typeof(props.Value) == "table")
	local points = Persist.value(scope, persistKey, "points", initial)
	local lastEmitted: NumberSequence? = nil
	if Bind.isState(props.Value) then
		local syncing = false
		table.insert(
			scope,
			scope:Observer(props.Value):onChange(function()
				if syncing then
					return
				end
				local incoming = peek(props.Value) :: NumberSequence
				if lastEmitted and sameSequence(incoming, lastEmitted) then
					return
				end
				syncing = true
				points:set(fromSequence(incoming))
				syncing = false
			end)
		)
		if Bind.isWritable(props.Value) then
			table.insert(
				scope,
				scope:Observer(points):onChange(function()
					if syncing then
						return
					end
					local sequence = toSequence(peek(points))
					if not sameSequence(sequence, peek(props.Value)) then
						lastEmitted = sequence
						syncing = true;
						(props.Value :: any):set(sequence)
						syncing = false
					end
				end)
			)
		end
	end
	local selected = scope:Value(1)

	local function commit(list: { Point })
		if samePoints(list, peek(points)) then
			return
		end
		local sequence = toSequence(list)
		lastEmitted = sequence
		points:set(list)
		if props.OnChanged then
			props.OnChanged(sequence)
		end
	end

	local plot = scope:TextButton({
		Name = "Plot",
		Text = "",
		AutoButtonColor = false,
		Active = not disabled,
		BackgroundColor3 = theme.Colors.SurfaceContainer,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, height),
		LayoutOrder = 1,
		CornerRadius = theme.Metrics.RadiusSm,
	}) :: TextButton
	local area = scope:New("Frame")({
		Name = "Area",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(PAD, PAD),
		Size = UDim2.new(1, -2 * PAD, 1, -2 * PAD),
		Parent = plot,
	}) :: Frame

	for step = 0, 4 do
		local fraction = step / 4
		scope:New("Frame")({
			Name = "GridX",
			Parent = area,
			BackgroundColor3 = theme.Colors.OutlineVariant,
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(fraction, 0),
			AnchorPoint = Vector2.new(fraction, 0),
			Size = UDim2.new(0, 1, 1, 0),
		})
		scope:New("Frame")({
			Name = "GridY",
			Parent = area,
			BackgroundColor3 = theme.Colors.OutlineVariant,
			BackgroundTransparency = 0.45,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0, fraction),
			AnchorPoint = Vector2.new(0, fraction),
			Size = UDim2.new(1, 0, 0, 1),
		})
	end
	for _, label in { { maxValue, 0 }, { minValue, 1 } } do
		scope:New("TextLabel")({
			Name = "AxisLabel",
			Parent = plot,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, label[2]),
			Position = UDim2.new(0, 3, label[2], if label[2] == 0 then 1 else -1),
			Size = UDim2.fromOffset(40, 12),
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = theme.Fonts.Mono,
			TextSize = A.size(theme, 10),
			TextColor3 = theme.Colors.OnSurfaceVariant,
			Text = tostring(label[1]),
		})
	end

	local segments: { Frame } = {}
	local envelopes: { Frame } = {}
	local handles: { TextButton } = {}
	local guides: { Frame } = {}
	local tangents: { TextButton } = {}

	local function pixelsOf(point: Point): (number, number)
		local size = area.AbsoluteSize
		return point.time * size.X, (1 - (point.value - minValue) / span) * size.Y
	end

	local function line(pool: { Frame }, index: number, color: any, thickness: number): Frame
		local frame = pool[index]
		if not frame then
			frame = scope:New("Frame")({
				Name = "Segment",
				Parent = area,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BorderSizePixel = 0,
				ZIndex = 2,
			}) :: Frame
			pool[index] = frame
		end
		frame.BackgroundColor3 = peek(color :: any)
		frame.Visible = true
		frame.Size = UDim2.fromOffset(frame.Size.X.Offset, thickness)
		return frame
	end

	local function place(
		frame: Frame,
		x1: number,
		y1: number,
		x2: number,
		y2: number,
		thickness: number
	)
		local length = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Position = UDim2.fromOffset((x1 + x2) / 2, (y1 + y2) / 2)
		frame.Size = UDim2.fromOffset(length + 0.75, thickness)
		frame.Rotation = math.deg(math.atan2(y2 - y1, x2 - x1))
	end

	local pressed: { [Instance]: boolean } = {}
	local function growTo(gui: GuiObject, px: number)
		if gui:GetAttribute("TargetSize") == px then
			return
		end
		gui:SetAttribute("TargetSize", px)
		TweenService:Create(
			gui,
			TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Size = UDim2.fromOffset(px, px) }
		):Play()
	end

	local function hideFrom(pool: { Frame }, index: number)
		for at = index, #pool do
			pool[at].Visible = false
		end
	end

	local ensureHandles: () -> ()
	local ensureTangents: () -> ()

	local function redraw()
		local list = peek(points) :: { Point }
		local size = area.AbsoluteSize
		if size.X <= 0 or size.Y <= 0 then
			return
		end
		ensureHandles()
		local used = 0
		for index = 1, #list - 1 do
			local c = segmentOf(list, index)
			local pieces = if isStraight(c) then 1 else STEPS
			local lastX, lastY = pixelsOf({ time = c[1], value = c[2], envelope = 0 })
			for step = 1, pieces do
				local u = step / pieces
				local x, y = pixelsOf({
					time = bezier(c[1], c[3], c[5], c[7], u),
					value = bezier(c[2], c[4], c[6], c[8], u),
					envelope = 0,
				})
				used += 1
				local segment = line(segments, used, theme.Colors.Primary, 2)
				place(segment, lastX, lastY, x, y, 2)
				lastX, lastY = x, y
			end
		end
		hideFrom(segments, used + 1)

		used = 0
		if showEnvelope then
			for _, point in list do
				if point.envelope > 0 then
					used += 1
					local x, y = pixelsOf(point)
					local reach = point.envelope / span * size.Y
					local bar = line(envelopes, used, theme.Colors.Warning, 1)
					bar.AnchorPoint = Vector2.new(0.5, 0.5)
					bar.Position = UDim2.fromOffset(x, y)
					bar.Size = UDim2.fromOffset(2, reach * 2)
					bar.Rotation = 0
					bar.BackgroundTransparency = 0.35
				end
			end
		end
		hideFrom(envelopes, used + 1)

		local current = peek(selected) :: number
		for index, point in list do
			local handle = handles[index]
			local x, y = pixelsOf(point)
			handle.Visible = true
			handle.Position = UDim2.fromOffset(x, y)
			local isSelected = index == current
			growTo(
				handle,
				HANDLE + (if isSelected then 4 else 0) + (if pressed[handle] then 6 else 0)
			)
			handle.BackgroundColor3 =
				peek((if isSelected then theme.Colors.Primary else theme.Colors.Surface) :: any)
		end
		for index = #list + 1, #handles do
			handles[index].Visible = false
		end

		ensureTangents()
		local at = math.clamp(current, 1, #list)
		local point = list[at]
		local inX, inY, outX, outY = handlesOf(list, at)
		local shownGuides = 0
		for kind = 1, 2 do
			local present = if kind == 1 then at > 1 else at < #list
			local button = tangents[kind]
			button.Visible = present
			growTo(button, if pressed[button] then 15 else 10)
			if present then
				local dx, dy = if kind == 1 then inX else outX, if kind == 1 then inY else outY
				local hx, hy = pixelsOf({
					time = point.time + dx,
					value = point.value + dy,
					envelope = 0,
				})
				local px, py = pixelsOf(point)
				button.Position = UDim2.fromOffset(hx, hy)
				shownGuides += 1
				local guide = line(guides, shownGuides, theme.Colors.OnSurfaceVariant, 1)
				guide.ZIndex = 1
				guide.BackgroundTransparency = 0.4
				place(guide, px, py, hx, hy, 1)
			end
		end
		hideFrom(guides, shownGuides + 1)
	end

	local function move(index: number, time: number, value: number)
		local list = table.clone(peek(points)) :: { Point }
		local point = list[index]
		local nextTime = point.time
		if index > 1 and index < #list then
			nextTime =
				math.clamp(time, list[index - 1].time + EPSILON, list[index + 1].time - EPSILON)
		end
		list[index] = {
			time = nextTime,
			value = math.clamp(value, minValue, maxValue),
			envelope = point.envelope,
			manual = point.manual,
		}
		commit(list)
	end

	local function addAt(time: number)
		local list = table.clone(peek(points)) :: { Point }
		local index = 1
		for at = 1, #list - 1 do
			if time >= list[at].time then
				index = at
			end
		end
		local c = segmentOf(list, index)
		local low, high = 0, 1
		for _ = 1, 30 do
			local mid = (low + high) / 2
			if bezier(c[1], c[3], c[5], c[7], mid) < time then
				low = mid
			else
				high = mid
			end
		end
		local u = (low + high) / 2
		local function lerp(a: number, b: number): number
			return a + (b - a) * u
		end
		local ax, ay = lerp(c[1], c[3]), lerp(c[2], c[4])
		local bx, by = lerp(c[3], c[5]), lerp(c[4], c[6])
		local cx, cy = lerp(c[5], c[7]), lerp(c[6], c[8])
		local dx, dy = lerp(ax, bx), lerp(ay, by)
		local ex, ey = lerp(bx, cx), lerp(by, cy)
		local fx, fy = lerp(dx, ex), lerp(dy, ey)

		local left, right = list[index], list[index + 1]
		local leftInX, leftInY = handlesOf(list, index)
		local _, _, rightOutX, rightOutY = handlesOf(list, index + 1)
		list[index] = {
			time = left.time,
			value = left.value,
			envelope = left.envelope,
			manual = {
				inX = leftInX,
				inY = leftInY,
				outX = ax - c[1],
				outY = ay - c[2],
			},
		}
		list[index + 1] = {
			time = right.time,
			value = right.value,
			envelope = right.envelope,
			manual = {
				inX = cx - c[7],
				inY = cy - c[8],
				outX = rightOutX,
				outY = rightOutY,
			},
		}
		table.insert(list, index + 1, {
			time = math.clamp(fx, left.time + EPSILON, right.time - EPSILON),
			value = math.clamp(fy, minValue, maxValue),
			envelope = left.envelope + (right.envelope - left.envelope) * u,
			manual = { inX = dx - fx, inY = dy - fy, outX = ex - fx, outY = ey - fy },
		})
		selected:set(index + 1)
		commit(list)
	end

	local function remove(index: number)
		local list = table.clone(peek(points)) :: { Point }
		if index <= 1 or index >= #list then
			return
		end
		table.remove(list, index)
		selected:set(math.max(index - 1, 1))
		commit(list)
	end

	local function dragTangent(kind: number, position: Vector3)
		local list = table.clone(peek(points)) :: { Point }
		local index = math.clamp(peek(selected) :: number, 1, #list)
		local point = list[index]
		local origin, size = area.AbsolutePosition, area.AbsoluteSize
		local time = (position.X - origin.X) / math.max(size.X, 1)
		local value = minValue + (1 - (position.Y - origin.Y) / math.max(size.Y, 1)) * span
		local inX, inY, outX, outY = handlesOf(list, index)
		local dx = time - point.time
		local dy = math.clamp(value, minValue, maxValue) - point.value
		if kind == 1 then
			inX, inY = dx, dy
		else
			outX, outY = dx, dy
		end
		list[index] = {
			time = point.time,
			value = point.value,
			envelope = point.envelope,
			manual = { inX = inX, inY = inY, outX = outX, outY = outY },
		}
		commit(list)
	end

	function ensureTangents()
		for kind = #tangents + 1, 2 do
			local button = scope:New("TextButton")({
				Name = if kind == 1 then "TangentIn" else "TangentOut",
				Text = "",
				AutoButtonColor = false,
				Active = not disabled,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(10, 10),
				Rotation = 45,
				BackgroundColor3 = theme.Colors.Primary,
				BorderSizePixel = 0,
				Visible = false,
				ZIndex = 3,
				Parent = area,
			}) :: TextButton
			tangents[kind] = button
			table.insert(
				scope,
				button.InputBegan:Connect(function(input: InputObject)
					if
						disabled
						or (
							input.UserInputType ~= Enum.UserInputType.MouseButton1
							and input.UserInputType ~= Enum.UserInputType.Touch
						)
					then
						return
					end
					pressed[button] = true
					redraw()
					ScrollInput.capture(button, function(changed: InputObject)
						return changed.UserInputType == Enum.UserInputType.MouseMovement
							or changed.UserInputType == Enum.UserInputType.Touch
					end, function(ended: InputObject)
						return ended.UserInputType == Enum.UserInputType.MouseButton1
							or ended.UserInputType == Enum.UserInputType.Touch
					end, function(position: Vector3)
						dragTangent(kind, position)
					end, function()
						pressed[button] = nil
						redraw()
					end)
				end)
			)
		end
	end

	function ensureHandles()
		local list = peek(points) :: { Point }
		for index = #handles + 1, #list do
			local handle = scope:New("TextButton")({
				Name = `Point{index}`,
				Text = "",
				AutoButtonColor = false,
				Active = not disabled,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromOffset(HANDLE, HANDLE),
				BackgroundColor3 = theme.Colors.Surface,
				BorderSizePixel = 0,
				ZIndex = 4,
				Parent = area,
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
					scope:New("UIStroke")({
						Color = theme.Colors.Primary,
						Thickness = 2,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					}),
				},
			}) :: TextButton
			handles[index] = handle
			Focus.manage(handle, theme)
			table.insert(
				scope,
				handle.InputBegan:Connect(function(input: InputObject)
					if
						disabled
						or (
							input.UserInputType ~= Enum.UserInputType.MouseButton1
							and input.UserInputType ~= Enum.UserInputType.Touch
						)
					then
						return
					end
					selected:set(index)
					pressed[handle] = true
					redraw()
					ScrollInput.capture(handle, function(changed: InputObject)
						return changed.UserInputType == Enum.UserInputType.MouseMovement
							or changed.UserInputType == Enum.UserInputType.Touch
					end, function(ended: InputObject)
						return ended.UserInputType == Enum.UserInputType.MouseButton1
							or ended.UserInputType == Enum.UserInputType.Touch
					end, function(position: Vector3)
						local origin, size = area.AbsolutePosition, area.AbsoluteSize
						local time = math.clamp((position.X - origin.X) / math.max(size.X, 1), 0, 1)
						local across =
							math.clamp((position.Y - origin.Y) / math.max(size.Y, 1), 0, 1)
						move(index, time, minValue + (1 - across) * span)
					end, function()
						pressed[handle] = nil
						redraw()
					end)
				end)
			)
			Focus.onKey(handle, function(key: InputObject): boolean
				local current = (peek(points) :: { Point })[index]
				local point = current
				local stepTime, stepValue = 0.01, span / 100
				if key.KeyCode == Enum.KeyCode.Left then
					move(index, point.time - stepTime, point.value)
				elseif key.KeyCode == Enum.KeyCode.Right then
					move(index, point.time + stepTime, point.value)
				elseif key.KeyCode == Enum.KeyCode.Up then
					move(index, point.time, point.value + stepValue)
				elseif key.KeyCode == Enum.KeyCode.Down then
					move(index, point.time, point.value - stepValue)
				elseif
					key.KeyCode == Enum.KeyCode.Delete or key.KeyCode == Enum.KeyCode.Backspace
				then
					remove(index)
				else
					return false
				end
				return true
			end)
		end
	end

	local lastPress = 0
	table.insert(
		scope,
		plot.InputBegan:Connect(function(input: InputObject)
			if disabled or input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end
			local now = os.clock()
			if now - lastPress < DOUBLE_CLICK then
				lastPress = 0
				local origin, size = area.AbsolutePosition, area.AbsoluteSize
				addAt(
					math.clamp(
						(input.Position.X - origin.X) / math.max(size.X, 1),
						EPSILON,
						1 - EPSILON
					)
				)
			else
				lastPress = now
			end
		end)
	)

	local function refresh()
		ensureHandles()
		redraw()
	end
	table.insert(scope, scope:Observer(points):onChange(refresh))
	table.insert(
		scope,
		scope:Observer(selected):onChange(function()
			redraw()
		end)
	)
	table.insert(scope, area:GetPropertyChangedSignal("AbsoluteSize"):Connect(redraw))
	for _, color in { theme.Colors.Primary, theme.Colors.Surface, theme.Colors.Warning } do
		if (color :: any).type == "State" then
			table.insert(scope, scope:Observer(color :: any):onChange(redraw))
		end
	end
	task.defer(refresh)

	local function field(
		label: string,
		order: number,
		get: (Point) -> number,
		set: (Point, number) -> Point,
		min: number,
		max: number,
		step: number
	): Instance
		local shown = scope:Value(0)
		local function pull()
			local list = peek(points) :: { Point }
			local point = list[math.clamp(peek(selected) :: number, 1, #list)]
			shown:set(get(point))
		end
		pull()
		table.insert(scope, scope:Observer(points):onChange(pull))
		table.insert(scope, scope:Observer(selected):onChange(pull))
		return NumberField(scope, {
			Theme = theme,
			Label = label,
			Value = shown,
			Min = min,
			Max = max,
			Step = step,
			Disabled = disabled,
			LayoutOrder = order,
			Size = UDim2.new(1 / 3, -6, 0, 32),
			OnChanged = function(n: number)
				local list = table.clone(peek(points)) :: { Point }
				local index = math.clamp(peek(selected) :: number, 1, #list)
				local updated = set(list[index], n)
				if index == 1 then
					updated.time = 0
				elseif index == #list then
					updated.time = 1
				else
					updated.time = math.clamp(
						updated.time,
						list[index - 1].time + EPSILON,
						list[index + 1].time - EPSILON
					)
				end
				list[index] = updated
				commit(list)
			end,
		})
	end

	local fields = scope:New("Frame")({
		Name = "Fields",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 32),
		LayoutOrder = 2,
		[Children] = {
			scope:New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
			}),
			field("T", 1, function(p)
				return p.time
			end, function(p, n)
				return { time = n, value = p.value, envelope = p.envelope, manual = p.manual }
			end, 0, 1, 0.01),
			field("V", 2, function(p)
				return p.value
			end, function(p, n)
				return { time = p.time, value = n, envelope = p.envelope, manual = p.manual }
			end, minValue, maxValue, span / 100),
			if showEnvelope
				then field("±", 3, function(p)
					return p.envelope
				end, function(p, n)
					return { time = p.time, value = p.value, envelope = n, manual = p.manual }
				end, 0, span, span / 100)
				else nil,
			IconButton(scope, {
				Theme = theme,
				Name = "trash-2",
				Disabled = disabled,
				LayoutOrder = 4,
				Size = UDim2.fromOffset(32, 32),
				OnClick = function()
					remove(peek(selected) :: number)
				end,
			}),
		} :: any,
	}) :: Frame

	return scope:New("Frame")({
		Name = "CurveEditor",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		[Children] = {
			scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
			}),
			plot,
			fields,
		} :: any,
	}) :: Frame
end
