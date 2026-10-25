--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local tr = require(script.Parent.Parent.Internal.Translate).t
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Focus = require(script.Parent.Parent.Internal.Focus)
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local CanvasFade = require(script.Parent.Parent.Internal.CanvasFade)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Layer = require(script.Parent.Parent.Internal.Layer)
local whileActive = require(script.Parent.Parent.Internal.Follow)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.SelectProps): Instance
	local theme = resolveTheme(props)
	local open = scope:Value(false)
	local openS = scope:Spring(
		scope:Computed(function(use)
			return if use(open) then 1 else 0
		end),
		theme.Motion.SpringSpeed,
		theme.Motion.SpringDamping
	)
	local selected = Persist.value(
		scope,
		Persist.key("Select", typeof(props.Value) == "table"),
		"value",
		(peek(props.Value) or "") :: string
	)
	Bind.link(scope, props.Value, selected)
	local filter = scope:Value("" :: string)
	local disabled = peek(props.Disabled) == true
	local hasLabel = props.Label ~= nil
	local closedHeight = (if hasLabel then 20 else 0) + 40

	local function labelFor(value: string): string
		for _, opt in props.Options do
			if opt.Value == value then
				return opt.Label
			end
		end
		return peek(props.Placeholder) or tr("select.placeholder", "Select…")
	end

	local menuChildren = scope:Computed(function(use)
		if use(openS) < 0.05 then
			return {}
		end
		local q = string.lower(tostring(use(filter)))
		local nodes = {}
		local order = 1
		for _, opt in props.Options do
			local hay = string.lower(opt.Label .. " " .. opt.Value)
			if q == "" or string.find(hay, q, 1, true) then
				local optValue = opt.Value
				local isSelected = tostring(use(selected)) == optValue
				local hover = scope:Value(0)
				local press = scope:Value(0)
				local hoverS =
					scope:Spring(hover, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
				local pressS =
					scope:Spring(press, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
				local base = if isSelected
					then use(theme.Colors.PrimaryContainer)
					else use(theme.Colors.Surface)
				local item = scope:TextButton({
					Text = opt.Label,
					FontFace = theme.Typography.Body.Font,
					TextSize = theme.Typography.Body.Size,
					TextColor3 = use(theme.Colors.OnSurface),
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundColor3 = scope:Computed(function(u)
						local alpha = math.clamp(
							(u(hoverS) :: number) * 0.08 + (u(pressS) :: number) * 0.12,
							0,
							0.2
						)
						return Interaction.lerpColor(base, u(theme.Colors.OnSurface), alpha)
					end),
					Size = UDim2.new(1, 0, 0, 40),
					LayoutOrder = order,
					AutoButtonColor = false,
					ClipsDescendants = true,
					CornerRadius = theme.Metrics.RadiusSm - theme.Metrics.Space2xs,
					Padding = { theme.Metrics.SpaceXs, theme.Metrics.SpaceSm },
					[OnEvent("Activated")] = function()
						selected:set(optValue)
						open:set(false)
						if props.OnChanged then
							props.OnChanged(optValue)
						end
					end,
					[OnEvent("MouseEnter")] = function()
						hover:set(1)
					end,
					[OnEvent("MouseLeave")] = function()
						hover:set(0)
						press:set(0)
					end,
					[OnEvent("MouseButton1Down")] = function()
						press:set(1)
					end,
					[OnEvent("MouseButton1Up")] = function()
						press:set(0)
					end,
				})
				table.insert(nodes, item)
				order += 1
			end
		end
		return nodes
	end)

	local triggerIx = Interaction.bind(scope, theme, {
		Disabled = disabled,
		StateColor = theme.Colors.OnSurface,
	})

	local fieldKids: { any } = {}
	if hasLabel then
		table.insert(
			fieldKids,
			scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Label.Font,
				TextSize = theme.Typography.Label.Size,
				TextColor3 = theme.Colors.OnSurfaceVariant,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = props.Label,
				Size = UDim2.new(1, 0, 0, 16),
				LayoutOrder = 1,
			})
		)
	end

	local trigger = scope:TextButton({
		Name = "Trigger",
		Text = scope:Computed(function(use)
			local v = use(selected)
			return if v ~= ""
				then labelFor(v)
				else (peek(props.Placeholder) or tr("select.placeholder", "Select…"))
		end),
		FontFace = theme.Typography.Body.Font,
		TextSize = theme.Typography.Body.Size,
		TextColor3 = theme.Colors.OnSurface,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundColor3 = triggerIx.fill(theme.Colors.SurfaceContainer),
		Size = UDim2.new(1, 0, 0, 40),
		LayoutOrder = 2,
		AutoButtonColor = false,
		Active = not disabled,
		ClipsDescendants = false,
		CornerRadius = theme.Metrics.RadiusSm,
		Padding = { theme.Metrics.SpaceSm, theme.Metrics.SpaceMd },
		Outline = {
			Color = theme.Colors.Outline,
			Thickness = 1,
			Mode = Enum.ApplyStrokeMode.Border,
		},
		[OnEvent("Activated")] = function()
			if not disabled then
				open:set(not peek(open))
			end
		end,
	}) :: TextButton
	triggerIx.wire(trigger)
	table.insert(fieldKids, trigger)

	-- Popover mounts to Layer when provided (does not push layout)
	local popover = scope:Frame({
		Name = "SelectPopover",
		BackgroundColor3 = theme.Colors.Surface,
		Size = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		Visible = CanvasFade.shown(scope, openS, nil, { Theme = theme }),
		BackgroundTransparency = CanvasFade.surfaceTransparency(scope, openS, { Theme = theme }),
		CornerRadius = theme.Metrics.RadiusSm,
		Outline = {
			Color = theme.Colors.Outline,
			Thickness = 1,
			Mode = Enum.ApplyStrokeMode.Border,
		},
		Padding = { theme.Metrics.Space2xs },
		Layout = {
			Kind = "List",
			Padding = 2,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		SizeConstraint = {
			MinSize = Vector2.new(160, 0),
		},
		Shadow = {
			BlurRadius = 8,
			Transparency = scope:Computed(function(use)
				return 1 - (use(openS) :: number) * 0.1
			end),
		},
		ZIndex = 200,
		[Children] = {
			menuChildren,
		},
	})

	local field = scope:Frame({
		Name = "Select",
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Size = props.Size or UDim2.new(1, 0, 0, closedHeight),
		LayoutOrder = props.LayoutOrder or 0,
		ZIndex = scope:Computed(function(use)
			local base = props.ZIndex
			local n = if typeof(base) == "number" then base else 1
			return if use(open) then math.max(n, 200) else n
		end),
		[Children] = {
			scope:Frame({
				Name = "Field",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Layout = {
					Kind = "List",
					Padding = 4,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = fieldKids,
			}),
		},
	}) :: Frame

	local chrome = CanvasFade.host(scope, popover, openS, { Theme = theme })
	if chrome ~= popover then
		popover.Size = UDim2.new(1, 0, 0, 0)
		popover.AutomaticSize = Enum.AutomaticSize.Y
	end
	local mounted = Layer.mount(scope, props, chrome)
	if not mounted then
		chrome.Parent = field
		chrome.Size = UDim2.new(1, 0, 0, 0)
		chrome.AutomaticSize = Enum.AutomaticSize.Y
		chrome.Position = UDim2.fromOffset(0, closedHeight + 4)
	else
		whileActive(scope, open, function(isOpen)
			return isOpen == true
		end, function()
			local layer = Layer.resolve(props)
			if layer == nil then
				return
			end
			local tp = trigger.AbsolutePosition
			local ts = trigger.AbsoluteSize
			local lp = layer.AbsolutePosition
			local bounds = layer.AbsoluteSize
			local width = math.max(ts.X, 160)
			local height = chrome.AbsoluteSize.Y
			local gap = 4
			local below = bounds.Y - (tp.Y - lp.Y + ts.Y + gap)
			local above = tp.Y - lp.Y - gap
			local flip = height > below and above > below
			local x = math.clamp(tp.X - lp.X, 0, math.max(bounds.X - width, 0))
			chrome.AnchorPoint = Vector2.new(0, if flip then 1 else 0)
			chrome.Position =
				UDim2.fromOffset(x, if flip then tp.Y - lp.Y - gap else tp.Y - lp.Y + ts.Y + gap)
			chrome.Size = UDim2.fromOffset(width, 0)
		end)
	end

	Focus.escape(scope, open, function()
		open:set(false)
	end)
	return field
end
