--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.ListItemProps): Instance
	local theme = resolveTheme(props)
	local disabled = peek(props.Disabled) == true
	local ix = Interaction.bind(scope, theme, {
		Disabled = disabled,
		StateColor = theme.Colors.OnSurface,
	})

	local textCol = {
		scope:TextLabel({
			BackgroundTransparency = 1,
			FontFace = theme.Typography.Title.Font,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = theme.Colors.OnSurface,
			Text = props.Title,
			-- A title that is too long ends in an ellipsis, so it does not run under the trailing element.
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, 0, 0, 20),
			LayoutOrder = 1,
		}),
	}
	if props.Subtitle ~= nil then
		table.insert(
			textCol,
			scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Body.Font,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = theme.Colors.OnSurfaceVariant,
				Text = props.Subtitle,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.new(1, 0, 0, 18),
				LayoutOrder = 2,
			})
		)
	end

	local kids: { any } = {}
	if props.Leading then
		table.insert(kids, scope:Apply(props.Leading)({ LayoutOrder = 1 }))
	end
	table.insert(
		kids,
		scope:Frame({
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = 2,
			Layout = {
				Kind = "List",
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = 2,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			[Children] = textCol,
		})
	)
	if props.Trailing then
		table.insert(kids, scope:Apply(props.Trailing)({ LayoutOrder = 3 }))
	end

	-- Flex the middle text column
	local button = scope:TextButton(P({
		Name = "ListItem",
		AutoButtonColor = false,
		Active = not disabled,
		BackgroundColor3 = ix.fill(theme.Colors.Surface),
		BorderSizePixel = 0,
		Size = props.Size or UDim2.new(1, 0, 0, 56),
		Text = "",
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		CornerRadius = theme.Metrics.RadiusSm,
		Padding = { theme.Metrics.SpaceXs, theme.Metrics.SpaceMd },
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = theme.Metrics.SpaceSm,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[OnEvent("Activated")] = if disabled then nil else props.OnClick,
		[Children] = kids,
	})) :: TextButton

	local mid = kids[if props.Leading then 2 else 1]
	if mid and mid:IsA("GuiObject") then
		local flex = Instance.new("UIFlexItem")
		flex.FlexMode = Enum.UIFlexMode.Fill
		flex.Parent = mid
	end

	ix.wire(button)
	return button
end
