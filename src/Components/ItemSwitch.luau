--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local ItemValue = require(script.Parent.Parent.Internal.ItemValue)
local ListItem = require(script.Parent.ListItem)
local Switch = require(script.Parent.Switch)

local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.ItemSwitchProps): Instance
	local function flip(value: boolean)
		ItemValue.write(props.Value, value)
		if props.OnChanged then
			props.OnChanged(value)
		end
	end
	return ListItem(
		scope,
		ItemValue.merge(ItemValue.base(props), {
			OnClick = function()
				flip(not (peek(props.Value :: any) == true))
			end,
			Slot = {
				Mode = "Inline",
				Build = function(inner: Types.Scope)
					return Switch(inner, {
						Theme = props.Theme,
						Checked = props.Value,
						Disabled = props.Disabled,
						OnChanged = flip,
					})
				end,
			},
		})
	)
end
