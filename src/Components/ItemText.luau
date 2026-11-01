--!strict
local Types = require(script.Parent.Parent.Types)
local ItemValue = require(script.Parent.Parent.Internal.ItemValue)
local ListItem = require(script.Parent.ListItem)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local TextField = require(script.Parent.TextField)

local DISPLAY_MAX_WIDTH = 140

return function(scope: Types.Scope, props: Types.ItemTextProps): Instance
	local theme = resolveTheme(props)
	local mode = props.Mode or "Inline"

	local slot: any = {
		Mode = mode,
		Placement = "Below",
		Detent = props.Detent,
		Build = function(inner: Types.Scope)
			return TextField(inner, {
				Theme = theme,
				Layer = props.Layer,
				Text = props.Value,
				Placeholder = props.Placeholder,
				Multiline = props.Multiline,
				Disabled = props.Disabled,
				OnChanged = function(text: string)
					ItemValue.write(props.Value, text)
					if props.OnChanged then
						props.OnChanged(text)
					end
				end,
			})
		end,
	}
	if mode ~= "Inline" then
		slot.Display = scope:TextLabel({
			BackgroundTransparency = 1,
			FontFace = theme.Typography.Body.Font,
			TextSize = theme.Typography.Body.Size,
			TextColor3 = theme.Colors.OnSurfaceVariant,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Right,
			AutomaticSize = Enum.AutomaticSize.XY,
			SizeConstraint = { MaxSize = Vector2.new(DISPLAY_MAX_WIDTH, math.huge) },
			Text = props.Value,
		})
	end
	return ListItem(scope, ItemValue.merge(ItemValue.base(props), { Slot = slot }))
end
