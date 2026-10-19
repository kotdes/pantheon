--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Radio = require(script.Parent.Radio)

local Children = Fusion.Children
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.RadioGroupProps): Instance
	local theme = resolveTheme(props)
	local selected = if props.Value
		then props.Value
		else Persist.value(
			scope,
			Persist.key("RadioGroup", props.Id),
			"value",
			(props.Options[1] and props.Options[1].Value) or ""
		)
	local disabled = peek(props.Disabled) == true
	local rows = {}

	for i, opt in props.Options do
		local checked = scope:Computed(function(use)
			return use(selected) == opt.Value
		end)

		local radio = Radio(scope, {
			Checked = checked,
			Label = opt.Label,
			Disabled = disabled,
			LayoutOrder = i,
			OnClick = function()
				if disabled then
					return
				end
				selected:set(opt.Value)
				if props.OnChanged then
					props.OnChanged(opt.Value)
				end
			end,
		})
		table.insert(rows, radio)
	end

	return scope:Frame({
		Name = "RadioGroup",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.Space2xs,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = rows,
	}) :: Frame
end
