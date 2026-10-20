--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Color = require(script.Parent.Parent.Internal.Color)
local MenuNav = require(script.Parent.Parent.Internal.MenuNav)
local Icon = require(script.Parent.Icon)
local Tooltip = require(script.Parent.Tooltip)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local function resolveSlot(value: Types.MenuSlot?, iconAlias: string?): (string?, Instance?)
	if typeof(value) == "Instance" then
		return nil, value
	end
	if typeof(value) == "string" and value ~= "" then
		return value, nil
	end
	if typeof(iconAlias) == "string" and iconAlias ~= "" then
		return iconAlias, nil
	end
	return nil, nil
end

return function(scope: Types.Scope, props: Types.MenuButtonProps): Instance
	local theme = resolveTheme(props)
	local disabled = peek(props.Disabled) == true
	local compact = props.Compact ~= false
	local rowHeight = if compact then 40 else 44
	local hPad = if compact then theme.Metrics.SpaceSm else theme.Metrics.SpaceMd
	local vPad = if compact then theme.Metrics.SpaceXs else theme.Metrics.SpaceSm
	local iconSize = 18
	-- Hover/press whenever the row can activate (click, push page, or close).
	local clickable = not disabled
		and (props.OnClick ~= nil or props.Page ~= nil or props.OnClose ~= nil)

	local role = if props.Color ~= nil
		then Color.resolve(peek(props.Color) :: Types.ColorInput?, theme, "primary")
		else nil
	local baseFg = if disabled
		then theme.Colors.OnSurfaceVariant
		elseif role then role.Base
		else theme.Colors.OnSurface
	local stateColor = if role then role.Base else theme.Colors.OnSurface

	-- A selected row is filled with the primary container and drawn in its on-colour. It
	-- follows a state, so the row changes as the state does.
	local selected = props.Selected
	local fg: any = baseFg
	local fillBase: any = theme.Colors.Surface
	if selected ~= nil and not disabled then
		fg = scope:Computed(function(use)
			return if use(selected :: any) == true
				then use(theme.Colors.OnPrimaryContainer :: any)
				else use(baseFg :: any)
		end)
		fillBase = scope:Computed(function(use)
			return if use(selected :: any) == true
				then use(theme.Colors.SurfaceContainer :: any)
				else use(theme.Colors.Surface :: any)
		end)
		stateColor = theme.Colors.OnPrimaryContainer
	end

	-- A flat row has no fill until it is hovered or pressed. A selected row keeps its fill.
	local flat = props.Flat == true and props.Selected == nil

	local ix = Interaction.bind(scope, theme, {
		Disabled = not clickable,
		StateColor = stateColor,
	})

	local leadingName, leadingInst = resolveSlot(props.Leading, props.LeadingIcon)
	local trailingName, trailingInst = resolveSlot(props.Trailing, props.TrailingIcon)

	local btn: TextButton
	btn = scope:TextButton(P({
		Name = "MenuButton",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = if flat then stateColor else ix.fill(fillBase),
		BackgroundTransparency = if flat then ix.fillTransparency(1) else nil,
		Size = props.Size or UDim2.new(1, 0, 0, rowHeight),
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Active = clickable,
		ClipsDescendants = true,
		CornerRadius = theme.Metrics.RadiusPanel - 4,
		-- An element at the end, such as a count or a switch, sits as far from the edge as the row
		-- is from its top and bottom.
		Padding = if trailingName
			then { vPad, hPad }
			elseif trailingInst then { vPad, vPad, vPad, hPad }
			else { vPad, hPad / 2, vPad, hPad },
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = 8,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[OnEvent("Activated")] = function()
			if not clickable then
				return
			end
			if props.OnClick then
				props.OnClick()
			end
			if props.Page then
				local nav = MenuNav.from(btn)
				if nav then
					nav.push(props.Page)
				end
				return
			end
			if props.OnClose then
				props.OnClose()
			end
		end,
		[Children] = {
			-- Left: icon + label; fills remaining width
			scope:Frame({
				Name = "Left",
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 1, 0),
				LayoutOrder = 1,
				Flex = { FlexMode = Enum.UIFlexMode.Fill },
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = theme.Metrics.SpaceSm,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = {
					if leadingInst
						then scope:Apply(leadingInst)({ LayoutOrder = 1 })
						elseif leadingName then scope:Apply(Icon(scope, {
							Theme = theme,
							Name = leadingName,
							IconSize = iconSize,
							Color = fg,
						}))({
							LayoutOrder = 1,
							ImageTransparency = if disabled then 0.38 else 0,
						})
						else nil,
					scope:TextLabel({
						BackgroundTransparency = 1,
						FontFace = if disabled
							then theme.Typography.Body.Font
							else theme.Typography.Button.Font,
						TextSize = theme.Typography.Button.Size,
						TextColor3 = fg,
						TextTransparency = if disabled then 0.38 else 0,
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = props.Text,
						Name = "Label",
						-- Takes the width that is left, and ends in an ellipsis when the text is longer.
						Size = UDim2.new(0, 0, 1, 0),
						TextTruncate = Enum.TextTruncate.AtEnd,
						LayoutOrder = 2,
						[Children] = scope:New("UIFlexItem")({ FlexMode = Enum.UIFlexMode.Fill }),
					}),
				},
			}),
			-- Right / trailing: hug content
			scope:Frame({
				Name = "Right",
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = 2,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = 4,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = {
					if trailingName
						then scope:Apply(Icon(scope, {
							Theme = theme,
							Name = trailingName,
							IconSize = iconSize,
							Color = fg,
						}))({
							LayoutOrder = 1,
							ImageTransparency = if disabled then 0.38 else 0,
						})
						else nil,
					if trailingInst then scope:Apply(trailingInst)({ LayoutOrder = 2 }) else nil,
				},
			}),
			props.Children,
		},
	})) :: TextButton

	if props.Page then
		btn:SetAttribute("PantheonMenuPushPage", props.Page)
	end
	ix.wire(btn)

	-- When the label is cut short, hovering the row shows the full text in a tooltip. The tooltip
	-- is made the first time the label is cut, so rows that fit never pay for one.
	local label = btn:FindFirstChild("Label", true) :: TextLabel?
	if label then
		local truncated = scope:Value(false)
		local tooltipMade = false
		local function refresh()
			local cut = not label.TextFits
			truncated:set(cut)
			if cut and not tooltipMade then
				tooltipMade = true
				Tooltip(scope, {
					Theme = theme,
					Layer = props.Layer,
					Target = btn,
					Text = props.Text,
					Placement = "Right",
					Enabled = truncated,
				})
			end
		end
		table.insert(scope, label:GetPropertyChangedSignal("TextFits"):Connect(refresh))
		table.insert(scope, label:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh))
		task.defer(refresh)
	end

	return btn
end
