--!strict
--[[
	Single colour picker. GradientPicker uses it for the selected stop.
	See docs/Components/Pickers/ColorPicker.md.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local HSV = require(script.Parent.Parent.Internal.Picker.HSV)
local ColorSpaces = require(script.Parent.Parent.Internal.Picker.ColorSpaces)
local Drag = require(script.Parent.Parent.Internal.Picker.Drag)
local GroupFade = require(script.Parent.Parent.Internal.GroupFade)
local Features = require(script.Parent.Parent.Internal.Features)
local Flags = require(script.Parent.Parent.Internal.Flags)
local SegmentedControl = require(script.Parent.SegmentedControl)
local Widgets = require(script.Parent.Parent.Internal.Picker.Widgets)
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local tr = require(script.Parent.Parent.Internal.Translate).t

local DEFAULT_MODES = { "Grid", "Spectrum", "Sliders" }
local DEFAULT_MODELS = { "RGB", "HSB", "HSL", "LAB", "Hex" }

local PANEL_SPEED = 14 -- spring speed for panel fade / scale / height (critically damped)

local function rgb255(color: Color3): (number, number, number)
	return math.floor(color.R * 255 + 0.5),
		math.floor(color.G * 255 + 0.5),
		math.floor(color.B * 255 + 0.5)
end

local function hueSequence(saturation: number, value: number): ColorSequence
	local keys: { ColorSequenceKeypoint } = {}
	for i = 0, 6 do
		table.insert(
			keys,
			ColorSequenceKeypoint.new(i / 6, Color3.fromHSV((i % 6) / 6, saturation, value))
		)
	end
	return ColorSequence.new(keys)
end

local function twoStop(a: Color3, b: Color3): ColorSequence
	return ColorSequence.new(a, b)
end

--- Sample `count` evenly spaced colours of a function of 0..1 into a sequence.
local function sampled(count: number, at: (t: number) -> Color3): ColorSequence
	local keys: { ColorSequenceKeypoint } = {}
	for i = 0, count - 1 do
		local t = i / (count - 1)
		table.insert(keys, ColorSequenceKeypoint.new(t, at(t)))
	end
	return ColorSequence.new(keys)
end

-- Component
return function(scope: Types.Scope, props: Types.ColorPickerProps): Instance
	local theme = resolveTheme(props)
	local modes: { string } = props.Modes or DEFAULT_MODES
	local models: { string } = props.Models or DEFAULT_MODELS
	local showAlpha = props.ShowAlpha ~= false
	local gap = theme.Metrics.SpaceSm

	local initial: Color3 = peek(props.Value) or Color3.fromRGB(0, 105, 92)
	local h0, s0, v0 = HSV.fromColor3(initial)
	-- Colour and view state survive a rebuild when the app provides a Persist store (unless the
	-- colour is controlled from outside).
	local persistKey = Persist.key("ColorPicker", typeof(props.Value) == "table")
	local h = Persist.value(scope, persistKey, "h", h0)
	local s = Persist.value(scope, persistKey, "s", s0)
	local v = Persist.value(scope, persistKey, "v", v0)
	local alpha = Persist.value(scope, persistKey, "alpha", peek(props.Alpha) or 1)
	local mode = Persist.value(scope, persistKey, "mode", props.Mode or modes[1])
	local model = Persist.value(scope, persistKey, "model", props.Model or models[1])

	local color = scope:Computed(function(use)
		return HSV.toColor3(use(h), use(s), use(v))
	end)

	-- Change plumbing
	local function emit()
		local current = HSV.toColor3(peek(h), peek(s), peek(v))
		-- A Value passed in follows the picker.
		if Bind.isWritable(props.Value) and peek(props.Value) ~= current then
			(props.Value :: any):set(current)
		end
		if Bind.isWritable(props.Alpha) and peek(props.Alpha) ~= peek(alpha) then
			(props.Alpha :: any):set(peek(alpha))
		end
		if props.OnChanged then
			props.OnChanged(current)
		end
		if props.OnAlphaChanged then
			props.OnAlphaChanged(peek(alpha))
		end
	end

	--- Grey has no hue and black has no saturation, so keep the previous values.
	--- Otherwise dragging a slider to 0 would snap the others to red.
	local function setColor(c: Color3)
		local nh, ns, nv = HSV.fromColor3(c)
		if ns < 1e-4 or nv < 1e-4 then
			nh = peek(h)
		end
		if nv < 1e-4 then
			ns = peek(s)
		end
		h:set(nh)
		s:set(ns)
		v:set(nv)
		emit()
	end

	local function setAlpha(a: number)
		alpha:set(math.clamp(a, 0, 1))
		emit()
	end

	local function approxEqual(a: Color3, b: Color3): boolean
		return math.abs(a.R - b.R) + math.abs(a.G - b.G) + math.abs(a.B - b.B) < 0.004
	end
	if typeof(props.Value) == "table" then
		table.insert(
			scope,
			scope:Observer(props.Value :: any):onChange(function()
				local incoming = peek(props.Value) :: Color3
				if incoming and not approxEqual(incoming, peek(color)) then
					local nh, ns, nv = HSV.fromColor3(incoming)
					if ns >= 1e-4 and nv >= 1e-4 then
						h:set(nh)
					end
					s:set(ns)
					v:set(nv)
				end
			end)
		)
	end
	if typeof(props.Alpha) == "table" then
		table.insert(
			scope,
			scope:Observer(props.Alpha :: any):onChange(function()
				local incoming = peek(props.Alpha) :: number
				if incoming and math.abs(incoming - peek(alpha)) > 0.002 then
					alpha:set(incoming)
				end
			end)
		)
	end

	-- Building blocks
	local W = Widgets.new(theme, color)
	local checker, channel, hexField = W.checker, W.channel, W.hexField
	local TRACK_HEIGHT = W.TRACK_HEIGHT
	--- Handle for the saturation/value area and the hue ring. Grows from `rest` to `grown` px
	--- while held, like the slider thumbs.
	local function ringThumb(
		sc: any,
		position: any,
		fill: any,
		held: any,
		rest: number,
		grown: number
	): Frame
		local grow = sc:Spring(
			sc:Computed(function(use)
				return if use(held) then 1 else 0
			end),
			32,
			0.7
		)
		return sc:New("Frame")({
			Name = "Thumb",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = position,
			Size = sc:Computed(function(use)
				local px = rest + (grown - rest) * use(grow)
				return UDim2.fromOffset(px, px)
			end),
			BackgroundColor3 = fill or color,
			BorderSizePixel = 0,
			ZIndex = 3,
			[Children] = {
				sc:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
				sc:New("UIStroke")({
					Color = Color3.new(1, 1, 1),
					Thickness = 2.5,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				}),
				-- Shadow so the white ring shows on light colours.
				sc:New("UIShadow")({
					Color = Color3.new(0, 0, 0),
					Transparency = 0.55,
					BlurRadius = UDim.new(0, 5),
					Offset = UDim2.fromOffset(0, 1),
				}),
			},
		}) :: Frame
	end

	local function alphaChannel(sc: any, order: number): any
		if not showAlpha then
			return nil
		end
		return channel(sc, {
			label = tr("colorpicker.alpha", "Alpha"),
			min = 0,
			max = 100,
			get = function(use)
				return use(alpha) * 100
			end,
			set = function(n)
				setAlpha(n / 100)
			end,
			track = function(use)
				local c = use(color)
				return twoStop(c, c)
			end,
			alphaTrack = true,
			order = order,
		})
	end

	-- Panel: Spectrum
	local function saturationValueArea(sc: any, height: number?, name: string?): Frame
		local held = sc:Value(false)
		local area = sc:New("Frame")({
			Name = name or "SaturationValue",
			BackgroundColor3 = sc:Computed(function(use)
				return HSV.toColor3(use(h), 1, 1)
			end),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, height or 120),
			Active = true,
			[Children] = {
				sc:New("UICorner")({ CornerRadius = UDim.new(0, theme.Metrics.RadiusSm) }),
				-- white → clear, left to right
				sc:New("Frame")({
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					[Children] = {
						sc:New("UICorner")({ CornerRadius = UDim.new(0, theme.Metrics.RadiusSm) }),
						sc:New("UIGradient")({ Transparency = NumberSequence.new(0, 1) }),
					},
				}),
				-- clear → black, top to bottom
				sc:New("Frame")({
					BackgroundColor3 = Color3.new(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					[Children] = {
						sc:New("UICorner")({ CornerRadius = UDim.new(0, theme.Metrics.RadiusSm) }),
						sc:New("UIGradient")({
							Rotation = 90,
							Transparency = NumberSequence.new(1, 0),
						}),
					},
				}),
				ringThumb(
					sc,
					sc:Computed(function(use)
						return UDim2.fromScale(use(s), 1 - use(v))
					end),
					nil,
					held,
					14,
					26
				),
			},
		}) :: Frame
		Drag.bind(
			sc,
			area,
			function(x: number, y: number)
				s:set(x)
				v:set(1 - y)
				emit()
			end,
			nil,
			function(down: boolean)
				held:set(down)
			end
		)
		return area
	end

	--- Hue ring (conical gradient) around a saturation/value square.
	local function wheelArea(sc: any): { any }
		local D = 168
		local T = 18
		local inner = (D - 2 * T) * 0.7
		local mid = (D - T) / 2

		local ringHeld = sc:Value(false)
		local ring = sc:New("Frame")({
			Name = "HueRing",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(D, D),
			Active = true,
			[Children] = {
				sc:New("Frame")({
					Name = "Ring",
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(T, T),
					Size = UDim2.new(1, -2 * T, 1, -2 * T),
					[Children] = {
						sc:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
						sc:New("UIStroke")({
							Thickness = T,
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = Color3.new(1, 1, 1),
							[Children] = {
								sc:New("UIGradient")({
									Type = "Conical",
									Rotation = Flags.ConicalRotation,
									Color = hueSequence(1, 1),
								}),
							},
						}),
					},
				}),
				ringThumb(
					sc,
					sc:Computed(function(use)
						local a = use(h) :: number
							* math.pi
							* 2
							* (if Flags.ConicalClockwise then 1 else -1)
						return UDim2.new(0.5, math.sin(a) * mid, 0.5, -math.cos(a) * mid)
					end),
					sc:Computed(function(use)
						return HSV.toColor3(use(h), 1, 1)
					end),
					ringHeld,
					12,
					T
				),
			},
		}) :: Frame

		Drag.bind(sc, ring, function(x: number, y: number)
			local angle = math.atan2(x - 0.5, -(y - 0.5))
			h:set((angle / (math.pi * 2) * (if Flags.ConicalClockwise then 1 else -1)) % 1)
			emit()
		end, function(x: number, y: number)
			-- Only the ring itself: ignore presses in the hole (the square handles those).
			local r = math.sqrt((x - 0.5) ^ 2 + (y - 0.5) ^ 2) * 2
			return r >= (D - 2 * T) / D - 0.02
		end, function(down: boolean)
			ringHeld:set(down)
		end)

		local square = saturationValueArea(sc, inner, "SaturationValue")
		square.AnchorPoint = Vector2.new(0.5, 0.5)
		square.Position = UDim2.fromScale(0.5, 0.5)
		square.Size = UDim2.fromOffset(inner, inner)
		square.ZIndex = 2
		square.Parent = ring

		return {
			sc:New("Frame")({
				Name = "WheelHolder",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, D),
				LayoutOrder = 1,
				[Children] = {
					sc:New("UIListLayout")({
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
					ring,
				},
			}),
			alphaChannel(sc, 2),
		}
	end

	local function spectrumPanel(sc: any): { any }
		if props.Area == "Wheel" and Features.gradientTypes() then
			return wheelArea(sc)
		end
		local area = saturationValueArea(sc, 112)
		area.LayoutOrder = 1
		return {
			area,
			channel(sc, {
				label = tr("colorpicker.hue", "Hue"),
				min = 0,
				max = 360,
				get = function(use)
					return use(h) * 360
				end,
				set = function(n)
					h:set(n / 360)
					emit()
				end,
				track = function()
					return hueSequence(1, 1)
				end,
				order = 2,
			}),
			alphaChannel(sc, 3),
		}
	end

	-- Panel: Grid
	local function swatches(): { Color3 }
		if props.Palette then
			return props.Palette
		end
		local list: { Color3 } = {}
		-- A grey ramp, then hues across with lightness stepping down.
		for i = 0, 11 do
			local g = 1 - i / 11
			table.insert(list, Color3.new(g, g, g))
		end
		for _, light in { 0.88, 0.76, 0.64, 0.52, 0.40, 0.28 } do
			for i = 0, 11 do
				local r, g, b = ColorSpaces.hslToRgb(i / 12, 0.78, light)
				table.insert(list, Color3.new(r, g, b))
			end
		end
		return list
	end

	local function gridPanel(sc: any): { any }
		local cells: { any } = {
			sc:New("UIGridLayout")({
				CellSize = UDim2.new(1 / 12, -4, 0, 22),
				CellPadding = UDim2.fromOffset(4, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}
		for index, swatchColor in swatches() do
			table.insert(
				cells,
				sc:New("TextButton")({
					Name = "Swatch",
					Text = "",
					AutoButtonColor = false,
					BackgroundColor3 = swatchColor,
					BorderSizePixel = 0,
					LayoutOrder = index,
					[OnEvent("Activated")] = function()
						setColor(swatchColor)
					end,
					[Children] = (
							{
								sc:New("UICorner")({
									CornerRadius = UDim.new(0, theme.Metrics.RadiusXs),
								}),
								sc:New("UIStroke")({
									Color = Color3.new(1, 1, 1),
									Thickness = 2.5,
									ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
									-- Ring the swatch that matches the current colour.
									Transparency = sc:Computed(function(use)
										local c = use(color) :: Color3
										local near = math.abs(c.R - swatchColor.R)
											+ math.abs(c.G - swatchColor.G)
											+ math.abs(c.B - swatchColor.B)
										return if near < 0.012 then 0 else 1
									end),
								}),
							} :: any
						) :: any,
				})
			)
		end
		return {
			sc:New("Frame")({
				Name = "Swatches",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 1,
				[Children] = cells,
			}),
			alphaChannel(sc, 2),
		}
	end

	-- Panel: Sliders (per model)
	local function rgbModel(sc: any): { any }
		local function withChannel(index: number, n: number): Color3
			local r, g, b = rgb255(peek(color))
			local values = { r, g, b }
			values[index] = math.floor(n + 0.5)
			return Color3.fromRGB(values[1], values[2], values[3])
		end
		local function row(index: number, label: string)
			return channel(sc, {
				label = label,
				min = 0,
				max = 255,
				get = function(use)
					local c = use(color)
					return (if index == 1 then c.R elseif index == 2 then c.G else c.B) * 255
				end,
				set = function(n)
					setColor(withChannel(index, n))
				end,
				track = function(use)
					local r, g, b = rgb255(use(color))
					local lo = { r, g, b }
					local hi = { r, g, b }
					lo[index], hi[index] = 0, 255
					return twoStop(
						Color3.fromRGB(lo[1], lo[2], lo[3]),
						Color3.fromRGB(hi[1], hi[2], hi[3])
					)
				end,
				order = index,
			})
		end
		return {
			row(1, tr("colorpicker.red", "Red")),
			row(2, tr("colorpicker.green", "Green")),
			row(3, tr("colorpicker.blue", "Blue")),
			alphaChannel(sc, 4),
		}
	end

	local function hsbModel(sc: any, brightnessLabel: string): { any }
		return {
			channel(sc, {
				label = tr("colorpicker.hue", "Hue"),
				min = 0,
				max = 360,
				get = function(use)
					return use(h) * 360
				end,
				set = function(n)
					h:set(n / 360)
					emit()
				end,
				track = function(use)
					-- Current saturation/value, floored so the rainbow doesn't go grey.
					return hueSequence(math.max(use(s), 0.3), math.max(use(v), 0.4))
				end,
				order = 1,
			}),
			channel(sc, {
				label = tr("colorpicker.saturation", "Saturation"),
				min = 0,
				max = 100,
				get = function(use)
					return use(s) * 100
				end,
				set = function(n)
					s:set(n / 100)
					emit()
				end,
				track = function(use)
					return twoStop(HSV.toColor3(use(h), 0, use(v)), HSV.toColor3(use(h), 1, use(v)))
				end,
				order = 2,
			}),
			channel(sc, {
				label = brightnessLabel,
				min = 0,
				max = 100,
				get = function(use)
					return use(v) * 100
				end,
				set = function(n)
					v:set(n / 100)
					emit()
				end,
				track = function(use)
					return twoStop(HSV.toColor3(use(h), use(s), 0), HSV.toColor3(use(h), use(s), 1))
				end,
				order = 3,
			}),
			alphaChannel(sc, 4),
		}
	end

	local function hslModel(sc: any): { any }
		local function hslOf(use: any): (number, number, number)
			local c = use(color)
			local _, sat, light = ColorSpaces.rgbToHsl(c.R, c.G, c.B)
			return use(h), sat, light
		end
		local function fromHsl(hue: number, sat: number, light: number): Color3
			local r, g, b = ColorSpaces.hslToRgb(hue, sat, light)
			return Color3.new(r, g, b)
		end
		return {
			channel(sc, {
				label = tr("colorpicker.hue", "Hue"),
				min = 0,
				max = 360,
				get = function(use)
					return use(h) * 360
				end,
				set = function(n)
					h:set(n / 360)
					emit()
				end,
				track = function(use)
					local _, sat, light = hslOf(use)
					return sampled(7, function(t)
						return fromHsl(t, sat, light)
					end)
				end,
				order = 1,
			}),
			channel(sc, {
				label = tr("colorpicker.saturation", "Saturation"),
				min = 0,
				max = 100,
				get = function(use)
					local _, sat = hslOf(use)
					return sat * 100
				end,
				set = function(n)
					local hue, _, light = hslOf(peek)
					setColor(fromHsl(hue, n / 100, light))
				end,
				track = function(use)
					local hue, _, light = hslOf(use)
					return twoStop(fromHsl(hue, 0, light), fromHsl(hue, 1, light))
				end,
				order = 2,
			}),
			channel(sc, {
				label = tr("colorpicker.lightness", "Lightness"),
				min = 0,
				max = 100,
				get = function(use)
					local _, _, light = hslOf(use)
					return light * 100
				end,
				set = function(n)
					local hue, sat = hslOf(peek)
					setColor(fromHsl(hue, sat, n / 100))
				end,
				track = function(use)
					local hue, sat = hslOf(use)
					return sampled(3, function(t)
						return fromHsl(hue, sat, t)
					end)
				end,
				order = 3,
			}),
			alphaChannel(sc, 4),
		}
	end

	local function labModel(sc: any): { any }
		local function labOf(use: any): (number, number, number)
			local c = use(color)
			return ColorSpaces.rgbToLab(c.R, c.G, c.B)
		end
		local function fromLab(l: number, a: number, b: number): Color3
			local r, g, bb = ColorSpaces.labToRgb(l, a, b)
			return Color3.new(r, g, bb)
		end
		return {
			channel(sc, {
				label = "L*",
				min = 0,
				max = 100,
				decimals = 1,
				get = function(use)
					return (labOf(use))
				end,
				set = function(n)
					local _, a, b = labOf(peek)
					setColor(fromLab(n, a, b))
				end,
				track = function(use)
					local _, a, b = labOf(use)
					return sampled(5, function(t)
						return fromLab(t * 100, a, b)
					end)
				end,
				order = 1,
			}),
			channel(sc, {
				label = "a*",
				min = -128,
				max = 127,
				decimals = 1,
				get = function(use)
					local _, a = labOf(use)
					return a
				end,
				set = function(n)
					local l, _, b = labOf(peek)
					setColor(fromLab(l, n, b))
				end,
				track = function(use)
					local l, _, b = labOf(use)
					return sampled(9, function(t)
						return fromLab(l, -128 + t * 255, b)
					end)
				end,
				order = 2,
			}),
			channel(sc, {
				label = "b*",
				min = -128,
				max = 127,
				decimals = 1,
				get = function(use)
					local _, _, b = labOf(use)
					return b
				end,
				set = function(n)
					local l, a = labOf(peek)
					setColor(fromLab(l, a, n))
				end,
				track = function(use)
					local l, a = labOf(use)
					return sampled(9, function(t)
						return fromLab(l, a, -128 + t * 255)
					end)
				end,
				order = 3,
			}),
			alphaChannel(sc, 4),
		}
	end

	local function hexModel(sc: any): { any }
		local field = hexField(sc, function(use)
			return use(color)
		end, setColor, 34)
		local fieldGui = field :: GuiObject
		fieldGui.LayoutOrder = 1
		return { field, alphaChannel(sc, 2) }
	end

	local function slidersPanel(sc: any, name: string): { any }
		if name == "RGB" then
			return rgbModel(sc)
		elseif name == "HSV" then
			return hsbModel(sc, tr("colorpicker.value", "Value"))
		elseif name == "HSB" then
			return hsbModel(sc, tr("colorpicker.brightness", "Brightness"))
		elseif name == "HSL" then
			return hslModel(sc)
		elseif name == "LAB" then
			return labModel(sc)
		end
		return hexModel(sc)
	end

	local function buildPanel(sc: any, key: string): { any }
		if key == "Grid" then
			return gridPanel(sc)
		elseif key == "Spectrum" then
			return spectrumPanel(sc)
		end
		-- "Sliders:<model>"
		return slidersPanel(sc, string.sub(key, 9))
	end

	-- Animated panel host
	-- Each panel lives in its own inner scope. Switching fades and scales the old one out and
	-- the new one in (GroupFade + UIScale), and springs the host's height between them.
	local heightTarget = scope:Value(0)
	local heightSpring = scope:Spring(heightTarget, 12, 1)
	local host = scope:New("Frame")({
		Name = "Panels",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		LayoutOrder = 3,
		Size = scope:Computed(function(use)
			return UDim2.new(1, 0, 0, math.max(use(heightSpring), 0))
		end),
	}) :: Frame

	type PanelRecord = { panel: Frame, inner: any, dead: { value: boolean }, reveal: any }
	local current: PanelRecord? = nil
	local measuredOnce = false

	local function showPanel(key: string, instant: boolean)
		local previous = current

		local inner = scope:innerScope()
		local dead = { value = false }
		table.insert(inner, function()
			dead.value = true
		end)
		local reveal = inner:Value(if instant then 1 else 0)
		local revealSpring = inner:Spring(reveal, PANEL_SPEED, 1)

		local layout = inner:New("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, gap),
		}) :: UIListLayout
		local panel = inner:New("Frame")({
			Name = `Panel_{key}`,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = inner:Computed(function(use)
				return UDim2.new(0.5, 0, 0, (1 - math.clamp(use(revealSpring) :: number, 0, 1)) * 8)
			end),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = host,
			[Children] = {
				layout,
				inner:New("UIScale")({
					Scale = inner:Computed(function(use)
						return 0.95 + 0.05 * math.clamp(use(revealSpring) :: number, 0, 1)
					end),
				}),
				buildPanel(inner, key) :: any,
			},
		}) :: Frame
		GroupFade.bind(inner, panel, revealSpring)

		local record: PanelRecord = { panel = panel, inner = inner, dead = dead, reveal = reveal }
		current = record
		if not instant then
			-- Start hidden (so it can fade in), then reveal on the next frame.
			task.defer(function()
				if not dead.value then
					reveal:set(1)
				end
			end)
		end

		local function measure()
			if current ~= record then
				return
			end
			-- The layout's content size is unaffected by the panel's UIScale.
			local height = layout.AbsoluteContentSize.Y
			if height > 0 then
				heightTarget:set(height)
				if not measuredOnce then
					measuredOnce = true;
					(heightSpring :: any):setPosition(height)
				end
			end
		end
		table.insert(inner, layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(measure))
		task.defer(measure)

		if previous then
			previous.reveal:set(0)
			task.delay(0.45, function()
				if not previous.dead.value then
					Fusion.doCleanup(previous.inner)
				end
			end)
		end
	end

	local panelKey = scope:Computed(function(use)
		local m = use(mode) :: string
		if m == "Sliders" then
			return "Sliders:" .. (use(model) :: string)
		end
		return m
	end)
	table.insert(
		scope,
		scope:Observer(panelKey):onChange(function()
			showPanel(peek(panelKey) :: string, false)
		end)
	)
	showPanel(peek(panelKey) :: string, true)

	-- Tabs, and the model chips that slide in under "Sliders"
	local tabItems = {}
	for _, id in modes do
		table.insert(tabItems, { Id = id, Label = tr("colorpicker." .. string.lower(id), id) })
	end
	local tabs = SegmentedControl(scope, {
		Theme = theme,
		Items = tabItems,
		Selected = mode,
		LayoutOrder = 1,
		OnChanged = function(id: string)
			mode:set(id)
		end,
	})

	local modelItems = {}
	for _, id in models do
		table.insert(modelItems, { Id = id, Label = tr("colorpicker." .. string.lower(id), id) })
	end
	local chipsReveal = scope:Spring(
		scope:Computed(function(use)
			return if use(mode) == "Sliders" then 1 else 0
		end),
		14,
		1
	)
	local chips = scope:New("Frame")({
		Name = "Models",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		LayoutOrder = 2,
		Visible = scope:Computed(function(use)
			return (use(chipsReveal) :: number) > 0.01
		end),
		Size = scope:Computed(function(use)
			return UDim2.new(1, 0, 0, 36 * math.clamp(use(chipsReveal) :: number, 0, 1))
		end),
		[Children] = {
			SegmentedControl(scope, {
				Theme = theme,
				Items = modelItems,
				Selected = model,
				OnChanged = function(id: string)
					model:set(id)
				end,
			}),
		},
	}) :: Frame
	GroupFade.bind(scope, chips, chipsReveal)

	-- Footer (single colour)
	local function swatch(sc: any, size: number, fill: any): Frame
		return sc:New("Frame")({
			Name = "Swatch",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(size, size),
			[Children] = {
				checker(sc, 6, 6, nil, nil, UDim.new(0, theme.Metrics.RadiusSm)),
				sc:New("Frame")({
					Name = "Fill",
					BackgroundColor3 = fill,
					BackgroundTransparency = sc:Computed(function(use)
						return 1 - use(alpha)
					end),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					[Children] = {
						sc:New("UICorner")({ CornerRadius = UDim.new(0, theme.Metrics.RadiusSm) }),
					},
				}),
			},
		}) :: Frame
	end

	local footer: Frame? = nil
	if props.Footer ~= false then
		local field = hexField(scope, function(use)
			return use(color)
		end, setColor)
		local fieldGui = field :: GuiObject
		fieldGui.Size = UDim2.new(1, -(40 + 52 + gap * 2), 0, TRACK_HEIGHT)
		fieldGui.LayoutOrder = 2
		footer = scope:New("Frame")({
			Name = "Footer",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 40),
			LayoutOrder = 4,
			[Children] = {
				scope:New("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, gap),
				}),
				swatch(scope, 40, color),
				field,
				scope:New("TextLabel")({
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(52, TRACK_HEIGHT),
					LayoutOrder = 3,
					FontFace = theme.Fonts.Body,
					TextSize = A.size(theme, 13),
					TextColor3 = theme.Colors.OnSurfaceVariant,
					Text = scope:Computed(function(use)
						return if showAlpha
							then `{math.floor((use(alpha) :: number) * 100 + 0.5)}%`
							else ""
					end),
				}),
			},
		}) :: Frame
	end

	return scope:Frame({
		Name = "ColorPicker",
		BackgroundColor3 = props.Background or theme.Colors.Surface,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		CornerRadius = theme.Metrics.RadiusPanel,
		Padding = { gap },
		Layout = { Kind = "List", Padding = gap, SortOrder = Enum.SortOrder.LayoutOrder },
		[Children] = { tabs, chips, host, footer :: any },
	}) :: Frame
end
