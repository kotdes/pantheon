--!strict
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.resolveTheme).resolveTheme

local ItemValue = {}

function ItemValue.write(state: any, value: any)
	if typeof(state) == "table" and state.set then
		state:set(value)
	end
end

function ItemValue.base(props: Types.ItemBaseProps): { [string]: any }
	return {
		PaddingX = resolveTheme(props).Metrics.SpaceMd,
		Theme = props.Theme,
		LayoutOrder = props.LayoutOrder,
		Size = props.Size,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Layer = props.Layer,
		Icon = props.Icon,
		Title = props.Title,
		Subtitle = props.Subtitle,
		Disabled = props.Disabled,
		OnPage = props.OnPage,
	}
end

function ItemValue.merge(base: { [string]: any }, extra: { [string]: any }): { [string]: any }
	for key, value in extra do
		base[key] = value
	end
	return base
end

return ItemValue
