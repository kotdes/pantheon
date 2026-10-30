--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local Motion = require(script.Parent.Parent.Internal.Motion)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Focus = require(script.Parent.Parent.Internal.Focus)
local Defaults = require(script.Parent.Parent.Internal.Defaults)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local ScrollInput = require(script.Parent.Parent.Internal.ScrollInput)

local Children = Fusion.Children
local peek = Fusion.peek

local THUMB = 16 -- default size of the thumb
local STRETCH_MAX = 10 -- hard limit on velocity stretch (px)

return function(scope: Types.Scope, props: Types.SliderProps): Instance
	local theme = resolveTheme(props)
	-- The rail, the thumb and the touch area can be resized. The blueprint sets the default.
	local thumb = props.ThumbSize or Defaults.get(theme, "Slider", "ThumbSize") or THUMB
	local thickness = props.Thickness or Defaults.get(theme, "Slider", "Thickness") or 4
	local height = props.Height or math.max(40, thumb + 24)
	local edge = math.ceil(thumb * 0.85)
	local minV = props.Min or 0
	local maxV = props.Max or 1
	local step = props.Step or 0.01
	local value = Persist.value(
		scope,
		Persist.key("Slider", typeof(props.Value) == "table"),
		"value",
		peek(props.Value) or minV
	)
	Bind.link(scope, props.Value, value)
	local dragging = scope:Value(0)
	local draggingS = Motion.spring(scope, dragging, theme, "Snappy")
	local stretch = scope:Value(0)
	local stretchS = Motion.spring(scope, stretch, theme, "Snappy", 1.6)
	local disabled = peek(props.Disabled) == true
	local ix = Interaction.bind(scope, theme, {
		Disabled = disabled,
		StateColor = theme.Colors.OnPrimary,
	})

	local range = math.max(maxV - minV, 1e-6)
	local stepCount = math.floor(range / step + 0.5)
	local showSteps = stepCount >= 1 and stepCount <= 24

	local function fraction(use: any): number
		return math.clamp((use(value) - minV) / range, 0, 1)
	end

	local ticks = {}
	if showSteps then
		for i = 0, stepCount do
			-- A tick appears as the thumb is picked up, and the ones the thumb has passed fill with
			-- the accent colour and grow a little.
			local passed = Motion.spring(
				scope,
				scope:Computed(function(use)
					return if i / stepCount <= fraction(use) + 1e-6 then 1 else 0
				end),
				theme,
				"Snappy",
				1.4
			)
			table.insert(
				ticks,
				scope:Frame({
					Name = "Tick",
					Size = scope:Computed(function(use)
						local lift = use(passed) :: number
						return UDim2.fromOffset(2 + lift * 0.6, 6 + lift * 3)
					end),
					BackgroundColor3 = scope:Computed(function(use)
						return Interaction.lerpColor(
							use(theme.Colors.OnSurfaceVariant),
							use(theme.Colors.Primary),
							math.clamp(use(passed) :: number, 0, 1),
							use
						)
					end),
					BackgroundTransparency = scope:Computed(function(use)
						return 1 - math.clamp(use(draggingS) :: number, 0, 1) * 0.8
					end),
					BorderSizePixel = 0,
					LayoutOrder = i + 1,
				})
			)
		end
	end

	local thumbSize = scope:Computed(function(use)
		local hoverN = use(ix.Hover) :: number
		local pressN = use(ix.Press) :: number
		local dragN = use(draggingS) :: number
		local grow = 1 + hoverN * 0.12 + pressN * 0.18 + dragN * 0.15
		local base = thumb * grow
		local sx = use(stretchS) :: number
		return UDim2.fromOffset(base + sx, math.max(base - sx * 0.35, base * 0.7))
	end)

	local bar = scope:TextButton({
		Name = "Track",
		Text = "",
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		AutoButtonColor = false,
		Active = not disabled,
		[Children] = {
			scope:Frame({
				Name = "TrackInner",
				BackgroundTransparency = 1,
				-- Keeps the thumb, with its hover and press growth, inside the control.
				Size = UDim2.new(1, -edge * 2, 1, 0),
				Position = UDim2.fromOffset(edge, 0),
				[Children] = {
					scope:Frame({
						Name = "Rail",
						Size = UDim2.new(1, 0, 0, thickness),
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 0, 0.5, 0),
						BackgroundColor3 = Interaction.trackColor(theme),
						BorderSizePixel = 0,
						CornerRadius = theme.Metrics.RadiusPill,
					}),
					scope:Frame({
						Name = "Fill",
						Size = scope:Computed(function(use)
							return UDim2.new(fraction(use), 0, 0, thickness)
						end),
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 0, 0.5, 0),
						BackgroundColor3 = theme.Colors.Primary,
						BorderSizePixel = 0,
						CornerRadius = theme.Metrics.RadiusPill,
					}),
					if showSteps
						then scope:Frame({
							Name = "Ticks",
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 8),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 0, 0.5, 14),
							[Children] = {
								scope:New("UIListLayout")({
									FillDirection = Enum.FillDirection.Horizontal,
									HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween,
									VerticalAlignment = Enum.VerticalAlignment.Center,
									SortOrder = Enum.SortOrder.LayoutOrder,
								}),
								ticks,
							},
						})
						else nil,
					scope:Frame({
						Name = "Thumb",
						Size = thumbSize,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = scope:Computed(function(use)
							return UDim2.new(fraction(use), 0, 0.5, 0)
						end),
						BackgroundColor3 = scope:Computed(function(use)
							return Interaction.lerpColor(
								use(theme.Colors.Primary),
								use(theme.Colors.OnPrimary),
								ix.alpha(use),
								use
							)
						end),
						CornerRadius = theme.Metrics.RadiusPill,
						ZIndex = 2,
					}),
				},
			}),
		},
	}) :: TextButton
	ix.wire(bar)
	-- Arrow keys move the focused slider by one step; Home and End jump to the ends.
	Focus.onKey(bar, function(input: InputObject): boolean
		local current = peek(value) :: number
		local target: number
		if input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.Down then
			target = current - step
		elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.Up then
			target = current + step
		elseif input.KeyCode == Enum.KeyCode.Home then
			target = minV
		elseif input.KeyCode == Enum.KeyCode.End then
			target = maxV
		else
			return false
		end
		target = math.clamp(math.floor(target / step + 0.5) * step, minV, maxV)
		value:set(target)
		if props.OnChanged then
			props.OnChanged(target)
		end
		return true
	end)

	local trackInner = bar:FindFirstChild("TrackInner") :: Frame

	table.insert(
		scope,
		bar.InputBegan:Connect(function(input)
			if disabled then
				return
			end
			if
				input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch
			then
				return
			end
			dragging:set(1)
			local lastX = input.Position.X
			local lastT = os.clock()

			local function apply(pos: Vector3)
				local now = os.clock()
				local dt = math.max(now - lastT, 1 / 240)
				local vel = (pos.X - lastX) / dt
				lastX = pos.X
				lastT = now
				stretch:set(math.clamp(math.abs(vel) * 0.01, 0, STRETCH_MAX))

				local target = trackInner
				local rel = math.clamp(
					(pos.X - target.AbsolutePosition.X) / math.max(target.AbsoluteSize.X, 1),
					0,
					1
				)
				local raw = minV + rel * range
				local stepped = math.floor(raw / step + 0.5) * step
				stepped = math.clamp(stepped, minV, maxV)
				value:set(stepped)
				if props.OnChanged then
					props.OnChanged(stepped)
				end
			end
			apply(input.Position)
			local stopCapture = ScrollInput.capture(
				bar,
				function(changed)
					return changed.UserInputType == Enum.UserInputType.MouseMovement
						or changed.UserInputType == Enum.UserInputType.Touch
				end,
				function(endedInput)
					return endedInput.UserInputType == Enum.UserInputType.MouseButton1
						or endedInput.UserInputType == Enum.UserInputType.Touch
				end,
				apply,
				function()
					dragging:set(0)
					stretch:set(0)
				end
			)
			table.insert(scope, stopCapture)
		end)
	)

	return scope:Frame({
		Name = "Slider",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.Space2xs,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			if props.Label
				then scope:TextLabel({
					BackgroundTransparency = 1,
					FontFace = theme.Typography.Label.Font,
					TextSize = theme.Typography.Label.Size,
					TextColor3 = theme.Colors.OnSurfaceVariant,
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = scope:Computed(function(use)
						return `{peek(props.Label) or ""} ({string.format("%.2f", use(value))})`
					end),
					Size = UDim2.new(1, 0, 0, 16),
					LayoutOrder = 1,
				})
				else nil,
			bar,
		},
	}) :: Frame
end
