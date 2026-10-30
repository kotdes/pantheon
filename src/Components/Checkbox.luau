--!strict
--[[
	Animated checkmark: strokes grow along their axes (short \ then long /).
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local Motion = require(script.Parent.Parent.Internal.Motion)
local Defaults = require(script.Parent.Parent.Internal.Defaults)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.CheckboxProps): Instance
	local theme = resolveTheme(props)
	local persistKey = Persist.key("Checkbox", typeof(props.Checked) == "table")
	local checked = Persist.value(scope, persistKey, "checked", peek(props.Checked) == true)
	Bind.link(scope, props.Checked, checked)
	local checkedS = Motion.spring(
		scope,
		scope:Computed(function(use)
			return if use(checked) then 1 else 0
		end),
		theme,
		"Snappy"
	)
	local draw = Motion.spring(
		scope,
		scope:Computed(function(use)
			return if use(checked) then 1 else 0
		end),
		theme,
		"Snappy",
		1.15
	)
	local bounce = Motion.spring(
		scope,
		scope:Computed(function(use)
			return if use(checked) then 1 else 0
		end),
		theme,
		"Snappy",
		1.3
	)
	local disabled = peek(props.Disabled) == true
	-- Without an outline, an empty box is a tonal fill, so it can still be seen.
	local outlined = Defaults.outlined(theme, "Checkbox", props.Outlined)
	local ix = Interaction.bind(scope, theme, {
		Disabled = disabled,
		StateColor = theme.Colors.OnSurface,
	})

	local fillColor = scope:Computed(function(use)
		local t = use(checkedS)
		local base = Interaction.lerpColor(
			use(if outlined then theme.Colors.Surface else theme.Colors.SurfaceContainerHigh),
			use(theme.Colors.Primary),
			t,
			use
		)
		if disabled then
			return Interaction.lerpColor(base, use(theme.Colors.SurfaceDim), 0.5, use)
		end
		local state = if t > 0.5 then use(theme.Colors.OnPrimary) else use(theme.Colors.OnSurface)
		return Interaction.lerpColor(base, state, ix.alpha(use), use)
	end)

	local shortProgress = scope:Computed(function(use)
		return math.clamp((use(draw) :: number) / 0.4, 0, 1)
	end)
	local longProgress = scope:Computed(function(use)
		return math.clamp(((use(draw) :: number) - 0.28) / 0.72, 0, 1)
	end)

	local stroke = theme.Colors.OnPrimary
	local box = scope:TextButton(P({
		Name = "Box",
		Text = "",
		Size = UDim2.fromOffset(24, 24),
		BackgroundColor3 = fillColor,
		BackgroundTransparency = if disabled then 0.35 else 0,
		AutoButtonColor = false,
		Active = not disabled,
		LayoutOrder = 1,
		CornerRadius = 4,
		Outline = if outlined
			then {
				Color = scope:Computed(function(use)
					local c = Interaction.lerpColor(
						use(theme.Colors.Outline),
						use(theme.Colors.Primary),
						use(checkedS),
						use
					)
					return if disabled then use(theme.Colors.OutlineVariant) else c
				end),
				Thickness = 1.5,
				Transparency = if disabled then 0.35 else 0,
				Mode = Enum.ApplyStrokeMode.Border,
			}
			else nil,
		[OnEvent("Activated")] = function()
			if disabled then
				return
			end
			local nextValue = not peek(checked)
			checked:set(nextValue)
			if props.OnChanged then
				props.OnChanged(nextValue)
			end
		end,
		[Children] = {
			scope:New("Frame")({
				Name = "Check",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				[Children] = {
					scope:New("Frame")({
						Name = "ShortHost",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.fromScale(1, 1),
						[Children] = {
							scope:New("Frame")({
								Name = "ShortArm",
								BackgroundColor3 = stroke,
								BorderSizePixel = 0,
								AnchorPoint = Vector2.new(1, 1),
								Position = UDim2.new(0.46, 0, 0.68, 0),
								Rotation = 42,
								Size = scope:Computed(function(use)
									return UDim2.fromOffset(6 * use(shortProgress), 1)
								end),
								BackgroundTransparency = scope:Computed(function(use)
									return if use(shortProgress) < 0.04 then 1 else 0
								end),
							}),
						},
					}),
					scope:New("Frame")({
						Name = "LongHost",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.fromScale(1, 1),
						[Children] = {
							scope:New("Frame")({
								Name = "LongArm",
								BackgroundColor3 = stroke,
								BorderSizePixel = 0,
								AnchorPoint = Vector2.new(0, 1),
								Position = UDim2.new(0.36, 0, 0.57, 0),
								Rotation = -48,
								Size = scope:Computed(function(use)
									return UDim2.fromOffset(13 * use(longProgress), 1)
								end),
								BackgroundTransparency = scope:Computed(function(use)
									return if use(longProgress) < 0.04 then 1 else 0
								end),
							}),
						},
					}),
				},
			}),
		},
	}))
	ix.wire(box)

	local scale = Instance.new("UIScale")
	scale.Parent = box
	table.insert(
		scope,
		scope:Observer(bounce):onBind(function()
			local t = peek(bounce)
			scale.Scale = 1 + (1 - math.abs(t * 2 - 1)) * 0.08 * (if peek(checked) then 1 else 0.4)
		end)
	)

	return scope:Frame({
		Name = "Checkbox",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = props.Size,
		LayoutOrder = props.LayoutOrder or 0,
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = theme.Metrics.SpaceXs,
		},
		[Children] = {
			box,
			if props.Label
				then scope:TextLabel({
					BackgroundTransparency = 1,
					FontFace = theme.Typography.Body.Font,
					TextSize = theme.Typography.Body.Size,
					TextColor3 = if disabled
						then theme.Colors.OnSurfaceVariant
						else theme.Colors.OnSurface,
					TextTransparency = if disabled then 0.35 else 0,
					Text = props.Label,
					AutomaticSize = Enum.AutomaticSize.XY,
					LayoutOrder = 2,
				})
				else nil,
		},
	}) :: Frame
end
