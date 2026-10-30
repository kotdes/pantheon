--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local DataRow = require(script.Parent.DataRow)
local Icon = require(script.Parent.Icon)
local Text = require(script.Parent.Text)

local Children = Fusion.Children

return function(scope: Types.Scope, props: Types.DataLinkProps): Instance
	local theme = resolveTheme(props)
	local parts: { any } = {}
	if props.Value ~= nil then
		table.insert(
			parts,
			Text(scope, {
				Theme = theme,
				Text = props.Value,
				Variant = "Label",
				Color = theme.Colors.OnSurfaceVariant,
				LayoutOrder = 1,
			})
		)
	end
	if props.Trailing then
		table.insert(parts, scope:Apply(props.Trailing)({ LayoutOrder = 2 }))
	end
	table.insert(
		parts,
		Icon(scope, {
			Theme = theme,
			Name = "chevron-right",
			IconSize = theme.Metrics.IconMd,
			Color = theme.Colors.OnSurfaceVariant,
			LayoutOrder = 3,
		})
	)
	return DataRow(scope, {
		Theme = theme,
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Icon = props.Icon,
		Title = props.Title,
		Summary = props.Summary,
		Disabled = props.Disabled,
		OnClick = props.OnClick,
		Trailing = scope:Frame({
			Name = "Trailing",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			Layout = {
				Kind = "List",
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = theme.Metrics.SpaceXs,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			[Children] = parts,
		}),
	})
end
