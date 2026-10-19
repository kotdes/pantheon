--!strict
--[[
	Gradient editor. The selected stop's colour is edited by a ColorPicker underneath.
	See docs/Components/Pickers/GradientPicker.md.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Drag = require(script.Parent.Parent.Internal.Picker.Drag)
local Widgets = require(script.Parent.Parent.Internal.Picker.Widgets)
local GroupFade = require(script.Parent.Parent.Internal.GroupFade)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Corners = require(script.Parent.Parent.Internal.Corners)
local Persist = require(script.Parent.Parent.Internal.Persist)
local Icon = require(script.Parent.Icon)
local Tooltip = require(script.Parent.Tooltip)
local ColorPicker = require(script.Parent.ColorPicker)

type ChannelSpec = Widgets.ChannelSpec

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

-- Spring for the Rot / Pos / Alpha boxes. Underdamped, so they overshoot slightly.
local EXPAND_SPEED = 28
local EXPAND_DAMPING = 0.8

type Stop = { id: number, color: Color3, alpha: number, pos: number }

local function twoStop(a: Color3, b: Color3): ColorSequence
	return ColorSequence.new(a, b)
end

--- Sample `count` evenly spaced colours of a function of 0..1 into a sequence.
local function indexOf(list: { Stop }, id: number): number?
	for index, stop in list do
		if stop.id == id then
			return index
		end
	end
	return nil
end

local function sorted(list: { Stop }): { Stop }
	local copy = table.clone(list)
	table.sort(copy, function(a, b)
		return a.pos < b.pos
	end)
	return copy
end

--- Stops as a UIGradient's Color and Transparency. Keypoints have to ascend and cover 0..1, so
--- equal positions are nudged apart and the end colours are extended to the edges.
local function sequences(list: { Stop }): (ColorSequence, NumberSequence)
	local colors: { ColorSequenceKeypoint } = {}
	local alphas: { NumberSequenceKeypoint } = {}
	local last = -1
	for _, stop in sorted(list) do
		local t = math.clamp(stop.pos, 0, 1)
		if t <= last then
			t = last + 0.001
		end
		last = t
		if t <= 1 then
			table.insert(colors, ColorSequenceKeypoint.new(t, stop.color))
			table.insert(alphas, NumberSequenceKeypoint.new(t, 1 - stop.alpha))
		end
	end
	if colors[1].Time > 0 then
		table.insert(colors, 1, ColorSequenceKeypoint.new(0, colors[1].Value))
		table.insert(alphas, 1, NumberSequenceKeypoint.new(0, alphas[1].Value))
	end
	if colors[#colors].Time < 1 then
		table.insert(colors, ColorSequenceKeypoint.new(1, colors[#colors].Value))
		table.insert(alphas, NumberSequenceKeypoint.new(1, alphas[#alphas].Value))
	end
	return ColorSequence.new(colors), NumberSequence.new(alphas)
end

--- Colour and alpha of the gradient at `pos`, for seeding a new stop.
local function sampleAt(list: { Stop }, pos: number): (Color3, number)
	local ordered = sorted(list)
	local before, after = ordered[1], ordered[#ordered]
	for _, stop in ordered do
		if stop.pos <= pos then
			before = stop
		end
	end
	for index = #ordered, 1, -1 do
		if ordered[index].pos >= pos then
			after = ordered[index]
		end
	end
	local span = after.pos - before.pos
	local t = if span > 1e-6 then math.clamp((pos - before.pos) / span, 0, 1) else 0
	return before.color:Lerp(after.color, t), before.alpha + (after.alpha - before.alpha) * t
end

local function sampleNumber(sequence: NumberSequence, time: number): number
	local keys = sequence.Keypoints
	for index = 2, #keys do
		if time <= keys[index].Time then
			local a, b = keys[index - 1], keys[index]
			local span = b.Time - a.Time
			return a.Value + (b.Value - a.Value) * (if span > 0 then (time - a.Time) / span else 0)
		end
	end
	return keys[#keys].Value
end

local function shortNumber(n: number): string
	return string.format("%g", math.floor(n * 100 + 0.5) / 100)
end

return function(scope: Types.Scope, props: Types.GradientPickerProps): Instance
	local theme = resolveTheme(props)
	local showAlpha = props.ShowAlpha ~= false
	local gap = theme.Metrics.SpaceSm
	local initial: Color3 = Color3.fromRGB(0, 105, 92)
	local persistKey = Persist.key("GradientPicker", props.Id, false)

	--- Tooltip for a button. Skipped when there is no overlay layer (`Layer`, or one set with Layer.Provide or Layer.bind).
	local function tip(target: Instance, text: string)
		if Layer.resolve(props) then
			Tooltip(scope, { Theme = theme, Layer = props.Layer, Target = target, Text = text })
		end
	end

	-- Gradient state: any number of stops
	local nextId = 0
	local function newId(): number
		nextId += 1
		return nextId
	end
	local stops = Persist.value(
		scope,
		persistKey,
		"stops",
		{
			{ id = newId(), color = initial, alpha = 1, pos = 0 },
			{ id = newId(), color = Color3.new(1, 1, 1), alpha = 1, pos = 1 },
		} :: { Stop }
	)
	for _, stop in peek(stops) do
		nextId = math.max(nextId, stop.id)
	end
	local selected = Persist.value(scope, persistKey, "selected", peek(stops)[1].id)
	local rotation = Persist.value(scope, persistKey, "rotation", props.GradientRotation or 0)
	local offsetX = Persist.value(scope, persistKey, "offsetX", 0)
	local offsetY = Persist.value(scope, persistKey, "offsetY", 0)

	do
		local given = peek(props.Gradient) :: ColorSequence?
		if given then
			local transparency = peek(props.GradientTransparency) :: NumberSequence?
			local list: { Stop } = {}
			for _, key in given.Keypoints do
				table.insert(list, {
					id = newId(),
					color = key.Value,
					alpha = if transparency then 1 - sampleNumber(transparency, key.Time) else 1,
					pos = key.Time,
				})
			end
			stops:set(list)
			selected:set(list[1].id)
		end
	end

	local function emitGradient()
		if props.OnChanged then
			local colors, transparency = sequences(peek(stops))
			props.OnChanged(
				colors,
				transparency,
				peek(rotation),
				Vector2.new(peek(offsetX), peek(offsetY))
			)
		end
	end
	-- Report the starting gradient so a preview is correct before the first edit.
	task.defer(emitGradient)

	-- Selected stop. `stopColor` is the colour the node picker edits.
	local stopColor = scope:Value(peek(stops)[indexOf(peek(stops), peek(selected)) or 1].color)
	local stopAlpha = scope:Computed(function(use: any)
		local list = use(stops)
		return list[indexOf(list, use(selected) :: number) or 1].alpha
	end)
	local W = Widgets.new(theme, stopColor)
	local checker, numberBox, sliderTrack, hexField =
		W.checker, W.numberBox, W.sliderTrack, W.hexField
	local TRACK_HEIGHT = W.TRACK_HEIGHT

	-- Gradient editor
	local setStopColor: (id: number, c: Color3) -> ()
	local gradientEditor: Frame? = nil
	do
		local EDIT_ROW = TRACK_HEIGHT + 12
		-- Spacing in an open box: equal padding on all sides (animated up from CLOSED_PAD) and
		-- one gap between row elements and between rows.
		local OPEN_PAD = 14
		local CLOSED_PAD = 4
		local INNER_GAP = 12
		local ROW_GAP = 12
		local BACK_W, LABEL_W, FIELD_W = 28, 44, 56
		local TRACK_X = BACK_W + INNER_GAP + LABEL_W + INNER_GAP
		local RAIL_H = 60
		local BAR_TOP, BAR_H = 22, TRACK_HEIGHT
		local RAIL_PAD = 10

		local selectedStop = scope:Computed(function(use: any)
			local list = use(stops)
			return list[indexOf(list, use(selected) :: number) or 1]
		end)

		-- Select a stop and load its colour into the node picker.
		local function selectStop(id: number)
			local list = peek(stops)
			local index = indexOf(list, id)
			if not index then
				return
			end
			selected:set(id)
			stopColor:set(list[index].color)
		end

		local function commit(list: { Stop })
			stops:set(list)
			emitGradient()
		end

		local function addStop(pos: number): number
			local list = table.clone(peek(stops))
			local sampledColor, sampledAlpha = sampleAt(list, pos)
			local id = newId()
			table.insert(list, { id = id, color = sampledColor, alpha = sampledAlpha, pos = pos })
			commit(list)
			selectStop(id)
			return id
		end

		local function duplicateStop()
			local list = table.clone(peek(stops))
			local index = indexOf(list, peek(selected))
			if not index then
				return
			end
			local source = list[index]
			local id = newId()
			table.insert(list, {
				id = id,
				color = source.color,
				alpha = source.alpha,
				pos = if source.pos > 0.9 then source.pos - 0.08 else source.pos + 0.08,
			})
			commit(list)
			selectStop(id)
		end

		local function removeStop()
			local list = table.clone(peek(stops))
			if #list <= 2 then
				return
			end
			local index = indexOf(list, peek(selected))
			if not index then
				return
			end
			table.remove(list, index)
			commit(list)
			selectStop(sorted(list)[math.min(index, #list)].id)
		end

		local function setStopPos(id: number, pos: number)
			local list = table.clone(peek(stops))
			local index = indexOf(list, id)
			if not index then
				return
			end
			local stop = list[index]
			list[index] =
				{ id = id, color = stop.color, alpha = stop.alpha, pos = math.clamp(pos, 0, 1) }
			commit(list)
		end

		setStopColor = function(id: number, c: Color3)
			local list = table.clone(peek(stops))
			local index = indexOf(list, id)
			if not index then
				return
			end
			local stop = list[index]
			list[index] = { id = id, color = c, alpha = stop.alpha, pos = stop.pos }
			commit(list)
			if id == peek(selected) and peek(stopColor) ~= c then
				stopColor:set(c)
			end
		end

		local function setStopAlpha(a: number)
			local list = table.clone(peek(stops))
			local index = indexOf(list, peek(selected))
			if not index then
				return
			end
			local stop = list[index]
			list[index] =
				{ id = stop.id, color = stop.color, alpha = math.clamp(a, 0, 1), pos = stop.pos }
			commit(list)
		end

		-- The bar and its handles
		local barSequences = scope:Computed(function(use)
			local colors, transparency = sequences(use(stops))
			return { colors = colors, transparency = transparency }
		end)
		local dragging = scope:Value(nil :: number?)

		local stopIds = scope:Computed(function(use)
			local ids: { number } = {}
			for _, stop in use(stops) do
				table.insert(ids, stop.id)
			end
			return ids
		end)

		local handles = scope:ForValues(stopIds, function(_, sc: any, id: number)
			local stop = sc:Computed(function(get)
				local list = get(stops)
				return list[indexOf(list, id) or 1]
			end)
			local isSelected = sc:Computed(function(get)
				return get(selected) == id
			end)
			local isHeld = sc:Computed(function(get)
				return get(dragging) == id
			end)
			-- A handle scales in when added. The selected one is slightly larger and grows while held.
			local appear = sc:Value(0)
			local appearSpring = sc:Spring(appear, 26, 0.65)
			task.defer(function()
				appear:set(1)
			end)
			local emphasis = sc:Spring(
				sc:Computed(function(get)
					return (if get(isSelected) then 0.1 else 0) + (if get(isHeld) then 0.12 else 0)
				end),
				34,
				0.7
			)

			return sc:New("Frame")({
				Name = `Stop{id}`,
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = sc:Computed(function(get)
					return UDim2.new(get(stop).pos, 0, 0.5, 0)
				end),
				Size = UDim2.fromOffset(24, RAIL_H),
				ZIndex = sc:Computed(function(get)
					return if get(isSelected) then 4 else 3
				end),
				[Children] = {
					sc:New("UIScale")({
						Scale = sc:Computed(function(get)
							return math.max(get(appearSpring), 0) * (0.9 + get(emphasis))
						end),
					}),
					-- Diamond marker above the bar: white when selected.
					sc:New("Frame")({
						Name = "Marker",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0, 8),
						Size = UDim2.fromOffset(10, 10),
						Rotation = 45,
						BorderSizePixel = 0,
						BackgroundColor3 = sc:Spring(
							sc:Computed(function(get)
								return if get(isSelected)
									then Color3.new(1, 1, 1)
									else get(theme.Colors.Outline)
							end),
							30,
							1
						),
						[Children] = {
							sc:New("UICorner")({ CornerRadius = UDim.new(0, 2) }),
						},
					}),
					sc:New("Frame")({
						Name = "Handle",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0, BAR_TOP + BAR_H / 2),
						Size = UDim2.fromOffset(15, BAR_H + 8),
						BorderSizePixel = 0,
						BackgroundColor3 = sc:Computed(function(get)
							return get(stop).color
						end),
						[Children] = {
							sc:New("UICorner")({ CornerRadius = UDim.new(0, 7.5) }),
							sc:New("UIStroke")({
								Color = Color3.new(1, 1, 1),
								Thickness = 2.5,
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							}),
							sc:New("UIShadow")({
								Color = Color3.new(0, 0, 0),
								Transparency = 0.6,
								BlurRadius = UDim.new(0, 4),
								Offset = UDim2.fromOffset(0, 1),
							}),
						},
					}),
				},
			})
		end)

		local rail = scope:New("Frame")({
			Name = "Rail",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(RAIL_PAD, 0),
			Size = UDim2.new(1, -2 * RAIL_PAD, 1, 0),
			Active = true,
			[Children] = {
				checker(
					scope,
					48,
					2,
					UDim2.fromOffset(0, BAR_TOP),
					UDim2.new(1, 0, 0, BAR_H),
					UDim.new(0, 8)
				),
				scope:New("Frame")({
					Name = "Bar",
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					Position = UDim2.fromOffset(0, BAR_TOP),
					Size = UDim2.new(1, 0, 0, BAR_H),
					[Children] = {
						scope:New("UICorner")({ CornerRadius = UDim.new(0, 8) }),
						scope:New("UIGradient")({
							Color = scope:Computed(function(use)
								return use(barSequences).colors
							end),
							Transparency = scope:Computed(function(use)
								return use(barSequences).transparency
							end),
						}),
					},
				}),
				handles,
			},
		}) :: Frame

		-- Pressing a handle selects and drags it. Pressing anywhere else adds a stop there.
		Drag.bind(scope, rail, function(x: number)
			local id = peek(dragging)
			if id then
				setStopPos(id, x)
			end
		end, function(x: number)
			local width = math.max(rail.AbsoluteSize.X, 1)
			local nearest: number? = nil
			local best = 14 / width
			for _, stop in peek(stops) do
				local distance = math.abs(stop.pos - x)
				if distance <= best then
					nearest, best = stop.id, distance
				end
			end
			if nearest then
				selectStop(nearest)
			else
				nearest = addStop(x)
			end
			dragging:set(nearest)
			return true
		end, function(down: boolean)
			if not down then
				dragging:set(nil)
			end
		end)

		-- Rot / Pos / Alpha: the pressed box grows to fill the row
		local open = scope:Value(nil :: string?)
		local keys = { "Rot", "Pos" }
		if showAlpha then
			table.insert(keys, "Alpha")
		end
		local count = #keys

		local function back(sc: any): TextButton
			local button = sc:New("TextButton")({
				Name = "Back",
				Text = "",
				AutoButtonColor = false,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromOffset(28, 28),
				BackgroundColor3 = theme.Colors.SurfaceContainerHigh,
				BorderSizePixel = 0,
				[OnEvent("Activated")] = function()
					open:set(nil)
				end,
				[Children] = {
					sc:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
					sc:Apply(Icon(sc, {
						Theme = theme,
						Name = "arrow-left",
						IconSize = 16,
						Color = theme.Colors.OnSurface,
					}))({
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
					}),
				} :: any,
			}) :: TextButton
			tip(button, "Back")
			return button
		end

		--- Row: back button, label, slider, number field. Only the first row of an editor has the back button.
		local function editorRow(
			sc: any,
			label: string,
			spec: ChannelSpec,
			withBack: boolean
		): Frame
			local holder = sliderTrack(sc, spec)
			holder.Position = UDim2.fromOffset(TRACK_X, 0)
			holder.Size = UDim2.new(1, -(TRACK_X + INNER_GAP + FIELD_W), 1, 0)
			return sc:New("Frame")({
				Name = label,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, EDIT_ROW),
				LayoutOrder = spec.order,
				[Children] = {
					if withBack then back(sc) :: any else nil,
					sc:New("TextLabel")({
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(BACK_W + INNER_GAP, 0),
						Size = UDim2.new(0, LABEL_W, 1, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						FontFace = theme.Typography.Label.Font,
						TextSize = 13,
						TextColor3 = theme.Colors.OnSurfaceVariant,
						Text = label,
					}),
					holder,
					sc:New("Frame")({
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(1, 0.5),
						Size = UDim2.fromOffset(FIELD_W, TRACK_HEIGHT),
						[Children] = {
							numberBox(
								sc,
								spec.get,
								spec.set,
								spec.min,
								spec.max,
								spec.decimals or 0
							),
						},
					}),
				},
			}) :: Frame
		end

		local neutralTrack = function(use: any)
			return twoStop(use(theme.Colors.OutlineVariant), use(theme.Colors.Outline))
		end
		local function axisSpec(label: string, state: any, order: number): ChannelSpec
			return {
				label = label,
				min = -1,
				max = 1,
				decimals = 2,
				get = function(use)
					return use(state)
				end,
				set = function(n)
					state:set(n)
					emitGradient()
				end,
				track = neutralTrack,
				order = order,
			}
		end

		-- Editor rows per box. `rows` sets the open height (Pos has X and Y).
		local editors: { [string]: { rows: number, build: (sc: any) -> { any } } } = {
			Rot = {
				rows = 1,
				build = function(sc)
					return {
						editorRow(sc, "Rot", {
							label = "Rot",
							min = 0,
							max = 360,
							get = function(use)
								return use(rotation)
							end,
							set = function(n)
								rotation:set(n)
								emitGradient()
							end,
							track = neutralTrack,
							order = 1,
						}, true),
					}
				end,
			},
			Pos = {
				rows = 2,
				build = function(sc)
					return {
						editorRow(sc, "X", axisSpec("X", offsetX, 1), true),
						editorRow(sc, "Y", axisSpec("Y", offsetY, 2), false),
					}
				end,
			},
			Alpha = {
				rows = 1,
				build = function(sc)
					return {
						editorRow(sc, "Alpha", {
							label = "Alpha",
							min = 0,
							max = 100,
							get = function(use)
								return use(stopAlpha) * 100
							end,
							set = function(n)
								setStopAlpha(n / 100)
							end,
							track = function(use)
								local c = use(stopColor)
								return twoStop(c, c)
							end,
							alphaTrack = true,
							order = 1,
						}, true),
					}
				end,
			},
		}
		local function openHeight(key: string): number
			local rows = editors[key].rows
			return rows * EDIT_ROW + (rows - 1) * ROW_GAP + 2 * OPEN_PAD
		end

		local function lerp(a: number, b: number, t: number): number
			return a + (b - a) * t
		end

		--- Springs to 1 while `target` holds, 0 otherwise.
		local function reveal(target: (use: any) -> boolean): any
			return scope:Spring(
				scope:Computed(function(use)
					return if target(use) then 1 else 0
				end),
				EXPAND_SPEED,
				EXPAND_DAMPING
			)
		end

		--- Hide a layer once it has faded out, so it can't take clicks.
		local function shown(amount: any): any
			return scope:Computed(function(use)
				return (use(amount) :: number) > 0.01
			end)
		end

		-- While a box is open every summary fades out and the open box grows into its editor.
		local summariesIn = reveal(function(use)
			return use(open) == nil
		end)

		local function box(key: string, index: number): Frame
			local hovered = scope:Value(false)
			local pressed = scope:Value(false)
			local g = reveal(function(use)
				return use(open) == key
			end)
			-- The fill stays unless a different box is open.
			local cardIn = reveal(function(use)
				local which = use(open)
				return which == nil or which == key
			end)
			local text = scope:Computed(function(use)
				if key == "Rot" then
					return shortNumber(use(rotation))
				elseif key == "Pos" then
					local x, y = use(offsetX), use(offsetY)
					return if x == 0 and y == 0 then "0" else `{shortNumber(x)}, {shortNumber(y)}`
				end
				return shortNumber(use(stopAlpha) * 100)
			end)

			-- Closed: one third of the row (minus gaps). Open: the whole row.
			local closedWidth = 1 / count
			local closedWidthOffset = -gap * (count - 1) / count
			local closedX = (index - 1) / count
			local closedXOffset = (index - 1) * gap / count
			local full = openHeight(key)

			local card = scope:New("Frame")({
				Name = "Card",
				BackgroundColor3 = scope:Spring(
					scope:Computed(function(use)
						return if use(hovered) and use(open) == nil
							then use(theme.Colors.SurfaceContainerHigh)
							else use(theme.Colors.SurfaceContainer)
					end),
					30,
					1
				),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(0, theme.Metrics.RadiusSm) }),
				},
			}) :: Frame
			GroupFade.bind(scope, card, cardIn)

			local summary = scope:New("Frame")({
				Name = "Summary",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Visible = shown(summariesIn),
				[Children] = {
					scope:New("TextLabel")({
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(12, 0),
						Size = UDim2.new(0, 40, 1, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						FontFace = theme.Fonts.Body,
						TextSize = 13,
						TextColor3 = theme.Colors.OnSurfaceVariant,
						Text = key,
					}),
					scope:New("TextLabel")({
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(52, 0),
						Size = UDim2.new(1, -60, 1, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
						TextTruncate = Enum.TextTruncate.AtEnd,
						FontFace = theme.Typography.Label.Font,
						TextSize = 14,
						TextColor3 = theme.Colors.OnSurface,
						Text = text,
					}),
				},
			}) :: Frame
			GroupFade.bind(scope, summary, summariesIn)

			-- One value for all four sides.
			local padding = scope:Computed(function(use)
				return UDim.new(0, lerp(CLOSED_PAD, OPEN_PAD, math.clamp(use(g) :: number, 0, 1.2)))
			end)
			local column: { any } = {
				scope:New("UIListLayout")({
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = scope:Computed(function(use)
						return UDim.new(0, lerp(4, ROW_GAP, use(g) :: number))
					end),
				}),
				scope:New("UIPadding")({
					PaddingTop = padding,
					PaddingBottom = padding,
					PaddingLeft = padding,
					PaddingRight = padding,
				}),
			}
			for _, row in editors[key].build(scope) do
				table.insert(column, row)
			end
			local editor = scope:New("Frame")({
				Name = "Editor",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Visible = shown(g),
				[Children] = column,
			}) :: Frame
			GroupFade.bind(scope, editor, g)

			local openButton = scope:New("TextButton")({
				Name = "Open",
				Text = "",
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 4,
				Visible = scope:Computed(function(use)
					return use(open) == nil
				end),
				[OnEvent("Activated")] = function()
					open:set(key)
				end,
				[OnEvent("MouseEnter")] = function()
					hovered:set(true)
				end,
				[OnEvent("MouseLeave")] = function()
					hovered:set(false)
					pressed:set(false)
				end,
				[OnEvent("MouseButton1Down")] = function()
					pressed:set(true)
				end,
				[OnEvent("MouseButton1Up")] = function()
					pressed:set(false)
				end,
			}) :: TextButton
			tip(
				openButton,
				if key == "Rot"
					then "Rotation"
					elseif key == "Pos" then "Offset (X, Y)"
					else "Stop alpha"
			)

			return scope:New("Frame")({
				Name = key,
				BackgroundTransparency = 1,
				LayoutOrder = index,
				ZIndex = scope:Computed(function(use)
					return if use(open) == key then 3 else 1
				end),
				Visible = shown(cardIn),
				Position = scope:Computed(function(use)
					local t = use(g) :: number
					return UDim2.new(closedX * (1 - t), closedXOffset * (1 - t), 0, 0)
				end),
				Size = scope:Computed(function(use)
					local t = use(g) :: number
					return UDim2.new(
						lerp(closedWidth, 1, t),
						lerp(closedWidthOffset, 0, t),
						0,
						lerp(EDIT_ROW, full, t)
					)
				end),
				[Children] = {
					card,
					summary,
					editor,
					-- Press target while closed. Hidden once the editor is open.
					openButton :: any,
					scope:New("UIScale")({
						Scale = scope:Spring(
							scope:Computed(function(use)
								return if use(pressed) then 0.96 else 1
							end),
							40,
							0.8
						),
					}),
				},
			}) :: Frame
		end

		local boxes: { any } = {}
		for index, key in keys do
			table.insert(boxes, box(key, index))
		end

		-- Row height follows the open box.
		local fieldsHeight = scope:Spring(
			scope:Computed(function(use)
				local key = use(open)
				return if key then openHeight(key) else EDIT_ROW
			end),
			EXPAND_SPEED,
			EXPAND_DAMPING
		)
		local fields = scope:New("Frame")({
			Name = "Fields",
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Size = scope:Computed(function(use)
				return UDim2.new(1, 0, 0, use(fieldsHeight))
			end),
			[Children] = boxes,
		}) :: Frame

		-- Hex of the selected stop, with duplicate and delete
		local function actionButton(iconName: string, enabled: any, onClick: () -> ()): TextButton
			local pressed = scope:Value(false)
			return scope:New("TextButton")({
				Name = iconName,
				Text = "",
				AutoButtonColor = false,
				Size = UDim2.fromOffset(34, 34),
				BackgroundColor3 = theme.Colors.SurfaceContainer,
				BorderSizePixel = 0,
				[OnEvent("Activated")] = function()
					if peek(enabled) then
						onClick()
					end
				end,
				[OnEvent("MouseButton1Down")] = function()
					pressed:set(true)
				end,
				[OnEvent("MouseButton1Up")] = function()
					pressed:set(false)
				end,
				[OnEvent("MouseLeave")] = function()
					pressed:set(false)
				end,
				[Children] = ({
					scope:New("UICorner")({
						CornerRadius = UDim.new(0, theme.Metrics.RadiusSm),
					}),
					scope:New("UIScale")({
						Scale = scope:Spring(
							scope:Computed(function(use)
								return if use(pressed) and use(enabled) then 0.92 else 1
							end),
							40,
							0.8
						),
					}),
					scope:Apply(Icon(scope, {
						Theme = theme,
						Name = iconName,
						IconSize = 18,
						Color = theme.Colors.OnSurface,
					}))({
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						ImageTransparency = scope:Spring(
							scope:Computed(function(use)
								return if use(enabled) then 0 else 0.7
							end),
							30,
							1
						),
					}),
				} :: any) :: any,
			}) :: TextButton
		end

		local canRemove = scope:Computed(function(use)
			return #use(stops) > 2
		end)
		local hex = hexField(scope, function(use)
			return use(selectedStop).color
		end, function(c)
			setStopColor(peek(selected), c)
		end, 34)
		local hexGui = hex :: GuiObject
		hexGui.Size = UDim2.new(1, -(34 * 2 + gap * 2), 0, 34)
		hexGui.LayoutOrder = 1
		local duplicate = actionButton("copy", scope:Value(true), duplicateStop)
		duplicate.LayoutOrder = 2
		local delete = actionButton("trash-2", canRemove, removeStop)
		delete.LayoutOrder = 3
		tip(duplicate, "Duplicate stop")
		tip(delete, "Delete stop")

		gradientEditor = scope:New("Frame")({
			Name = "GradientEditor",
			BackgroundTransparency = 1,
			LayoutOrder = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			[Children] = {
				scope:New("UIListLayout")({
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, gap),
				}),
				scope:New("Frame")({
					Name = "BarHolder",
					BackgroundTransparency = 1,
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0, RAIL_H),
					[Children] = { rail },
				}),
				fields,
				scope:New("Frame")({
					Name = "HexRow",
					BackgroundTransparency = 1,
					LayoutOrder = 3,
					Size = UDim2.new(1, 0, 0, 34),
					[Children] = {
						scope:New("UIListLayout")({
							FillDirection = Enum.FillDirection.Horizontal,
							SortOrder = Enum.SortOrder.LayoutOrder,
							Padding = UDim.new(0, gap),
						}),
						hex,
						duplicate,
						delete,
					},
				}),
			},
		}) :: Frame
	end

	local r = theme.Metrics.RadiusPanel
	local editorPanel = scope:Frame({
		Name = "EditorPanel",
		BackgroundColor3 = theme.Colors.Surface,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Padding = { gap },
		[Children] = { gradientEditor },
	}) :: Frame

	-- Node editor: a ColorPicker on a darker fill, directly under the editor.
	local nodePicker = ColorPicker(scope, {
		Theme = theme,
		Value = stopColor,
		ShowAlpha = false,
		Footer = false,
		Background = theme.Colors.SurfaceDim,
		LayoutOrder = 2,
		Modes = props.Modes,
		Models = props.Models,
		Mode = props.Mode,
		Model = props.Model,
		Area = props.Area,
		Palette = props.Palette,
		OnChanged = function(c: Color3)
			setStopColor(peek(selected), c)
		end,
	}) :: Frame
	Corners.apply(editorPanel, r, r, 0, 0)
	Corners.apply(nodePicker, 0, 0, r, r)

	return scope:Frame({
		Name = "GradientPicker",
		BackgroundColor3 = theme.Colors.SurfaceDim,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		CornerRadius = r,
		Layout = { Kind = "List", Padding = 0, SortOrder = Enum.SortOrder.LayoutOrder },
		[Children] = { editorPanel, nodePicker },
	}) :: Frame
end
