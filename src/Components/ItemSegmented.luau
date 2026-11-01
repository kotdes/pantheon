--!strict
local Types = require(script.Parent.Parent.Types)
local ItemValue = require(script.Parent.Parent.Internal.ItemValue)
local ListItem = require(script.Parent.ListItem)
local ChoiceGroup = require(script.Parent.ChoiceGroup)

return function(scope: Types.Scope, props: Types.ItemSegmentedProps): Instance
	return ListItem(
		scope,
		ItemValue.merge(ItemValue.base(props), {
			Slot = {
				Mode = "Inline",
				Placement = "Below",
				Build = function(inner: Types.Scope)
					return ChoiceGroup(inner, {
						Theme = props.Theme,
						Variant = "Segmented",
						Options = props.Options,
						Value = props.Value,
						Disabled = props.Disabled,
						OnChanged = function(value: string)
							ItemValue.write(props.Value, value)
							if props.OnChanged then
								props.OnChanged(value)
							end
						end,
					})
				end,
			},
		})
	)
end
