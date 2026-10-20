--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local TRACK_W = 52
local TRACK_H = 32
local THUMB = 24
local INSET = 4

return function(scope: Types.Scope, props: Types.SwitchProps): Instance
	local theme = resolveTheme(props)
	local persistKey = Persist.key("Switch", typeof(props.Checked) == "table")
	local checked = Persist.value(scope, persistKey, "checked", peek(props.Checked) == true)
	Bind.link(scope, props.Checked, checked)
	local disabled = peek(props.Disabled) == true
	local showIcons = if props.Icons ~= nil
		then props.Icons == true
		else (theme.Controls and theme.Controls.SwitchIcons) ~= false

	local checkedS = scope:Spring(
		scope:Computed(function(use)
			return if use(checked) then 1 else 0
		end),
		theme.Motion.SpringSpeed * 0.95,
		theme.Motion.SpringDamping
	)

	local stretch = scope:Value(0)
	local stretchS =
		scope:Spring(stretch, theme.Motion.SpringSpeed * 1.4, theme.Motion.SpringDamping)

	local ix = Interaction.bind(scope, theme, {
		Disabled = disabled,
		StateColor = theme.Colors.OnSurface,
	})

	local function commit(nextValue: boolean)
		if peek(checked) == nextValue then
			return
		end
		stretch:set(8)
		checked:set(nextValue)
		task.delay(0.06, function()
			stretch:set(0)
		end)
		if props.OnChanged then
			props.OnChanged(nextValue)
		end
	end

	local trackColor = scope:Computed(function(use)
		local t = use(checkedS)
		-- Off state: clearer outline track (not washed into surface)
		local off = use(theme.Colors.SurfaceContainer)
		local on = use(theme.Colors.Primary)
		local base = Interaction.lerpColor(off, on, t, use)
		if disabled then
			return Interaction.lerpColor(base, use(theme.Colors.SurfaceDim), 0.45, use)
		end
		local state = if t > 0.5 then use(theme.Colors.OnPrimary) else use(theme.Colors.OnSurface)
		return Interaction.lerpColor(base, state, ix.alpha(use), use)
	end)

	local thumbColor = scope:Computed(function(use)
		local t = use(checkedS)
		-- Off thumb: solid OnSurface for contrast against track
		local base = Interaction.lerpColor(
			use(theme.Colors.OnSurfaceVariant),
			use(theme.Colors.OnPrimary),
			t,
			use
		)
		if disabled then
			return Interaction.lerpColor(base, use(theme.Colors.Outline), 0.35, use)
		end
		return base
	end)

	-- Same diameter on/off; only brief squash/stretch on press & toggle.
	local thumbSize = scope:Computed(function(use)
		local pressN = use(ix.Press) :: number
		local extra = (use(stretchS) :: number) + pressN * 2.5
		local w = THUMB + extra
		local h = THUMB - math.clamp(extra * 0.15, 0, 2.5)
		return UDim2.fromOffset(w, h)
	end)

	local thumbPos = scope:Computed(function(use)
		local w = THUMB + (use(stretchS) :: number)
		local travel = TRACK_W - INSET * 2 - w
		return UDim2.new(0, INSET + (use(checkedS) :: number) * travel, 0.5, 0)
	end)

	local trackChildren: { any } = {}
	if showIcons then
		-- iOS “Show On/Off Labels”: I on the left (on), O on the right (off)
		table.insert(
			trackChildren,
			scope:TextLabel({
				Name = "IconOn",
				BackgroundTransparency = 1,
				Text = "I",
				FontFace = theme.Fonts.Heading,
				TextSize = 12,
				TextColor3 = theme.Colors.OnPrimary,
				TextTransparency = scope:Computed(function(use)
					local t = use(checkedS)
					local base = 1 - t
					return if disabled then math.min(base + 0.35, 1) else base
				end),
				Size = UDim2.fromOffset(14, 14),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0, INSET + 10, 0.5, 0),
				ZIndex = 1,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			})
		)
		table.insert(
			trackChildren,
			scope:TextLabel({
				Name = "IconOff",
				BackgroundTransparency = 1,
				Text = "O",
				FontFace = theme.Fonts.Heading,
				TextSize = 11,
				TextColor3 = theme.Colors.OnSurfaceVariant,
				TextTransparency = scope:Computed(function(use)
					local t = use(checkedS) :: number
					local base = t
					return if disabled then math.min(base + 0.35, 1) else base
				end),
				Size = UDim2.fromOffset(14, 14),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(1, -(INSET + 10), 0.5, 0),
				ZIndex = 1,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
			})
		)
	end
	table.insert(
		trackChildren,
		scope:Frame({
			Name = "Thumb",
			Size = thumbSize,
			BackgroundColor3 = thumbColor,
			BackgroundTransparency = if disabled then 0.25 else 0,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = thumbPos,
			CornerRadius = theme.Metrics.RadiusPill,
			ZIndex = 2,
		})
	)

	local track = scope:TextButton(P({
		Name = "Track",
		Text = "",
		Size = UDim2.fromOffset(TRACK_W, TRACK_H),
		BackgroundColor3 = trackColor,
		BackgroundTransparency = if disabled then 0.35 else 0,
		AutoButtonColor = false,
		Active = not disabled,
		LayoutOrder = 1,
		CornerRadius = theme.Metrics.RadiusPill,
		-- Keep stroke visible (ClipsDescendants clips UIStroke on the same instance).
		ClipsDescendants = false,
		Outline = {
			Color = scope:Computed(function(use)
				local c = Interaction.lerpColor(
					use(theme.Colors.Outline),
					use(theme.Colors.Primary),
					use(checkedS),
					use
				)
				return if disabled then use(theme.Colors.OutlineVariant) else c
			end),
			Thickness = 2,
			Transparency = if disabled then 0.45 else 0.15,
			Mode = Enum.ApplyStrokeMode.Border,
		},
		[OnEvent("Activated")] = function()
			if not disabled then
				commit(not peek(checked))
			end
		end,
		[Children] = trackChildren,
	}))
	ix.wire(track)

	return scope:Frame({
		Name = "Switch",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = props.LayoutOrder or 0,
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = theme.Metrics.SpaceXs,
		},
		[Children] = {
			track,
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
				})
				else nil,
		},
	}) :: Frame
end
