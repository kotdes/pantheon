--!strict
local Types = require(script.Parent.Parent.Types)
local ItemValue = require(script.Parent.Parent.Internal.ItemValue)
local ListItem = require(script.Parent.ListItem)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local ChoiceItems = require(script.Parent.Parent.Internal.ChoiceItems)
local RadioGroup = require(script.Parent.RadioGroup)

return function(scope: Types.Scope, props: Types.ItemRadioProps): Instance
	local theme = resolveTheme(props)
	local mode = props.Mode or "Accordion"

	local function pick(value: string)
		ItemValue.write(props.Value, value)
		if props.OnChanged then
			props.OnChanged(value)
		end
	end

	local slot: any
	if mode == "Inline" then
		slot = {
			Mode = "Inline",
			Placement = "Below",
			Build = function(inner: Types.Scope)
				return RadioGroup(inner, {
					Theme = theme,
					Options = props.Options,
					Value = props.Value,
					Disabled = props.Disabled,
					OnChanged = pick,
				})
			end,
		}
	else
		slot = {
			Mode = mode,
			Detent = props.Detent,
			Display = scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Body.Font,
				TextSize = theme.Typography.Body.Size,
				TextColor3 = theme.Colors.OnSurfaceVariant,
				AutomaticSize = Enum.AutomaticSize.XY,
				Text = scope:Computed(function(use)
					local current = use(props.Value :: any)
					for _, option in props.Options do
						if option.Value == current then
							return option.Label
						end
					end
					return ""
				end),
			}),
			Build = function(inner: Types.Scope, close: () -> ())
				return ChoiceItems(inner, {
					Theme = theme,
					Layer = props.Layer,
					Options = props.Options,
					Value = props.Value,
					OnPick = pick,
					Close = close,
					Grouped = mode ~= "Accordion",
				})
			end,
		}
	end
	return ListItem(scope, ItemValue.merge(ItemValue.base(props), { Slot = slot }))
end
