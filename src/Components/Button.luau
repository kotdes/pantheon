--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Color = require(script.Parent.Parent.Internal.Color)
local Icon = require(script.Parent.Icon)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local function normalizeVariant(
	variant: string?,
	colorProp: Types.ColorInput?
): (string, Types.ColorInput?)
	local v = variant or "Filled"
	-- Legacy variants that encoded color
	if v == "Primary" then
		return "Filled", colorProp or "primary"
	end
	if v == "Destructive" then
		return "Filled", colorProp or "error"
	end
	if v == "Tonal" or v == "Outlined" or v == "Text" or v == "Filled" then
		return v, colorProp
	end
	return "Filled", colorProp
end

local function styleFromRole(
	style: string,
	role: Types.ThemeColorRole,
	theme: Types.Theme
): (Color3, Color3, number, boolean, Color3)
	if style == "Tonal" then
		return role.Container, role.OnContainer, 0, false, role.OnContainer
	end
	if style == "Outlined" then
		return theme.Colors.Surface, role.Base, 0, true, role.Base
	end
	if style == "Text" then
		return role.Base, role.Base, 1, false, role.Base
	end
	-- Filled
	return role.Base, role.OnBase, 0, false, role.OnBase
end

return function(scope: Types.Scope, props: Types.ButtonProps): Instance
	local theme = resolveTheme(props)
	local style, colorInput =
		normalizeVariant(props.Variant, peek(props.Color) :: Types.ColorInput?)
	local role = Color.resolve(colorInput, theme, "primary")
	local bg, fg, transparency, outlined, stateColor = styleFromRole(style, role, theme)
	local disabled = peek(props.Disabled) == true
	local padX = math.max(theme.Metrics.ButtonPadX, 8)
	local padY = math.max(theme.Metrics.ButtonPadY - 2, 2)
	local leading = props.LeadingIcon or props.Icon
	local trailing = props.TrailingIcon

	local ix = Interaction.bind(scope, theme, {
		Disabled = disabled,
		StateColor = stateColor,
	})

	-- Disabled: a darker fill than the surface and the label at 38%, for every variant.
	local disabledBg = scope:Computed(function(use)
		return Interaction.lerpColor(
			use(theme.Colors.Surface),
			use(theme.Colors.OnSurface),
			0.16,
			use
		)
	end)
	local disabledFg = theme.Colors.OnSurface

	local kids = {}
	if leading then
		table.insert(
			kids,
			scope:Apply(Icon(scope, {
				Theme = theme,
				Name = leading,
				IconSize = 18,
				Color = if disabled then disabledFg else fg,
			}))({
				LayoutOrder = 1,
				ImageTransparency = if disabled then 0.62 else 0,
			})
		)
	end
	local typeScale = theme.Typography.Button or theme.Typography.Label or theme.Typography.Body
	table.insert(
		kids,
		scope:TextLabel({
			BackgroundTransparency = 1,
			FontFace = typeScale.Font,
			TextSize = typeScale.Size,
			Text = props.Text or "Button",
			TextColor3 = if disabled then disabledFg else fg,
			TextTransparency = if disabled then 0.62 else 0,
			AutomaticSize = Enum.AutomaticSize.XY,
			LayoutOrder = 2,
		})
	)
	if trailing then
		table.insert(
			kids,
			scope:Apply(Icon(scope, {
				Theme = theme,
				Name = trailing,
				IconSize = 18,
				Color = if disabled then disabledFg else fg,
			}))({
				LayoutOrder = 3,
				ImageTransparency = if disabled then 0.62 else 0,
			})
		)
	end

	local button = scope:TextButton(P({
		Name = "Button",
		Text = "",
		AutoButtonColor = false,
		Active = not disabled,
		BackgroundColor3 = if disabled
			then disabledBg
			else (if transparency >= 1 then stateColor else ix.fill(bg)),
		BackgroundTransparency = if disabled
			then 0
			else (if transparency >= 1 then ix.fillTransparency(1) else transparency),
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = props.Size or UDim2.fromOffset(0, 40),
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		-- Clipping cuts UIStroke; only clip filled variants.
		ClipsDescendants = not outlined,
		CornerRadius = if props.CornerRadius then props.CornerRadius else theme.Metrics.RadiusPill,
		Padding = if props.Padding then props.Padding else { padY, padX },
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = if props.HorizontalAlignment
				then props.HorizontalAlignment
				else Enum.HorizontalAlignment.Center,
			Padding = 6,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		Outline = if outlined and not disabled
			then {
				Color = role.Base,
				Thickness = 1,
				Mode = Enum.ApplyStrokeMode.Border,
			}
			else nil,
		[OnEvent("Activated")] = if disabled then nil else props.OnClick,
		[Children] = kids,
	})) :: TextButton

	if not disabled then
		ix.wire(button)
	end
	return button
end
