--!strict
--[[
	iOS-style bottom sheet: scrim + sliding panel mounted via Layer. The body scrolls. Dragging
	the grabber or the header up expands the sheet, and dragging it down collapses or dismisses it.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Focus = require(script.Parent.Parent.Internal.Focus)
local CanvasFade = require(script.Parent.Parent.Internal.CanvasFade)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Corners = require(script.Parent.Parent.Internal.Corners)
local ScrollInput = require(script.Parent.Parent.Internal.ScrollInput)
local Overlay = require(script.Parent.Overlay)
local IconButton = require(script.Parent.IconButton)
local ScrollArea = require(script.Parent.ScrollArea)

local Children = Fusion.Children
local peek = Fusion.peek

local GRABBER_HEIGHT = 24
local HEADER_HEIGHT = 48
-- How far the grabber or header must be dragged, in pixels, before the sheet reacts.
local EXPAND_DISTANCE = 40
local COLLAPSE_DISTANCE = 60
local DISMISS_DISTANCE = 140

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

	-- Dragging the grabber or the header. `pull` is the drag in pixels, negative upwards.
	local expanded = scope:Value(false)
	local pull = scope:Value(0)
	local layerHeight = scope:Value(600)
	local pullS = scope:Spring(pull, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
	local expandS = scope:Spring(
		scope:Computed(function(use)
			return if use(expanded) then 1 else 0
		end),
		theme.Motion.SpringSpeed,
		theme.Motion.SpringDamping
	)
	-- Height of the sheet as a fraction of its layer.
	local heightScale = scope:Computed(function(use)
		local layer = math.max(use(layerHeight), 1)
		local base = detent + (1 - detent) * use(expandS)
		local dragged = use(pullS)
		return math.clamp(base + (if dragged < 0 then -dragged / layer else 0), 0.1, 1)
	end)

	-- A sheet always opens collapsed and in place.
	table.insert(
		scope,
		scope:Observer(open):onChange(function()
			if peek(open) then
				expanded:set(false)
				pull:set(0)
				pullS:setPosition(0)
			end
		end)
	)

	local root: Frame

	local function attachDrag(handle: GuiObject)
		table.insert(
			scope,
			handle.InputBegan:Connect(function(input: InputObject)
				if
					input.UserInputType ~= Enum.UserInputType.MouseButton1
					and input.UserInputType ~= Enum.UserInputType.Touch
				then
					return
				end
				local startY = input.Position.Y
				local wasExpanded = peek(expanded)
				local layer = math.max(peek(layerHeight), 1)
				local highest = if wasExpanded then 0 else -(1 - detent) * layer

				ScrollInput.capture(root, function(move: InputObject)
					return move.UserInputType == Enum.UserInputType.MouseMovement
						or move.UserInputType == Enum.UserInputType.Touch
				end, function(ended: InputObject)
					return ended.UserInputType == Enum.UserInputType.MouseButton1
						or ended.UserInputType == Enum.UserInputType.Touch
				end, function(pointer: Vector3)
					local dragged = math.max(pointer.Y - startY, highest)
					pull:set(dragged)
					-- Follow the pointer at once. The spring only animates the release.
					pullS:setPosition(dragged)
				end, function()
					local dragged = peek(pull)
					local sheet = peek(heightScale) * layer
					local dismissAt = if wasExpanded
						then sheet * 0.4
						else math.min(sheet * 0.3, DISMISS_DISTANCE)
					if dragged > dismissAt then
						if props.OnClose then
							props.OnClose()
						end
						-- If the sheet stays open, bring it back. If it closes, it slides away
						-- from where it was dropped.
						if peek(open) then
							pull:set(0)
						end
						return
					elseif wasExpanded and dragged > COLLAPSE_DISTANCE then
						expanded:set(false)
					elseif not wasExpanded and dragged < -EXPAND_DISTANCE then
						expanded:set(true)
					end
					pull:set(0)
				end)
			end)
		)
	end

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
			-- A role name follows the theme. A colour is resolved once, so it would stay light.
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
		local grabber = scope:Frame({
			Name = "Grabber",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, GRABBER_HEIGHT),
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
		}) :: Frame
		attachDrag(grabber)
		table.insert(panelKids, grabber)
	end

	local header = scope:Frame({
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
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
	}) :: Frame
	attachDrag(header)
	table.insert(panelKids, header)

	-- The body takes the rest of the height and scrolls when the content is taller.
	local chrome = HEADER_HEIGHT + (if showGrabber then GRABBER_HEIGHT else 0)
	table.insert(
		panelKids,
		scope:Frame({
			Name = "Body",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, -chrome),
			LayoutOrder = 3,
			Padding = { 0, theme.Metrics.SpaceMd },
			[Children] = {
				ScrollArea(scope, {
					Theme = theme,
					Size = UDim2.fromScale(1, 1),
					ContentPadding = theme.Metrics.SpaceXs,
					ListPadding = theme.Metrics.SpaceSm,
					Children = props.Children,
				}),
			},
		})
	)

	-- TextButton sinks Overlay Activated; Frame.Active alone does not.
	local panel = scope:TextButton({
		Name = "AppSheetPanel",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = theme.Colors.Surface,
		-- The host sets the size and the position.
		Size = UDim2.fromScale(1, 1),
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
		Size = scope:Computed(function(use)
			return UDim2.new(1, 0, use(heightScale), 0)
		end),
		AnchorPoint = Vector2.new(0, 1),
		Position = scope:Computed(function(use)
			-- openS 0 → fully below; 1 → flush to bottom. Pulling down moves it lower still.
			local height = use(heightScale)
			return UDim2.new(0, 0, 1 + (1 - use(openS)) * height, math.max(use(pullS), 0))
		end),
	})

	root = scope:Frame({
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

	table.insert(
		scope,
		root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			layerHeight:set(root.AbsoluteSize.Y)
		end)
	)

	Layer.mount(scope, props, root)
	Focus.trap(scope, root, open)
	Focus.escape(scope, open, Focus.closer(props))
	return root
end
