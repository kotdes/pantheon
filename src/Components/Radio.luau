--!strict
--[[
	Radio button (single option).

	Animation: when becoming selected, the dot expands to the outer ring size,
	then settles to regular size while fading in.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.RadioProps): Instance
	local theme = resolveTheme(props)
	local disabled = peek(props.Disabled) == true

	local checked = scope:Computed(function(use)
		return use(props.Checked) == true
	end)

	-- Ring reacts immediately; dot uses a 2-stage sequence.
	local checkedN = scope:Computed(function(use)
		return if use(checked) then 1 else 0
	end)

	local selectedRingS =
		scope:Spring(checkedN, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
	local ix = Interaction.bind(scope, theme, {
		Disabled = disabled,
		StateColor = theme.Colors.OnSurface,
	})

	local dotBurstV = scope:Value(0)
	local dotBurstS =
		scope:Spring(dotBurstV, theme.Motion.SpringSpeed * 1.3, theme.Motion.SpringDamping)

	table.insert(
		scope,
		scope:Observer(checked):onChange(function(isOn)
			if isOn then
				-- Temporary "full-size" burst to outer ring, then settle.
				dotBurstV:set(1)
				task.delay(0.075, function()
					if peek(checked) then
						dotBurstV:set(0)
					end
				end)
			else
				dotBurstV:set(0)
			end
		end)
	)

	local outer = scope:Frame({
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = scope:Computed(function(use)
			local base = use(theme.Colors.Surface)
			return Interaction.lerpColor(base, use(theme.Colors.OnSurface), ix.alpha(use), use)
		end),
		CornerRadius = theme.Metrics.RadiusPill,
		LayoutOrder = 1,
		Outline = {
			Color = scope:Computed(function(use)
				return Interaction.lerpColor(
					use(theme.Colors.Outline),
					use(theme.Colors.Primary),
					use(selectedRingS),
					use
				)
			end),
			Thickness = 2,
			Mode = Enum.ApplyStrokeMode.Border,
		},
		[Children] = {
			scope:Frame({
				Name = "Dot",
				Size = scope:Computed(function(use)
					-- Base: 10px when selected. Burst adds up to +10px (total 20px).
					local base = use(selectedRingS) :: number
					local burst = (use(dotBurstS) :: number) * base
					local s = 10 * math.clamp(base + burst, 0, 2)
					return UDim2.fromOffset(s, s)
				end),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				BackgroundColor3 = theme.Colors.Primary,
				BackgroundTransparency = scope:Computed(function(use)
					return 1 - use(selectedRingS)
				end),
				CornerRadius = theme.Metrics.RadiusPill,
			}),
		},
	})

	local row = scope:TextButton(P({
		Name = "Radio",
		Text = "",
		BackgroundColor3 = theme.Colors.OnSurface,
		BackgroundTransparency = ix.fillTransparency(1),
		Size = props.Size or UDim2.new(1, 0, 0, 40),
		LayoutOrder = props.LayoutOrder or 0,
		AutoButtonColor = false,
		Active = not disabled,
		CornerRadius = theme.Metrics.RadiusSm,
		Padding = { theme.Metrics.Space2xs, theme.Metrics.SpaceXs },
		[OnEvent("Activated")] = function()
			if disabled then
				return
			end
			if props.OnClick then
				props.OnClick()
			end
		end,
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = theme.Metrics.SpaceSm,
		},
		[Children] = {
			outer,
			scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Body.Font,
				TextSize = theme.Typography.Body.Size,
				TextColor3 = theme.Colors.OnSurface,
				Text = scope:Computed(function(use)
					return use(props.Label) or ""
				end),
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
			}),
		},
	}))

	ix.wire(row)
	return row
end
