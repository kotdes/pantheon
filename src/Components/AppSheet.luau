--!strict
--[[
	iOS-style bottom sheet: scrim + sliding panel mounted via Layer.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Focus = require(script.Parent.Parent.Internal.Focus)
local CanvasFade = require(script.Parent.Parent.Internal.CanvasFade)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Corners = require(script.Parent.Parent.Internal.Corners)
local Overlay = require(script.Parent.Overlay)
local IconButton = require(script.Parent.IconButton)

local Children = Fusion.Children

return function(scope: Types.Scope, props: Types.AppSheetProps): Instance
	local theme = resolveTheme(props)
	local detent = props.Detent or 0.92
	local showGrabber = props.ShowGrabber ~= false
	local openRef = props.Open
	local open = scope:Computed(function(use)
		if openRef == nil then
			return true
		end
		return (if typeof(openRef) == "table" then use(openRef) else openRef) == true
	end)
	local openS = scope:Spring(
		scope:Computed(function(use)
			return if use(open) then 1 else 0
		end),
		theme.Motion.SpringSpeed * 0.85,
		theme.Motion.SpringDamping
	)

	local headerKids: { any } = {
		scope:TextLabel({
			BackgroundTransparency = 1,
			FontFace = theme.Typography.Title.Font,
			TextSize = theme.Typography.Title.Size,
			TextColor3 = theme.Colors.OnSurface,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = props.Title or "",
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = 1,
		}),
		scope:Apply(IconButton(scope, {
			Theme = theme,
			Name = "x",
			OnClick = props.OnClose,
			Color = "surface",
			Variant = "Tonal",
		}))({
			LayoutOrder = 2,
			Size = UDim2.fromOffset(40, 40),
		}),
	}
	local titleLabel = headerKids[1]
	if titleLabel and titleLabel:IsA("GuiObject") then
		local flex = Instance.new("UIFlexItem")
		flex.FlexMode = Enum.UIFlexMode.Fill
		flex.Parent = titleLabel
	end

	local panelKids: { any } = {}
	if showGrabber then
		table.insert(
			panelKids,
			scope:Frame({
				Name = "Grabber",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 20),
				LayoutOrder = 1,
				Layout = {
					Kind = "List",
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				},
				[Children] = {
					scope:Frame({
						Size = UDim2.fromOffset(36, 4),
						BackgroundColor3 = theme.Colors.Outline,
						CornerRadius = theme.Metrics.RadiusPill,
					}),
				},
			})
		)
	end
	table.insert(
		panelKids,
		scope:Frame({
			Name = "Header",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 48),
			LayoutOrder = 2,
			Padding = { 0, theme.Metrics.SpaceMd },
			Layout = {
				Kind = "List",
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = theme.Metrics.SpaceXs,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			[Children] = headerKids,
		})
	)
	table.insert(
		panelKids,
		scope:Frame({
			Name = "Body",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = 3,
			Padding = { 0, theme.Metrics.SpaceMd },
			[Children] = { props.Children },
		})
	)

	-- TextButton sinks Overlay Activated; Frame.Active alone does not.
	local panel = scope:TextButton({
		Name = "AppSheetPanel",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = theme.Colors.Surface,
		Size = UDim2.new(1, 0, detent, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = CanvasFade.surfaceTransparency(scope, openS, { Theme = theme }),
		ZIndex = 111,
		Active = true,
		ClipsDescendants = true,
		CornerRadius = theme.Metrics.RadiusPanel,
		Layout = {
			Kind = "List",
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = panelKids,
	})

	-- Flush to the bottom edge: top corners round, bottom corners follow the enclosing Window
	-- (square when there is none).
	local sheetRadius: number = theme.Metrics.RadiusPanel
	table.insert(
		scope,
		Corners.followWindow(panel, function(windowRadius: number)
			Corners.apply(panel, sheetRadius, sheetRadius, windowRadius, windowRadius)
		end)
	)

	local host = CanvasFade.host(scope, panel, openS, { Theme = theme })
	scope:Apply(host)({
		Size = UDim2.new(1, 0, detent, 0),
		AnchorPoint = Vector2.new(0, 1),
		Position = scope:Computed(function(use)
			-- openS 0 → fully below; 1 → flush to bottom
			return UDim2.new(0, 0, 1 + (1 - use(openS)) * detent, 0)
		end),
	})

	local root = scope:Frame({
		Name = "AppSheet",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		Visible = scope:Computed(function(use)
			return use(openS) > 0.02 and (props.Visible ~= false)
		end),
		ZIndex = props.ZIndex or 110,
		LayoutOrder = props.LayoutOrder or 0,
		[Children] = {
			scope:Apply(Overlay(scope, {
				Theme = theme,
				OnClick = props.OnClose,
				ZIndex = 110,
			}))({
				BackgroundTransparency = scope:Computed(function(use)
					return 1 - (use(openS) :: number) * 0.55
				end),
			}),
			host,
		},
	}) :: Frame

	Layer.mount(scope, props, root)
	Focus.trap(scope, root, open)
	Focus.escape(scope, open, Focus.closer(props))
	return root
end
