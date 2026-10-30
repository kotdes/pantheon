--!strict
--[[
	iOS-style inset grouped settings list: Surface cards with icon rows.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Icon = require(script.Parent.Icon)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

return function(scope: Types.Scope, props: Types.SettingsListProps): Instance
	local theme = resolveTheme(props)
	local inset = props.InsetGrouped ~= false
	local items: { Types.SettingsListItem } = props.Items or {}
	local rows = {}

	for i, item in items do
		local disabled = item.Disabled == true
		local ix = Interaction.bind(scope, theme, {
			Disabled = disabled,
			StateColor = theme.Colors.OnSurface,
		})

		local kids: { any } = {}
		if item.Icon then
			table.insert(
				kids,
				scope:Frame({
					Name = "IconWell",
					Size = UDim2.fromOffset(40, 40),
					BackgroundColor3 = theme.Colors.PrimaryContainer,
					LayoutOrder = 1,
					CornerRadius = theme.Metrics.RadiusPill,
					[Children] = {
						scope:Apply(Icon(scope, {
							Theme = theme,
							Name = item.Icon,
							IconSize = theme.Metrics.IconLg,
							Color = theme.Colors.OnPrimaryContainer,
						}))({
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
						}),
					},
				})
			)
		end

		local textCol = {
			scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Title.Font,
				TextSize = A.size(theme, 15), -- token-ok
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = theme.Colors.OnSurface,
				Text = item.Title,
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 1,
			}),
		}
		if item.Subtitle ~= nil then
			table.insert(
				textCol,
				scope:TextLabel({
					BackgroundTransparency = 1,
					FontFace = theme.Typography.Body.Font,
					TextSize = theme.Typography.Caption.Size,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = theme.Colors.OnSurfaceVariant,
					Text = item.Subtitle,
					AutomaticSize = Enum.AutomaticSize.XY,
					LayoutOrder = 2,
				})
			)
		end
		table.insert(
			kids,
			scope:Frame({
				Name = "Text",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 2,
				Layout = {
					Kind = "List",
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = 1,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = textCol,
			})
		)

		if item.Trailing then
			table.insert(kids, scope:Apply(item.Trailing)({ LayoutOrder = 3 }))
		elseif item.ShowChevron ~= false and item.OnClick then
			table.insert(
				kids,
				scope:Apply(Icon(scope, {
					Theme = theme,
					Name = "chevron-right",
					IconSize = theme.Metrics.IconMd,
					Color = theme.Colors.OnSurfaceVariant,
				}))({
					LayoutOrder = 3,
				})
			)
		end

		local row = scope:TextButton(P({
			Name = item.Id or ("SettingsRow_" .. tostring(i)),
			Text = "",
			AutoButtonColor = false,
			Active = not disabled and item.OnClick ~= nil,
			BackgroundColor3 = ix.fill(theme.Colors.Surface),
			Size = UDim2.new(1, 0, 0, 56),
			LayoutOrder = i,
			ClipsDescendants = true,
			CornerRadius = theme.Metrics.RadiusPanel,
			Padding = { theme.Metrics.SpaceXs, theme.Metrics.SpaceMd },
			Layout = {
				Kind = "List",
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = theme.Metrics.SpaceSm,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			[OnEvent("Activated")] = if disabled then nil else item.OnClick,
			[Children] = kids,
		})) :: TextButton

		local mid = kids[if item.Icon then 2 else 1]
		if mid and mid:IsA("GuiObject") then
			local flex = Instance.new("UIFlexItem")
			flex.FlexMode = Enum.UIFlexMode.Fill
			flex.Parent = mid
		end

		ix.wire(row)
		table.insert(rows, row)
	end

	local kids: { any } = {}
	if props.Header ~= nil then
		table.insert(
			kids,
			scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Label.Font,
				TextSize = theme.Typography.Label.Size,
				TextColor3 = theme.Colors.OnSurfaceVariant,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = props.Header,
				Size = UDim2.new(1, 0, 0, 18),
				LayoutOrder = 0,
			})
		)
	end
	for i, row in rows do
		table.insert(kids, scope:Apply(row)({ LayoutOrder = i }))
	end
	if props.Children then
		table.insert(kids, props.Children)
	end
	if props.Footer ~= nil then
		table.insert(
			kids,
			scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Label.Font,
				TextSize = theme.Typography.Label.Size,
				TextColor3 = theme.Colors.OnSurfaceVariant,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				Text = props.Footer,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 1000,
			})
		)
	end

	return scope:Frame({
		Name = "SettingsList",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Padding = if inset then { 0, theme.Metrics.SpaceMd } else nil,
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.SpaceXs,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = kids,
	}) :: Frame
end
