--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local ItemValue = require(script.Parent.Parent.Internal.ItemValue)
local ListItem = require(script.Parent.ListItem)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local NumberField = require(script.Parent.NumberField)
local NumberSpinner = require(script.Parent.NumberSpinner)
local Slider = require(script.Parent.Slider)

local Children = Fusion.Children

local NUMBER_WIDTH = 120
local NUMBER_HEIGHT = 32
local SPINNER_SIZE = 40

return function(scope: Types.Scope, props: Types.ItemNumberProps): Instance
	local theme = resolveTheme(props)
	local mode = props.Mode or "Inline"

	local slot: any = {
		Mode = mode,
		Detent = props.Detent,
		Build = function(inner: Types.Scope)
			local function change(value: number)
				ItemValue.write(props.Value, value)
				if props.OnChanged then
					props.OnChanged(value)
				end
			end
			local sheet = mode ~= "Inline" and props.Min ~= nil and props.Max ~= nil
			if not sheet then
				return NumberField(inner, {
					Theme = theme,
					Value = props.Value,
					Min = props.Min,
					Max = props.Max,
					Step = props.Step,
					Decimals = props.Decimals,
					Suffix = props.Suffix,
					Disabled = props.Disabled,
					CornerRadius = theme.Metrics.RadiusPill,
					TextXAlignment = Enum.TextXAlignment.Center,
					Size = if mode == "Inline"
						then UDim2.fromOffset(NUMBER_WIDTH, NUMBER_HEIGHT)
						else nil,
					OnChanged = change,
				})
			end
			return inner:Frame({
				Name = "NumberSheet",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Layout = {
					Kind = "List",
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = theme.Metrics.SpaceMd,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = {
					NumberSpinner(inner, {
						Theme = theme,
						Value = props.Value,
						Decimals = props.Decimals,
						Suffix = props.Suffix,
						Grouping = false,
						Align = Enum.HorizontalAlignment.Center,
						Digits = #tostring(math.floor(math.abs(props.Max :: number))),
						TextSize = SPINNER_SIZE,
						LayoutOrder = 1,
					}),
					Slider(inner, {
						Theme = theme,
						Value = props.Value,
						Min = props.Min,
						Max = props.Max,
						Step = props.Step or 1,
						Disabled = props.Disabled,
						Size = UDim2.new(1, 0, 0, 0),
						LayoutOrder = 2,
						OnChanged = change,
					}),
				},
			})
		end,
	}
	if mode ~= "Inline" then
		slot.Display = scope:TextLabel({
			BackgroundTransparency = 1,
			FontFace = theme.Typography.Body.Font,
			TextSize = theme.Typography.Body.Size,
			TextColor3 = theme.Colors.OnSurfaceVariant,
			TextXAlignment = Enum.TextXAlignment.Right,
			AutomaticSize = Enum.AutomaticSize.XY,
			Text = scope:Computed(function(use)
				return tostring(use(props.Value :: any))
			end),
		})
	end
	return ListItem(scope, ItemValue.merge(ItemValue.base(props), { Slot = slot }))
end
