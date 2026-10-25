--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Icon = require(script.Parent.Icon)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

--[[
	A message on a contrasting surface. In order, from the start: `Leading` (or `Icon`), the
	message, the action button, `Trailing` and the dismiss button.
]]
return function(scope: Types.Scope, props: Types.SnackbarProps): Instance
	local theme = resolveTheme(props)
	local fill = props.Fill == true

	local leading: any = nil
	if props.Leading then
		leading = scope:Apply(props.Leading)({ LayoutOrder = 1 })
	elseif props.Icon then
		leading = scope:Apply(Icon(scope, {
			Theme = theme,
			Name = props.Icon,
			IconSize = 20,
			Color = theme.Colors.InverseOnSurface,
		}))({ LayoutOrder = 1 })
	end

	local message = scope:TextLabel({
		BackgroundTransparency = 1,
		FontFace = theme.Fonts.Body,
		TextSize = A.size(theme, 14),
		TextColor3 = theme.Colors.InverseOnSurface,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = fill,
		Text = props.Message,
		AutomaticSize = if fill then Enum.AutomaticSize.Y else Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(0, 0),
		LayoutOrder = 2,
		[Children] = if fill
			then { scope:New("UIFlexItem")({ FlexMode = Enum.UIFlexMode.Fill }) }
			else nil,
	})

	-- Text button in the inverse accent; the standard Button's colours assume a normal
	-- surface and would be unreadable here.
	local action: any = nil
	if props.ActionText then
		action = scope:New("TextButton")({
			Name = "Action",
			LayoutOrder = 3,
			AutoButtonColor = true,
			BackgroundColor3 = theme.Colors.InversePrimary,
			BackgroundTransparency = 0.88,
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.fromOffset(0, 0),
			FontFace = theme.Typography.Label.Font,
			TextSize = A.size(theme, 14),
			TextColor3 = theme.Colors.InversePrimary,
			Text = props.ActionText,
			[OnEvent("Activated")] = function()
				if props.OnAction then
					props.OnAction()
				end
			end,
			[Children] = {
				scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
				scope:New("UIPadding")({
					PaddingTop = UDim.new(0, 6),
					PaddingBottom = UDim.new(0, 6),
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
				}),
			} :: any,
		})
	end

	local trailing: any = nil
	if props.Trailing then
		trailing = scope:Apply(props.Trailing)({ LayoutOrder = 4 })
	end

	local dismiss: any = nil
	if props.Dismissible then
		dismiss = scope:New("TextButton")({
			Name = "Dismiss",
			LayoutOrder = 5,
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = theme.Colors.InverseOnSurface,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(28, 28),
			[OnEvent("Activated")] = function()
				if props.OnClose then
					props.OnClose()
				end
			end,
			[Children] = {
				scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
				scope:Apply(Icon(scope, {
					Theme = theme,
					Name = "x",
					IconSize = 16,
					Color = theme.Colors.InverseOnSurface,
				}))({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
				}),
			} :: any,
		})
	end

	return scope:Frame({
		Name = "Snackbar",
		-- Contrasting surface: dark in light mode, light in dark mode.
		BackgroundColor3 = theme.Colors.InverseSurface,
		AutomaticSize = if fill then Enum.AutomaticSize.Y else Enum.AutomaticSize.XY,
		Size = props.Size or (if fill then UDim2.new(1, 0, 0, 0) else nil),
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex or 90,
		CornerRadius = theme.Metrics.RadiusPanel,
		Shadow = {
			BlurRadius = 20,
			Offset = UDim2.fromOffset(0, 6),
			Transparency = 0.65,
		},
		Padding = { theme.Metrics.SpaceMd },
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = theme.Metrics.SpaceSm,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = { leading, message, action, trailing, dismiss } :: any,
	}) :: Frame
end
