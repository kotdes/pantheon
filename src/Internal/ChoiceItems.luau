--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.resolveTheme).resolveTheme
local Icon = require(script.Parent.Parent.Components.Icon)
local ListItem = require(script.Parent.Parent.Components.ListItem)
local ListItemGroup = require(script.Parent.Parent.Components.ListItemGroup)

local Children = Fusion.Children

export type Props = {
	Theme: Types.ThemeRef?,
	Layer: Instance?,
	Options: { { Value: string, Label: string } },
	Value: Types.UsedAs<string>,
	OnPick: (value: string) -> (),
	Close: () -> (),
	Grouped: boolean?,
}

return function(scope: Types.Scope, props: Props): Instance
	local theme = resolveTheme(props)
	local rows: { any } = {}
	for index, option in props.Options do
		local picked = scope:Computed(function(use)
			return use(props.Value :: any) == option.Value
		end)
		table.insert(
			rows,
			ListItem(scope, {
				Theme = theme,
				Layer = props.Layer,
				Title = option.Label,
				Selected = picked,
				Trailing = Icon(scope, {
					Theme = theme,
					Name = "check",
					IconSize = theme.Metrics.IconMd,
					Color = theme.Colors.Primary,
					Visible = picked,
				}),
				LayoutOrder = index,
				CornerRadius = if props.Grouped then nil else theme.Metrics.RadiusSm,
				OnClick = function()
					props.OnPick(option.Value)
					props.Close()
				end,
			})
		)
	end
	if props.Grouped then
		return ListItemGroup(scope, { Theme = theme, Children = rows })
	end
	return scope:Frame({
		Name = "ChoiceItems",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Layout = { Kind = "List", SortOrder = Enum.SortOrder.LayoutOrder },
		[Children] = rows,
	})
end
