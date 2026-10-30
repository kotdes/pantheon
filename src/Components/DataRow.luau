--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local ListItemStyle = require(script.Parent.Parent.Internal.ListItemStyle)
local Corners = require(script.Parent.Parent.Internal.Corners)
local P = require(script.Parent.Parent.Internal.props)
local Icon = require(script.Parent.Icon)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.DataRowProps): Instance
	local theme = resolveTheme(props)
	local style = ListItemStyle(theme)
	local iconColumn = style.IconSize + style.Gap
	local clickable = props.OnClick ~= nil and peek(props.Disabled) ~= true
	local ix = Interaction.bind(scope, theme, {
		Disabled = not clickable,
		StateColor = theme.Colors.OnSurface,
	})

	local function line(text: any, font: Font, size: number, colour: any, order: number): Instance
		return scope:TextLabel({
			Name = "Line",
			BackgroundTransparency = 1,
			FontFace = font,
			TextSize = size,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = colour,
			TextWrapped = true,
			Text = text,
			Size = UDim2.new(1, 0, 0, size),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = order,
		})
	end

	local texts: { any } = {
		line(props.Title, style.TitleFont, style.TitleSize, theme.Colors.OnSurface, 1),
	}
	if props.Summary ~= nil then
		table.insert(
			texts,
			line(
				props.Summary,
				style.SubtitleFont,
				style.SubtitleSize,
				theme.Colors.OnSurfaceVariant,
				2
			)
		)
	end
	local textColumn = scope:Frame({
		Name = "Text",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Layout = { Kind = "List", SortOrder = Enum.SortOrder.LayoutOrder },
		[Children] = texts,
	})
	local flex = Instance.new("UIFlexItem")
	flex.FlexMode = Enum.UIFlexMode.Fill
	flex.Parent = textColumn

	local top: { any } = {}
	if props.Icon then
		table.insert(
			top,
			scope:Frame({
				Name = "IconSlot",
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(style.IconSize, style.IconSize),
				LayoutOrder = 1,
				Layout = { Kind = "List", VerticalAlignment = Enum.VerticalAlignment.Center },
				[Children] = {
					Icon(scope, {
						Theme = theme,
						Name = props.Icon,
						IconSize = style.IconSize,
						Color = theme.Colors.OnSurfaceVariant,
					}),
				},
			})
		)
	end
	table.insert(top, textColumn)
	if props.Trailing then
		table.insert(top, scope:Apply(props.Trailing)({ LayoutOrder = 3 }))
	end

	local parts: { any } = {
		scope:Frame({
			Name = "Top",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1,
			Layout = {
				Kind = "List",
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = style.Gap,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			[Children] = top,
		}),
	}
	if props.Below then
		-- Lines up with the text, under the icon column.
		table.insert(
			parts,
			scope:Frame({
				Name = "Below",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 2,
				Padding = { 0, 0, 0, if props.Icon then iconColumn else 0 },
				[Children] = { props.Below },
			})
		)
	end

	local button = scope:TextButton(P({
		Name = "DataRow",
		Text = "",
		AutoButtonColor = false,
		Active = clickable,
		BackgroundColor3 = ix.fill(theme.Colors.Surface),
		BorderSizePixel = 0,
		-- At least the height of a ListItem. Long text or a control under the text make it taller.
		Size = props.Size or UDim2.new(
			1,
			0,
			0,
			if props.Summary ~= nil then style.HeightWithSubtitle else style.Height
		),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		CornerRadius = props.CornerRadius or style.Radius,
		-- The row is as tall as its content, so the space above and below the text is set here.
		Padding = { style.PaddingYTall, style.PaddingX },
		Layout = {
			Kind = "List",
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = style.Gap,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[OnEvent("Activated")] = if clickable then props.OnClick else nil,
		[Children] = parts,
	})) :: TextButton

	ix.wire(button)
	Corners.auto(button, props.CornerRadius, style.Radius)
	return button
end
