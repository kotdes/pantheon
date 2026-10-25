--!strict
--[[
	A bar of tool buttons, toggles and separators. See docs/Components/Navigation/Toolbar.md.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Icon = require(script.Parent.Icon)
local Tooltip = require(script.Parent.Tooltip)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local BUTTON = 30

return function(scope: Types.Scope, props: Types.ToolbarProps): Instance
	local theme = resolveTheme(props)
	local vertical = props.Orientation == "Vertical"
	local kids: { any } = {
		scope:New("UIListLayout")({
			FillDirection = if vertical
				then Enum.FillDirection.Vertical
				else Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = if vertical
				then Enum.HorizontalAlignment.Center
				else Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
		}),
		scope:New("UIPadding")({
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
		}),
	}

	local function tip(target: Instance, text: string)
		if Layer.resolve(props) then
			Tooltip(scope, { Theme = theme, Layer = props.Layer, Target = target, Text = text })
		end
	end

	for index, item in props.Items do
		if item.Separator then
			table.insert(
				kids,
				scope:New("Frame")({
					Name = "Separator",
					BackgroundColor3 = theme.Colors.OutlineVariant,
					BorderSizePixel = 0,
					LayoutOrder = index,
					Size = if vertical then UDim2.new(1, -8, 0, 1) else UDim2.new(0, 1, 1, -8),
				})
			)
		elseif item.Spacer then
			-- Takes the room that is left, pushing the items after it to the end.
			table.insert(
				kids,
				scope:New("Frame")({
					Name = "Spacer",
					BackgroundTransparency = 1,
					LayoutOrder = index,
					Size = UDim2.fromOffset(0, 0),
					[Children] = scope:New("UIFlexItem")({ FlexMode = Enum.UIFlexMode.Fill }),
				})
			)
		elseif item.Content then
			table.insert(kids, scope:Apply(item.Content)({ LayoutOrder = index }))
		else
			local disabled = peek(item.Disabled) == true
			local toggled = if item.Toggled ~= nil then item.Toggled else nil
			-- A toggle owns a Value of its own when it isn't given one.
			local state = if item.Toggle
				then (if Bind.isWritable(toggled)
					then toggled
					else scope:Value(peek(toggled) == true))
				else toggled
			local on = scope:Computed(function(use)
				return if state ~= nil then use(state) == true else false
			end)
			local ix = Interaction.bind(scope, theme, { Disabled = disabled })
			local labelKids: { any } = {
				scope:New("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 6),
				}),
				scope:New("UIPadding")({
					PaddingLeft = UDim.new(0, if item.Text then 10 else 0),
					PaddingRight = UDim.new(0, if item.Text then 10 else 0),
				}),
			}
			local ink = scope:Computed(function(use)
				if disabled then
					return use(theme.Colors.OnSurfaceVariant)
				end
				return if use(on)
					then use(theme.Colors.OnPrimaryContainer)
					else use(theme.Colors.OnSurface)
			end)
			if item.Icon then
				table.insert(
					labelKids,
					scope:Apply(Icon(scope, {
						Theme = theme,
						Name = item.Icon,
						IconSize = 18,
						Color = ink,
						Transparency = if disabled then 0.55 else 0,
					}))({ LayoutOrder = 1 })
				)
			end
			if item.Text then
				table.insert(
					labelKids,
					scope:New("TextLabel")({
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.X,
						Size = UDim2.fromOffset(0, BUTTON),
						LayoutOrder = 2,
						FontFace = theme.Typography.Label.Font,
						TextSize = A.size(theme, 13),
						TextColor3 = ink,
						TextTransparency = if disabled then 0.55 else 0,
						Text = item.Text,
					})
				)
			end
			local button = scope:New("TextButton")({
				Name = item.Id or `Item{index}`,
				Text = "",
				AutoButtonColor = false,
				Active = not disabled,
				LayoutOrder = index,
				AutomaticSize = if item.Text then Enum.AutomaticSize.X else Enum.AutomaticSize.None,
				Size = if item.Text
					then UDim2.fromOffset(0, BUTTON)
					else UDim2.fromOffset(BUTTON, BUTTON),
				BackgroundColor3 = scope:Computed(function(use)
					local base = if use(on)
						then use(theme.Colors.PrimaryContainer)
						else use(theme.Colors.Surface)
					return Interaction.lerpColor(
						base,
						use(theme.Colors.OnSurface),
						ix.alpha(use),
						use
					)
				end),
				BackgroundTransparency = scope:Computed(function(use)
					return if use(on) then 0 else 1 - math.clamp(ix.alpha(use) * 6, 0, 1)
				end),
				BorderSizePixel = 0,
				[OnEvent("Activated")] = function()
					if disabled then
						return
					end
					if item.Toggle and state ~= nil and Bind.isWritable(state) then
						(state :: any):set(not peek(state))
					end
					if item.OnClick then
						item.OnClick()
					end
				end,
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(0, theme.Metrics.RadiusSm) }),
					scope:New("Frame")({
						Name = "Content",
						BackgroundTransparency = 1,
						AutomaticSize = if item.Text
							then Enum.AutomaticSize.X
							else Enum.AutomaticSize.None,
						Size = if item.Text
							then UDim2.fromOffset(0, BUTTON)
							else UDim2.fromScale(1, 1),
						[Children] = labelKids,
					}),
				} :: any,
			}) :: TextButton
			ix.wire(button)
			table.insert(kids, button)
			local tipText = item.Tooltip or item.Text
			if tipText then
				tip(button, if item.Shortcut then `{tipText} ({item.Shortcut})` else tipText)
			end
		end
	end

	return scope:New("Frame")({
		Name = "Toolbar",
		BackgroundColor3 = theme.Colors.Surface,
		BorderSizePixel = 0,
		Size = props.Size or (if vertical then UDim2.new(0, 44, 1, 0) else UDim2.new(1, 0, 0, 40)),
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		[Children] = kids,
	}) :: Frame
end
