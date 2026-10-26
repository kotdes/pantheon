--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local DataRow = require(script.Parent.DataRow)
local Switch = require(script.Parent.Switch)

local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.DataToggleProps): Instance
	local function flip(value: boolean)
		local state: any = props.Value
		if typeof(state) == "table" and state.set then
			state:set(value)
		end
		if props.OnChanged then
			props.OnChanged(value)
		end
	end
	return DataRow(scope, {
		Theme = props.Theme,
		LayoutOrder = props.LayoutOrder,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Icon = props.Icon,
		Title = props.Title,
		Summary = props.Summary,
		Disabled = props.Disabled,
		OnClick = function()
			flip(not (peek(props.Value :: any) == true))
		end,
		Trailing = Switch(scope, {
			Theme = props.Theme,
			Checked = props.Value,
			Disabled = props.Disabled,
			OnChanged = flip,
		}),
	})
end
