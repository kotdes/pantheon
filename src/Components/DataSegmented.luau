--!strict
local Types = require(script.Parent.Parent.Types)
local DataRow = require(script.Parent.DataRow)
local ChoiceGroup = require(script.Parent.ChoiceGroup)

return function(scope: Types.Scope, props: Types.DataSegmentedProps): Instance
	return DataRow(scope, {
		Theme = props.Theme,
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Icon = props.Icon,
		Title = props.Title,
		Summary = props.Summary,
		Below = ChoiceGroup(scope, {
			Theme = props.Theme,
			Variant = "Segmented",
			Value = props.Value,
			Options = props.Options,
			Disabled = props.Disabled,
			OnChanged = props.OnChanged,
		}),
	})
end
