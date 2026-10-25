--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local EdgeFade = require(script.Parent.Parent.Internal.EdgeFade)

local Children = Fusion.Children

return function(scope: Types.Scope, props: Types.AppBarProps): Instance
	local theme = resolveTheme(props)
	local actions: { Instance } = props.Actions or {}
	local gradient = props.Variant == "Gradient"
	local barHeight = theme.Metrics.AppBarHeight
	local fadeHeight = if gradient then props.FadeHeight or 24 else 0

	-- Raise level, 0..1. With FadeAtTop it follows the scroll offset: at the top the fill is
	-- FadeTo and the divider and shadow are hidden. Without FadeAtTop it is always 1.
	local fadeTo: Color3 = props.FadeTo or theme.Colors.SurfaceContainerHigh
	-- Fill once raised. Defaults to Surface.
	local raisedColor: Color3 = props.RaisedColor or theme.Colors.Surface
	local ramp: number = props.FadeRamp or 24
	local raised: any = 1
	if props.FadeAtTop and props.ScrollOffset ~= nil then
		local target = scope:Computed(function(use)
			local offset = if typeof(props.ScrollOffset) == "table"
				then use(props.ScrollOffset)
				else props.ScrollOffset
			return math.clamp((offset :: number) / ramp, 0, 1)
		end)
		raised = scope:Spring(target, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
	end
	local function level(use: any): number
		local v = if typeof(raised) == "table" then use(raised) else raised
		return math.clamp(v :: number, 0, 1)
	end

	local bar = scope:Frame({
		Name = "AppBar",
		BackgroundColor3 = if gradient
			then fadeTo
			else scope:Computed(function(use)
				return Interaction.lerpColor(fadeTo, raisedColor, level(use), use)
			end),
		CornerRadius = props.Radius or { theme.Metrics.RadiusPanel, 0 },
		Size = props.Size or UDim2.new(1, 0, 0, barHeight + fadeHeight),
		LayoutOrder = props.LayoutOrder or 0,
		ZIndex = props.ZIndex or 10,
		Shadow = if props.Shadow == false or gradient
			then nil
			else {
				BlurRadius = 14,
				Offset = UDim2.fromOffset(0, 2),
				Transparency = scope:Computed(function(use)
					return 1 - 0.18 * level(use)
				end),
			},
		[Children] = {
			-- Bottom divider rather than an outline, so it doesn't double up with the Window's border.
			scope:Frame({
				Name = "Divider",
				Visible = not gradient,
				BackgroundColor3 = theme.Colors.OutlineVariant,
				BackgroundTransparency = scope:Computed(function(use)
					return 1 - level(use)
				end),
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 1),
				ZIndex = 2,
			}),
			if gradient then EdgeFade.gradient(scope, 90, barHeight, fadeHeight) else nil,
			scope:Frame({
				Name = "Row",
				BackgroundTransparency = 1,
				Size = if gradient then UDim2.new(1, 0, 0, barHeight) else UDim2.fromScale(1, 1),
				[Children] = {
					if props.Leading
						then scope:Apply(props.Leading)({
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, 8, 0.5, 0),
							Size = UDim2.fromOffset(40, 40),
						})
						else nil,
					if props.TitleContent
						then scope:Apply(props.TitleContent)({
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(0, if props.Leading then 56 else 8, 0.5, 0),
						})
						else scope:TextLabel({
							BackgroundTransparency = 1,
							FontFace = theme.Fonts.Heading,
							TextSize = A.size(theme, 18),
							TextColor3 = theme.Colors.OnSurface,
							TextXAlignment = Enum.TextXAlignment.Left,
							TextYAlignment = Enum.TextYAlignment.Center,
							Text = props.Title or "",
							Position = UDim2.fromOffset(if props.Leading then 56 else 16, 0),
							Size = UDim2.new(1, -120, 1, 0),
						}),
					scope:Frame({
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -8, 0.5, 0),
						AutomaticSize = Enum.AutomaticSize.X,
						Size = UDim2.fromOffset(0, 40),
						Layout = {
							Kind = "List",
							FillDirection = Enum.FillDirection.Horizontal,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = 4,
							HorizontalAlignment = Enum.HorizontalAlignment.Right,
						},
						[Children] = actions,
					}),
				},
			}),
		},
	}) :: Frame
	bar:SetAttribute(EdgeFade.HeightAttribute, barHeight + fadeHeight)
	bar:SetAttribute(EdgeFade.FadeAttribute, fadeHeight)
	return bar
end
