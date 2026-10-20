--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Icon = require(script.Parent.Icon)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.StarRatingProps): Instance
	local theme = resolveTheme(props)
	local maxStars = props.Max or 5
	local readOnly = props.ReadOnly == true
	local iconSize = props.IconSize or 24
	local value = Persist.value(
		scope,
		Persist.key("StarRating", typeof(props.Value) == "table"),
		"value",
		peek(props.Value) or 0
	)
	Bind.link(scope, props.Value, value)
	local stars = {}

	for i = 1, maxStars do
		local ix = Interaction.bind(scope, theme, {
			Disabled = readOnly,
			StateColor = theme.Colors.Primary,
		})
		local filled = scope:Computed(function(use)
			return use(value) >= i
		end)
		local starIcon = Icon(scope, {
			Theme = theme,
			Name = "star",
			IconSize = iconSize,
			Color = scope:Computed(function(use)
				return if use(filled) then use(theme.Colors.Primary) else use(theme.Colors.Outline)
			end),
		})
		local btn = scope:TextButton(P({
			Name = "Star_" .. tostring(i),
			Text = "",
			AutoButtonColor = false,
			Active = not readOnly,
			BackgroundColor3 = theme.Colors.Primary,
			BackgroundTransparency = if readOnly then 1 else ix.fillTransparency(1),
			Size = UDim2.fromOffset(iconSize + 16, iconSize + 16),
			LayoutOrder = i,
			ClipsDescendants = true,
			CornerRadius = theme.Metrics.RadiusPill,
			[OnEvent("Activated")] = if readOnly
				then nil
				else function()
					value:set(i)
					if props.OnChanged then
						props.OnChanged(i)
					end
				end,
			[Children] = {
				scope:Apply(starIcon)({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
				}),
			},
		})) :: TextButton
		if not readOnly then
			ix.wire(btn)
		end
		table.insert(stars, btn)
	end

	return scope:Frame({
		Name = "StarRating",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.fromOffset(0, iconSize + 16),
		AutomaticSize = Enum.AutomaticSize.X,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = theme.Metrics.Space2xs,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = stars,
	}) :: Frame
end
