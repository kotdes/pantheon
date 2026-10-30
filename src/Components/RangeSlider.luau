--!strict
--[[
	One track with two handles: the user picks a range. The bar between the handles is filled.
	Pressing the track moves the nearer handle there; the handles never cross.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
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

return function(scope: Types.Scope, props: Types.RangeSliderProps): Instance
	local theme = resolveTheme(props)
	-- The rail, the thumb and the touch area can be resized. The blueprint sets the default.
	local thumb = props.ThumbSize or Defaults.get(theme, "RangeSlider", "ThumbSize") or THUMB
	local thickness = props.Thickness or Defaults.get(theme, "RangeSlider", "Thickness") or 4
	local height = props.Height or math.max(40, thumb + 24)
	local edge = math.ceil(thumb * 0.85)
	local minBound = props.Min or 0
	local maxBound = props.Max or 1
	local step = props.Step or 0.01
	local span = math.max(maxBound - minBound, 1e-6)
	local disabled = peek(props.Disabled) == true

	local initial = peek(props.Value) or NumberRange.new(minBound, maxBound)
	local persistKey = Persist.key("RangeSlider", typeof(props.Value) == "table")
	local lo = Persist.value(scope, persistKey, "lo", initial.Min)
	local hi = Persist.value(scope, persistKey, "hi", initial.Max)
	Bind.linkParts(scope, props.Value, { lo, hi }, function(low: number, high: number)
		return NumberRange.new(low, high)
	end, function(range: NumberRange)
		return { range.Min, range.Max }
	end, function(a: NumberRange, b: NumberRange)
		return a.Min == b.Min and a.Max == b.Max
	end)

	local function emit()
		if props.OnChanged then
			props.OnChanged(NumberRange.new(peek(lo), peek(hi)))
		end
	end

	local function snap(value: number): number
		return math.clamp(math.floor(value / step + 0.5) * step, minBound, maxBound)
	end

	local function setHandle(which: number, value: number)
		value = snap(value)
		if which == 1 then
			value = math.min(value, peek(hi))
			if value ~= peek(lo) then
				lo:set(value)
				emit()
			end
		else
			value = math.max(value, peek(lo))
			if value ~= peek(hi) then
				hi:set(value)
				emit()
			end
		end
	end

	local function fraction(use: any, state: any): number
		return math.clamp((use(state) - minBound) / span, 0, 1)
	end

	local active = scope:Value(0)
	local lastActive = 1
	local grows = {
		scope:Spring(
			scope:Computed(function(use)
				return if use(active) == 1 then 1 else 0
			end),
			theme.Motion.SpringSpeed * 1.4,
			theme.Motion.SpringDamping
		),
		scope:Spring(
			scope:Computed(function(use)
				return if use(active) == 2 then 1 else 0
			end),
			theme.Motion.SpringSpeed * 1.4,
			theme.Motion.SpringDamping
		),
	}
	local ix = Interaction.bind(scope, theme, {
		Disabled = disabled,
		StateColor = theme.Colors.OnPrimary,
	})

	local function handle(which: number, state: any): Instance
		return scope:Frame({
			Name = if which == 1 then "ThumbLow" else "ThumbHigh",
			Size = scope:Computed(function(use)
				local grow = use(grows[which]) :: number
				local px = thumb * (1 + 0.12 * (use(ix.Hover) :: number) + 0.3 * grow)
				return UDim2.fromOffset(px, px)
			end),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = scope:Computed(function(use)
				return UDim2.new(fraction(use, state), 0, 0.5, 0)
			end),
			BackgroundColor3 = theme.Colors.Primary,
			CornerRadius = theme.Metrics.RadiusPill,
			ZIndex = 2 + which,
		})
	end

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
							local a, b = fraction(use, lo), fraction(use, hi)
							return UDim2.new(b - a, 0, 0, thickness)
						end),
						AnchorPoint = Vector2.new(0, 0.5),
						Position = scope:Computed(function(use)
							return UDim2.new(fraction(use, lo), 0, 0.5, 0)
						end),
						BackgroundColor3 = theme.Colors.Primary,
						BorderSizePixel = 0,
						CornerRadius = theme.Metrics.RadiusPill,
					}),
					handle(1, lo),
					handle(2, hi),
				},
			}),
		},
	}) :: TextButton
	ix.wire(bar)

	local trackInner = bar:FindFirstChild("TrackInner") :: Frame
	local function valueAt(x: number): number
		return minBound
			+ math.clamp(
					(x - trackInner.AbsolutePosition.X) / math.max(trackInner.AbsoluteSize.X, 1),
					0,
					1
				)
				* span
	end

	Focus.onKey(bar, function(input: InputObject): boolean
		local which = lastActive
		local current = peek(if which == 1 then lo else hi) :: number
		local target: number
		if input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.Down then
			target = current - step
		elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.Up then
			target = current + step
		elseif input.KeyCode == Enum.KeyCode.Home then
			target = minBound
		elseif input.KeyCode == Enum.KeyCode.End then
			target = maxBound
		else
			return false
		end
		setHandle(which, target)
		return true
	end)

	table.insert(
		scope,
		bar.InputBegan:Connect(function(input: InputObject)
			if
				disabled
				or (
					input.UserInputType ~= Enum.UserInputType.MouseButton1
					and input.UserInputType ~= Enum.UserInputType.Touch
				)
			then
				return
			end
			local at = valueAt(input.Position.X)
			local low, high = peek(lo) :: number, peek(hi) :: number
			local which: number
			if low == high then
				which = if at < low then 1 else 2
			else
				which = if math.abs(at - low) <= math.abs(at - high) then 1 else 2
			end
			lastActive = which
			active:set(which)
			setHandle(which, at)
			table.insert(
				scope,
				ScrollInput.capture(bar, function(changed: InputObject)
					return changed.UserInputType == Enum.UserInputType.MouseMovement
						or changed.UserInputType == Enum.UserInputType.Touch
				end, function(ended: InputObject)
					return ended.UserInputType == Enum.UserInputType.MouseButton1
						or ended.UserInputType == Enum.UserInputType.Touch
				end, function(pos: Vector3)
					setHandle(which, valueAt(pos.X))
				end, function()
					active:set(0)
				end)
			)
		end)
	)

	return scope:Frame({
		Name = "RangeSlider",
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
						return `{peek(props.Label) or ""} ({string.format("%.2f", use(lo))} – {string.format(
							"%.2f",
							use(hi)
						)})`
					end),
					Size = UDim2.new(1, 0, 0, 16),
					LayoutOrder = 1,
				})
				else nil,
			bar,
		},
	}) :: Frame
end
