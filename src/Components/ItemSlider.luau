--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local ItemValue = require(script.Parent.Parent.Internal.ItemValue)
local ListItem = require(script.Parent.ListItem)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Slider = require(script.Parent.Slider)

local Children = Fusion.Children

local TITLE_WIDTH = 112

return function(scope: Types.Scope, props: Types.ItemSliderProps): Instance
	local theme = resolveTheme(props)
	local minV = props.Min or 0
	local maxV = props.Max or 1

	local function format(value: number): string
		if props.Format then
			return props.Format(value)
		end
		if minV == 0 and maxV == 1 then
			return string.format("%d%%", math.floor(value * 100 + 0.5))
		end
		return tostring(math.floor(value * 100 + 0.5) / 100)
	end

	local readout = scope:TextLabel({
		Name = "Value",
		BackgroundTransparency = 1,
		FontFace = theme.Typography.Label.Font,
		TextSize = theme.Typography.Label.Size,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = theme.Colors.OnSurfaceVariant,
		Text = scope:Computed(function(use)
			return format(use(props.Value :: any) :: number)
		end),
		Size = UDim2.fromOffset(48, theme.Typography.Label.Size),
	})

	return ListItem(
		scope,
		ItemValue.merge(ItemValue.base(props), {
			TitleWidth = props.TitleWidth or TITLE_WIDTH,
			Trailing = readout,
			Slot = {
				Mode = "Inline",
				Fill = true,
				Build = function(inner: Types.Scope)
					return inner:Frame({
						Name = "Track",
						BackgroundTransparency = 1,
						Padding = { 0, theme.Metrics.SpaceMd },
						Size = UDim2.new(0, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						[Children] = {
							Slider(inner, {
								Theme = theme,
								Value = props.Value,
								Min = minV,
								Max = maxV,
								Step = props.Step or (maxV - minV) / 20,
								Disabled = props.Disabled,
								Size = UDim2.new(1, 0, 0, 0),
								OnChanged = function(value: number)
									ItemValue.write(props.Value, value)
									if props.OnChanged then
										props.OnChanged(value)
									end
								end,
							}),
						},
					})
				end,
			},
		})
	)
end
