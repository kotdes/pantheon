--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Corners = require(script.Parent.Parent.Internal.Corners)
local Text = require(script.Parent.Text)

local Children = Fusion.Children

return function(scope: Types.Scope, props: Types.DataListProps): Instance
	local theme = resolveTheme(props)
	local rows: { any } = {}
	for _, row in props.Children or {} do
		if #rows > 0 then
			table.insert(
				rows,
				scope:Frame({
					Name = "Divider",
					BackgroundColor3 = theme.Colors.OutlineVariant,
					Size = UDim2.new(1, -theme.Metrics.SpaceMd * 2, 0, 1),
					LayoutOrder = #rows + 1,
				})
			)
		end
		(row :: any).LayoutOrder = #rows + 1
		table.insert(rows, row)
	end

	local radius = props.CornerRadius or theme.Metrics.RadiusMd
	local card = scope:Frame({
		Name = "Card",
		BackgroundColor3 = theme.Colors.Surface,
		CornerRadius = radius,
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Layout = {
			Kind = "List",
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = rows,
	}) :: GuiObject
	Corners.setContainer(card, radius)

	local heading = props.Heading
	return scope:Frame({
		Name = "DataList",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.SpaceXs,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			if heading ~= nil
				then Text(scope, {
					Theme = theme,
					Text = heading,
					Visible = scope:Computed(function(use)
						return use(heading :: any) ~= ""
					end),
					Variant = "Label",
					Color = theme.Colors.Primary,
					Padding = { 0, theme.Metrics.SpaceMd },
					LayoutOrder = 1,
				})
				else nil,
			card,
		},
	})
end
