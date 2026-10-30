--!strict
--[[
	A thin bar for status text, with items at the start, middle and end.
	See docs/Components/Navigation/StatusBar.md.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Icon = require(script.Parent.Icon)
local LoadingIndicator = require(script.Parent.LoadingIndicator)
local Tooltip = require(script.Parent.Tooltip)

local Children = Fusion.Children

local HEIGHT = 24

return function(scope: Types.Scope, props: Types.StatusBarProps): Instance
	local theme = resolveTheme(props)

	local function toneColor(tone: string?): Color3
		if tone == "Error" then
			return theme.Colors.Error
		elseif tone == "Warning" then
			return theme.Colors.Warning
		elseif tone == "Success" then
			return theme.Colors.Success
		end
		return theme.Colors.OnSurfaceVariant
	end

	local function build(item: Types.StatusItem, order: number): Instance
		local color = toneColor(item.Tone)
		local kids: { any } = {
			scope:New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, theme.Metrics.Space2xs),
			}),
			scope:New("UIPadding")({
				PaddingLeft = UDim.new(0, theme.Metrics.SpaceXs),
				PaddingRight = UDim.new(0, theme.Metrics.SpaceXs),
			}),
		}
		if item.Busy then
			table.insert(
				kids,
				scope:Apply(LoadingIndicator(scope, { Theme = theme, SizePx = 14 }))({
					LayoutOrder = 1,
				})
			)
		elseif item.Icon then
			table.insert(
				kids,
				scope:Apply(
					Icon(scope, { Theme = theme, Name = item.Icon, IconSize = 13, Color = color })
				)({
					LayoutOrder = 1,
				})
			)
		end
		if item.Text ~= nil then
			table.insert(
				kids,
				scope:New("TextLabel")({
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.X,
					Size = UDim2.fromOffset(0, HEIGHT),
					LayoutOrder = 2,
					FontFace = theme.Fonts.Body,
					TextSize = theme.Typography.Caption.Size,
					TextColor3 = color,
					Text = item.Text,
				})
			)
		end
		if item.Progress ~= nil then
			local fraction = item.Progress
			table.insert(
				kids,
				scope:Frame({
					Name = "Progress",
					LayoutOrder = 3,
					Size = UDim2.fromOffset(80, 4),
					BackgroundColor3 = theme.Colors.OutlineVariant,
					BorderSizePixel = 0,
					CornerRadius = 2,
					[Children] = scope:New("Frame")({
						BackgroundColor3 = theme.Colors.Primary,
						BorderSizePixel = 0,
						Size = scope:Computed(function(use)
							local value = if typeof(fraction) == "table"
								then use(fraction)
								else fraction
							return UDim2.fromScale(math.clamp((value :: number) or 0, 0, 1), 1)
						end),
						[Children] = scope:New("UICorner")({ CornerRadius = UDim.new(0, 2) }),
					}),
				})
			)
		end

		local clickable = item.OnClick ~= nil
		local ix = Interaction.bind(scope, theme, { Disabled = not clickable })
		local node = scope:New(if clickable then "TextButton" else "Frame")({
			Name = item.Id or `Item{order}`,
			BackgroundColor3 = if clickable
				then ix.fill(theme.Colors.SurfaceContainer)
				else theme.Colors.SurfaceContainer,
			BackgroundTransparency = if clickable then ix.fillTransparency(1) else 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.fromOffset(0, HEIGHT),
			LayoutOrder = order,
			[Children] = kids :: any,
		}) :: GuiObject
		if clickable then
			local button = node :: TextButton
			button.Text = ""
			button.AutoButtonColor = false
			table.insert(
				scope,
				button.Activated:Connect(function()
					(item.OnClick :: () -> ())()
				end)
			)
			ix.wire(button)
		end
		if item.Tooltip and Layer.resolve(props) then
			Tooltip(
				scope,
				{ Theme = theme, Layer = props.Layer, Target = node, Text = item.Tooltip }
			)
		end
		return node
	end

	local function side(items: { Types.StatusItem }?, anchor: number, order: number): Instance
		local kids: { any } = {
			scope:New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = if anchor == 1
					then Enum.HorizontalAlignment.Right
					elseif anchor == 0.5 then Enum.HorizontalAlignment.Center
					else Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 2),
			}),
		}
		local list: { Types.StatusItem } = items or {}
		for index, item in list do
			table.insert(kids, build(item, index))
		end
		return scope:New("Frame")({
			Name = if anchor == 0 then "Start" elseif anchor == 1 then "End" else "Middle",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(anchor, 0),
			Position = UDim2.fromScale(anchor, 0),
			Size = UDim2.new(0.4, 0, 1, 0),
			LayoutOrder = order,
			[Children] = kids,
		})
	end

	return scope:New("Frame")({
		Name = "StatusBar",
		BackgroundColor3 = theme.Colors.SurfaceContainer,
		BorderSizePixel = 0,
		Size = props.Size or UDim2.new(1, 0, 0, HEIGHT),
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		[Children] = {
			scope:New("Frame")({
				Name = "Divider",
				BackgroundColor3 = theme.Colors.OutlineVariant,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 1),
			}),
			side(props.Start, 0, 1),
			side(props.Middle, 0.5, 2),
			side(props.End, 1, 3),
		} :: any,
	}) :: Frame
end
