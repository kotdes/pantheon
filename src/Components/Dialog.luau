--!strict
--[[
	Cadence dialog: scrim + centered surface.
	Actions: 2 → full-width horizontal; 3+ → stacked vertical.
	Pass Layer (top UI frame) so the modal does not shift content layout.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Corners = require(script.Parent.Parent.Internal.Corners)
local Focus = require(script.Parent.Parent.Internal.Focus)
local CanvasFade = require(script.Parent.Parent.Internal.CanvasFade)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Overlay = require(script.Parent.Overlay)
local Button = require(script.Parent.Button)
local Icon = require(script.Parent.Icon)

local Children = Fusion.Children
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.DialogProps): Instance
	local theme = resolveTheme(props)
	local openRef = props.Open
	local open = scope:Computed(function(use)
		if openRef == nil then
			return true
		end
		return (if typeof(openRef) == "table" then use(openRef) else openRef) ~= false
	end)
	local openS = scope:Spring(
		scope:Computed(function(use)
			return if use(open) then 1 else 0
		end),
		theme.Motion.SpringSpeed,
		theme.Motion.SpringDamping
	)

	local actions: { Types.DialogAction } = props.Actions or {}
	if props.OnClose and #actions == 0 then
		actions = {
			{
				Text = "Close",
				Variant = "Text" :: Types.ButtonVariant,
				OnClick = props.OnClose,
			},
		}
	end

	local actionCount = #actions
	local horizontal = actionCount > 0 and actionCount <= 2
	local actionRow = {}
	for i, action in actions do
		local variant = action.Variant
			or (if i == actionCount then "Filled" else (if horizontal then "Tonal" else "Text"))
		local btn = Button(scope, {
			Theme = theme,
			Text = action.Text,
			Variant = variant,
			Color = action.Color,
			OnClick = action.OnClick,
			LayoutOrder = i,
			Size = if horizontal then UDim2.new(1, 0, 0, 40) else UDim2.new(1, 0, 0, 40),
		})
		if horizontal then
			local flex = Instance.new("UIFlexItem")
			flex.FlexMode = Enum.UIFlexMode.Fill
			flex.Parent = btn
		end
		table.insert(actionRow, btn)
	end

	local hasIcon = props.Icon ~= nil and props.Icon ~= ""
	local iconSize = props.IconSize or 28
	local titleAlign = Enum.TextXAlignment.Center
	local radius = props.CornerRadius or theme.Metrics.Radius3xl

	-- TextButton sinks Overlay Activated; Frame.Active alone does not.
	local panel = scope:TextButton({
		Name = "DialogPanel",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = theme.Colors.Surface,
		Size = props.Size or UDim2.fromOffset(320, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
		Active = true,
		LayoutOrder = 2,
		CornerRadius = radius,
		Outline = {
			Color = theme.Colors.OutlineVariant,
			Thickness = 1,
			Mode = Enum.ApplyStrokeMode.Border,
		},
		Shadow = {
			BlurRadius = 12,
			Transparency = scope:Computed(function(use)
				return 1 - (use(openS) :: number) * 0.15
			end),
		},
		Padding = { theme.Metrics.SpaceMd },
		Layout = {
			Kind = "List",
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			if hasIcon
				then scope:Frame({
					Name = "IconWell",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, iconSize + theme.Metrics.SpaceXs * 2),
					LayoutOrder = 0,
					Padding = { theme.Metrics.SpaceXs },
					Layout = {
						Kind = "List",
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					},
					[Children] = {
						Icon(scope, {
							Theme = theme,
							Name = props.Icon,
							IconSize = iconSize,
							Color = props.IconColor or theme.Colors.OnSurfaceVariant,
						}),
					},
				})
				else nil,
			scope:Frame({
				Name = "Labels",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 1,
				Padding = { theme.Metrics.SpaceXs },
				Layout = {
					Kind = "List",
					Padding = theme.Metrics.Space2xs,
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				},
				[Children] = {
					scope:TextLabel({
						BackgroundTransparency = 1,
						FontFace = theme.Typography.Title.Font,
						TextSize = theme.Typography.Title.Size,
						TextColor3 = theme.Colors.OnSurface,
						TextXAlignment = titleAlign,
						Text = props.Title,
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						LayoutOrder = 1,
					}),
					if props.Body
						then scope:TextLabel({
							BackgroundTransparency = 1,
							FontFace = theme.Typography.Body.Font,
							TextSize = theme.Typography.Body.Size,
							TextColor3 = theme.Colors.OnSurfaceVariant,
							TextWrapped = true,
							TextXAlignment = titleAlign,
							Text = props.Body,
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							LayoutOrder = 2,
						})
						else nil,
				},
			}),
			if props.Children then props.Children else nil,
			scope:Frame({
				Name = "Actions",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 10,
				Layout = {
					Kind = "List",
					FillDirection = if horizontal
						then Enum.FillDirection.Horizontal
						else Enum.FillDirection.Vertical,
					HorizontalFlex = if horizontal then Enum.UIFlexAlignment.Fill else nil,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = theme.Metrics.SpaceXs,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				Padding = { theme.Metrics.SpaceMd, 0, 0, 0 },
				[Children] = actionRow,
			}),
		},
	})

	-- Above sheets (110), so a dialog opened from a sheet is on top of it.
	local baseZ = props.ZIndex or 140
	local outlineStroke = scope:New("UIStroke")({
		Name = "DialogOutlineFlash",
		Parent = panel,
		Color = theme.Colors.Outline,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 2,
		Transparency = 1,
	})

	local scale = Instance.new("UIScale")
	scale.Parent = panel
	table.insert(
		scope,
		scope:Observer(openS):onBind(function()
			local t = peek(openS)
			if peek(open) then
				scale.Scale = 1.1 - 0.1 * t
			else
				scale.Scale = 0.9 + 0.1 * t
			end

			-- Pulse around t ~= 0.5 (as openS springs from 0 -> 1).
			local pulse = math.clamp(1 - math.abs(2 * t - 1), 0, 1)
			outlineStroke.Transparency = 1 - pulse * 0.85
			outlineStroke.Thickness = 1 + pulse * 2
		end)
	)

	local panelHost = CanvasFade.host(scope, panel, openS, { Theme = theme })

	local root = scope:Frame({
		Name = "Dialog",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		Visible = scope:Computed(function(use)
			return use(openS) > 0.02 and (props.Visible ~= false)
		end),
		ZIndex = baseZ,
		LayoutOrder = props.LayoutOrder or 0,
		[Children] = {
			scope:Apply(Overlay(scope, {
				Theme = theme,
				OnClick = props.OnClose,
				ZIndex = baseZ,
			}))({
				BackgroundTransparency = scope:Computed(function(use)
					return 1 - (use(openS) :: number) * 0.55
				end),
			}),
			scope:Frame({
				Name = "DialogCenter",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = baseZ + 1,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				},
				[Children] = { panelHost },
			}),
		},
	}) :: Frame

	Corners.setContainer(panel, radius)
	Layer.mount(scope, props, root)
	Focus.trap(scope, root, open)
	Focus.escape(scope, open, Focus.closer(props))
	return root
end
