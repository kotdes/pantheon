--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local ListItemStyle = require(script.Parent.Parent.Internal.ListItemStyle)
local Slider = require(script.Parent.Slider)

local Children = Fusion.Children

local LABEL_WIDTH = 112
local VALUE_WIDTH = 48

return function(scope: Types.Scope, props: Types.DataSliderProps): Instance
	local theme = resolveTheme(props)
	local style = ListItemStyle(theme)
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

	local track = scope:Frame({
		Name = "Track",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		[Children] = {
			Slider(scope, {
				Theme = theme,
				Value = props.Value,
				Min = minV,
				Max = maxV,
				Step = props.Step or (maxV - minV) / 20,
				Disabled = props.Disabled,
				Size = UDim2.new(1, 0, 0, 0),
				OnChanged = function(value: number)
					local state: any = props.Value
					if typeof(state) == "table" and state.set then
						state:set(value)
					end
					if props.OnChanged then
						props.OnChanged(value)
					end
				end,
			}),
		},
	})
	local flex = Instance.new("UIFlexItem")
	flex.FlexMode = Enum.UIFlexMode.Fill
	flex.Parent = track

	return scope:Frame({
		Name = "DataSlider",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(1, 0, 0, style.Height),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Padding = { style.PaddingY, style.PaddingX },
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = style.Gap,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			scope:TextLabel({
				Name = "Title",
				BackgroundTransparency = 1,
				FontFace = style.TitleFont,
				TextSize = style.TitleSize,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = theme.Colors.OnSurface,
				Text = props.Title,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Size = UDim2.fromOffset(props.LabelWidth or LABEL_WIDTH, style.TitleSize),
				LayoutOrder = 1,
			}),
			track,
			scope:TextLabel({
				Name = "Value",
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Label.Font,
				TextSize = theme.Typography.Label.Size,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextColor3 = theme.Colors.OnSurfaceVariant,
				Text = scope:Computed(function(use)
					return format(use(props.Value :: any) :: number)
				end),
				Size = UDim2.fromOffset(VALUE_WIDTH, theme.Typography.Label.Size),
				LayoutOrder = 3,
			}),
		},
	})
end
