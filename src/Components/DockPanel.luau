--!strict
--[[
	A panel with a header: a title or a strip of tabs, header actions, and content below.
	It can collapse to its header. See docs/Components/Layout/DockPanel.md.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local GroupFade = require(script.Parent.Parent.Internal.GroupFade)
local Icon = require(script.Parent.Icon)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local HEADER_HEIGHT = 32

return function(scope: Types.Scope, props: Types.DockPanelProps): Instance
	local theme = resolveTheme(props)
	local tabs = props.Tabs
	local hasTabs = tabs ~= nil and #tabs > 0

	local persistKey = Persist.key("DockPanel", false)
	local open = Persist.value(scope, persistKey, "open", peek(props.Open) ~= false)
	Bind.link(scope, props.Open, open)
	local selected = Persist.value(
		scope,
		persistKey,
		"selected",
		peek(props.Selected) or (if hasTabs then (tabs :: { Types.DockTab })[1].Id else "")
	)
	Bind.link(scope, props.Selected, selected)

	local openS = scope:Spring(
		scope:Computed(function(use)
			return if use(open) then 1 else 0
		end),
		theme.Motion.SpringSpeed,
		1
	)

	-- header
	local headerKids: { any } = {
		scope:New("UIListLayout")({
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 4),
		}),
		scope:New("UIPadding")({ PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 6) }),
	}

	if props.Collapsible then
		local arrow = scope:Apply(Icon(scope, {
			Theme = theme,
			Name = "chevron-down",
			IconSize = 16,
			Color = theme.Colors.OnSurfaceVariant,
		}))({
			LayoutOrder = 1,
			Rotation = scope:Computed(function(use)
				return -90 * (1 - (use(openS) :: number))
			end),
		})
		local toggle = scope:New("TextButton")({
			Name = "Toggle",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(20, 20),
			LayoutOrder = 1,
			[OnEvent("Activated")] = function()
				open:set(not peek(open))
			end,
			[Children] = { arrow } :: any,
		}) :: TextButton
		Interaction.bind(scope, theme, {}).wire(toggle)
		table.insert(headerKids, toggle)
	end

	-- The tab strip, with an underline that slides to the selected tab.
	local strip: Frame? = nil
	if hasTabs then
		local indicatorX = scope:Value(0)
		local indicatorW = scope:Value(0)
		local xS = scope:Spring(indicatorX, theme.Motion.SpringSpeed, 1)
		local wS = scope:Spring(indicatorW, theme.Motion.SpringSpeed, 1)
		local buttons: { [string]: TextButton } = {}
		local stripFrame = scope:New("Frame")({
			Name = "Tabs",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = 2,
		}) :: Frame
		strip = stripFrame
		local function place()
			local button = buttons[peek(selected) :: string]
			if button and stripFrame.AbsoluteSize.X > 0 then
				indicatorX:set(button.AbsolutePosition.X - stripFrame.AbsolutePosition.X)
				indicatorW:set(button.AbsoluteSize.X)
			end
		end
		local row = scope:New("Frame")({
			Name = "Row",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = stripFrame,
		}) :: Frame
		scope:New("UIListLayout")({
			Parent = row,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
		})
		for index, tab in tabs :: { Types.DockTab } do
			local ix = Interaction.bind(scope, theme, {})
			local label = scope:New("TextButton")({
				Name = tab.Id,
				Text = tab.Title,
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.new(0, 0, 1, 0),
				LayoutOrder = index,
				FontFace = theme.Typography.Label.Font,
				TextSize = A.size(theme, 13),
				TextColor3 = scope:Computed(function(use)
					local on = if use(selected) == tab.Id then 1 else 0
					return Interaction.lerpColor(
						use(theme.Colors.OnSurfaceVariant),
						use(theme.Colors.OnSurface),
						math.max(on, (use(ix.Hover) :: number) * 0.6),
						use
					)
				end),
				[OnEvent("Activated")] = function()
					selected:set(tab.Id)
					if props.OnChanged then
						props.OnChanged(tab.Id)
					end
				end,
				[Children] = scope:New("UIPadding")({
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
				}),
			}) :: TextButton
			ix.wire(label)
			buttons[tab.Id] = label
			label.Parent = row
			table.insert(scope, label:GetPropertyChangedSignal("AbsoluteSize"):Connect(place))
		end
		table.insert(
			scope,
			scope:Observer(selected):onChange(function()
				task.defer(place)
			end)
		)
		table.insert(scope, stripFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(place))
		task.defer(place)
		scope:New("Frame")({
			Name = "Underline",
			Parent = stripFrame,
			AnchorPoint = Vector2.new(0, 1),
			Position = scope:Computed(function(use)
				return UDim2.new(0, use(xS) :: number, 1, 0)
			end),
			Size = scope:Computed(function(use)
				return UDim2.fromOffset(math.max(use(wS) :: number, 0), 2)
			end),
			BackgroundColor3 = theme.Colors.Primary,
			BorderSizePixel = 0,
		})
		table.insert(headerKids, stripFrame)
	else
		table.insert(
			headerKids,
			scope:New("TextLabel")({
				Name = "Title",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				LayoutOrder = 2,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				FontFace = theme.Typography.Label.Font,
				TextSize = A.size(theme, 13),
				TextColor3 = theme.Colors.OnSurface,
				Text = props.Title or "",
				[Children] = scope:New("UIFlexItem")({ FlexMode = Enum.UIFlexMode.Fill }),
			})
		)
	end
	if strip then
		local flex = Instance.new("UIFlexItem")
		flex.FlexMode = Enum.UIFlexMode.Fill
		flex.Parent = strip
	end

	local actions: { Instance } = props.Actions or {}
	for index, action in actions do
		table.insert(headerKids, scope:Apply(action)({ LayoutOrder = 10 + index }))
	end
	if props.OnClose then
		local close = scope:New("TextButton")({
			Name = "Close",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(22, 22),
			LayoutOrder = 99,
			[OnEvent("Activated")] = props.OnClose,
			[Children] = {
				scope:Apply(Icon(scope, {
					Theme = theme,
					Name = "x",
					IconSize = 14,
					Color = theme.Colors.OnSurfaceVariant,
				}))({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
				}),
			} :: any,
		}) :: TextButton
		Interaction.bind(scope, theme, {}).wire(close)
		table.insert(headerKids, close)
	end

	local header = scope:New("Frame")({
		Name = "Header",
		BackgroundColor3 = theme.Colors.SurfaceContainer,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
		[Children] = headerKids,
	}) :: Frame

	-- content
	local content = scope:New("Frame")({
		Name = "Content",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Position = UDim2.fromOffset(0, HEADER_HEIGHT),
		Size = UDim2.new(1, 0, 1, -HEADER_HEIGHT),
		Visible = scope:Computed(function(use)
			return (use(openS) :: number) > 0.02
		end),
	}) :: Frame
	GroupFade.bind(scope, content, openS)

	if hasTabs then
		for _, tab in tabs :: { Types.DockTab } do
			local page = scope:Apply(tab.Content)({
				Parent = content,
				Visible = scope:Computed(function(use)
					return use(selected) == tab.Id
				end),
			})
			if page:IsA("GuiObject") then
				local gui = page :: GuiObject
				gui.Size = UDim2.fromScale(1, 1)
				gui.Position = UDim2.fromScale(0, 0)
			end
		end
	elseif props.Children then
		scope:New("Frame")({
			Name = "Body",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Parent = content,
			[Children] = props.Children,
		})
	end

	-- Collapsing shrinks the panel to its header: the height is the full height at 1 and the
	-- header at 0, whatever mix of scale and offset the full size is made of.
	local full = props.Size or UDim2.fromScale(1, 1)
	return scope:Frame({
		Name = "DockPanel",
		BackgroundColor3 = theme.Colors.Surface,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Size = if props.Collapsible
			then scope:Computed(function(use)
				local t = use(openS) :: number
				return UDim2.new(
					full.X.Scale,
					full.X.Offset,
					full.Y.Scale * t,
					full.Y.Offset * t + HEADER_HEIGHT * (1 - t)
				)
			end)
			else full,
		CornerRadius = theme.Metrics.RadiusSm,
		Outline = {
			Color = theme.Colors.OutlineVariant,
			Thickness = 1,
			Mode = Enum.ApplyStrokeMode.Border,
		},
		[Children] = { header, content },
	}) :: Frame
end
