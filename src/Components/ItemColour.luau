--!strict
local Types = require(script.Parent.Parent.Types)
local ItemValue = require(script.Parent.Parent.Internal.ItemValue)
local ListItem = require(script.Parent.ListItem)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local ColorPicker = require(script.Parent.ColorPicker)

local SWATCH = 24

return function(scope: Types.Scope, props: Types.ItemColourProps): Instance
	local theme = resolveTheme(props)
	return ListItem(
		scope,
		ItemValue.merge(ItemValue.base(props), {
			Slot = {
				Mode = props.Mode or "Prompt",
				Detent = props.Detent,
				Display = scope:Frame({
					Name = "Swatch",
					BackgroundColor3 = props.Value,
					CornerRadius = theme.Metrics.RadiusPill,
					Size = UDim2.fromOffset(SWATCH, SWATCH),
				}),
				Build = function(inner: Types.Scope)
					return ColorPicker(inner, {
						Theme = theme,
						Layer = props.Layer,
						Value = props.Value,
						ShowAlpha = props.ShowAlpha,
						Modes = props.Modes,
						OnChanged = function(colour: Color3)
							ItemValue.write(props.Value, colour)
							if props.OnChanged then
								props.OnChanged(colour)
							end
						end,
					})
				end,
			},
		})
	)
end
