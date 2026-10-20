--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Wheel = require(script.Parent.Parent.Internal.Picker.Wheel)

local Children = Fusion.Children
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.TimePickerProps): Instance
	local theme = resolveTheme(props)
	local total = peek(props.Value) or 0
	local persistKey = Persist.key("TimePicker", typeof(props.Value) == "table")
	local hours = Persist.value(scope, persistKey, "hours", math.floor(total / 3600) % 24)
	local minutes = Persist.value(scope, persistKey, "minutes", math.floor(total / 60) % 60)
	Bind.linkParts(scope, props.Value, { hours, minutes }, function(h: number, m: number)
		return h * 3600 + m * 60
	end, function(seconds: number)
		return { math.floor(seconds / 3600) % 24, math.floor(seconds / 60) % 60 }
	end)

	local function emit()
		if props.OnChanged then
			props.OnChanged(peek(hours) * 3600 + peek(minutes) * 60)
		end
	end

	local ROW = 34
	local function wheel(count: number, value: any, set: (number) -> (), order: number): Instance
		return Wheel(scope, {
			Theme = theme,
			Count = count,
			Value = value,
			OnChanged = function(n: number)
				set(n)
				emit()
			end,
			LayoutOrder = order,
		})
	end

	return scope:Frame({
		Name = "TimePicker",
		BackgroundColor3 = theme.Colors.Surface,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		CornerRadius = theme.Metrics.RadiusPanel,
		Padding = { theme.Metrics.SpaceMd },
		[Children] = {
			scope:Frame({
				Name = "Wheels",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, ROW * 6),
				[Children] = {
					scope:Frame({
						Name = "Band",
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.new(1, 0, 0, ROW),
						BackgroundColor3 = theme.Colors.SurfaceContainerHigh,
						CornerRadius = theme.Metrics.RadiusSm,
						ZIndex = 1,
					}),
					scope:Frame({
						Name = "Row",
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0),
						Position = UDim2.fromScale(0.5, 0),
						Size = UDim2.fromScale(0, 1),
						AutomaticSize = Enum.AutomaticSize.X,
						ZIndex = 2,
						Layout = {
							Kind = "List",
							SortOrder = Enum.SortOrder.LayoutOrder,
							FillDirection = Enum.FillDirection.Horizontal,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							Padding = 0,
						},
						[Children] = {
							wheel(24, hours, function(n)
								hours:set(n)
							end, 1),
							scope:Frame({
								Name = "Colon",
								BackgroundTransparency = 1,
								Size = UDim2.fromOffset(16, ROW),
								LayoutOrder = 2,
								ZIndex = 3,
								[Children] = {
									scope:Frame({
										AnchorPoint = Vector2.new(0.5, 0.5),
										Position = UDim2.new(0.5, 0, 0.5, -5),
										Size = UDim2.fromOffset(4, 4),
										BackgroundColor3 = theme.Colors.OnSurface,
										CornerRadius = theme.Metrics.RadiusPill,
									}),
									scope:Frame({
										AnchorPoint = Vector2.new(0.5, 0.5),
										Position = UDim2.new(0.5, 0, 0.5, 5),
										Size = UDim2.fromOffset(4, 4),
										BackgroundColor3 = theme.Colors.OnSurface,
										CornerRadius = theme.Metrics.RadiusPill,
									}),
								},
							}),
							wheel(60, minutes, function(n)
								minutes:set(n)
							end, 3),
						},
					}),
				},
			}),
		},
	}) :: Frame
end
