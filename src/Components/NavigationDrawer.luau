--!strict
--[[
	Navigation drawer: AvatarMenu-style: rounded profile sheet on top, action
	buttons below (with optional categories + scroll).

	With `DockAt` the drawer stays open beside the content once its parent is wide enough, like
	the sidebar of a desktop app. It tells a Window how much room it takes with the
	`PantheonDockWidth` attribute, and the Window moves its content over.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Focus = require(script.Parent.Parent.Internal.Focus)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Corners = require(script.Parent.Parent.Internal.Corners)
local Overlay = require(script.Parent.Overlay)
local Menu = require(script.Parent.Menu)

local Children = Fusion.Children
local peek = Fusion.peek

-- Width in pixels that a docked drawer takes, set on its root. Window reads it.
local DOCK_ATTRIBUTE = "PantheonDockWidth"

local function normalizeItems(raw: { any }?): { Types.MenuItemProps }
	local out: { Types.MenuItemProps } = {}
	if raw == nil then
		return out
	end
	for _, item in raw do
		local text = item.Text or item.Title
		if typeof(text) == "string" then
			table.insert(out, {
				Text = text,
				OnClick = item.OnClick,
				Disabled = item.Disabled,
				Leading = item.Leading,
				Trailing = item.Trailing,
				LeadingIcon = item.LeadingIcon,
				TrailingIcon = item.TrailingIcon,
				Color = item.Color,
				Page = item.Page,
				Selected = item.Selected,
			})
		end
	end
	return out
end

return function(scope: Types.Scope, props: Types.NavigationDrawerProps): Instance
	local theme = resolveTheme(props)
	local dockAt = props.DockAt
	local openRef = props.Open
	local open = scope:Computed(function(use)
		if openRef == nil then
			return true
		end
		return (if typeof(openRef) == "table" then use(openRef) else openRef) == true
	end)
	local docked = scope:Value(false)
	-- A docked drawer is always shown. A floating one follows `Open`.
	local shown = scope:Computed(function(use)
		return use(docked) or use(open)
	end)
	local modal = scope:Computed(function(use)
		return use(open) and not use(docked)
	end)
	local openS = scope:Spring(
		scope:Computed(function(use)
			return if use(shown) then 1 else 0
		end),
		theme.Motion.SpringSpeed,
		theme.Motion.SpringDamping
	)

	-- The width follows `Width` with a spring, so a drawer that gets narrower or wider glides.
	local widthGoal = scope:Computed(function(use)
		local given = if props.Width ~= nil then use(props.Width :: any) else nil
		return given or theme.Metrics.DrawerWidth
	end)
	local widthS = scope:Spring(widthGoal, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
	local inset = props.Inset or (if props.Sidebar then theme.Metrics.SidebarInset else 0)
	local cornerRadius = props.CornerRadius
		or (if inset > 0 then theme.Metrics.RadiusPanel + 4 else theme.Metrics.RadiusPanel)
	local flatItems = if props.Sections then nil else normalizeItems(props.Items :: any)

	-- A docked drawer does not close, so pressing a row does not run `OnClose`.
	local closeFloating = Focus.closer(props)
	local function close()
		if not peek(docked) then
			closeFloating()
		end
	end

	local menu = Menu(scope, {
		Theme = theme,
		Layer = props.Layer,
		Embedded = true,
		Open = shown,
		Header = props.Header,
		Footer = props.Footer,
		HideScrollBar = props.HideScrollBar,
		OnClose = close,
		Sections = props.Sections,
		Items = flatItems,
		Children = props.Children,
		RootPage = props.RootPage,
		Page = props.Page,
		OnChanged = props.OnChanged,
		MaxHeight = props.MaxHeight,
		Fill = props.MaxHeight == nil,
		Background = if props.Sidebar then theme.Colors.Sidebar else nil,
		BorderColor = if props.Sidebar then theme.Colors.SidebarSelected else nil,
		Size = scope:Computed(function(use)
			return UDim2.new(0, use(widthS), 1, -inset * 2)
		end),
		CornerRadius = cornerRadius,
		-- Flush against the screen edge: only the inner corners are rounded.
		Corners = if inset > 0 then nil else { 0, cornerRadius, 0, cornerRadius },
		ZIndex = 61,
	})

	scope:Apply(menu)({
		Name = "DrawerPanel",
		Position = scope:Computed(function(use)
			local t = use(openS) :: number
			return UDim2.new(0, inset + (t - 1) * (use(widthS) + inset), 0, inset)
		end),
		-- CanvasGroup wrap must stay transparent; the inner Menu is already opaque.
		BackgroundTransparency = if menu:IsA("CanvasGroup") then 1 else 0,
		ClipsDescendants = true,
	})

	-- The panel is a container: what sits inside it rounds itself to fit. Unless the caller chose a
	-- radius, the panel itself is concentric with the window around it.
	local panel = if menu:IsA("CanvasGroup") then menu:FindFirstChild("Menu") else menu
	if panel and panel:IsA("GuiObject") then
		Corners.setContainer(panel, cornerRadius)
		if props.CornerRadius == nil then
			task.defer(function()
				if panel.Parent and Corners.container(panel) ~= nil then
					Corners.auto(panel, nil, cornerRadius, { Container = true })
				end
			end)
		end
	end

	local root = scope:Frame({
		Name = "NavigationDrawer",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = scope:Computed(function(use)
			return use(openS) > 0.02
		end),
		ZIndex = props.ZIndex or 60,
		[Children] = {
			scope:Apply(Overlay(scope, {
				Theme = theme,
				OnClick = close,
				CornerRadius = cornerRadius + inset,
				ZIndex = 60,
			}))({
				-- No scrim while docked: the content beside the drawer stays in use.
				Visible = scope:Computed(function(use)
					return not use(docked)
				end),
				BackgroundTransparency = scope:Computed(function(use)
					local t = use(openS) :: number
					return 1 - t * 0.55
				end),
			}),
			menu,
		},
	}) :: Frame

	if dockAt ~= nil then
		root:SetAttribute(DOCK_ATTRIBUTE, 0)
		local function update()
			local want = root.AbsoluteSize.X >= peek(dockAt :: any)
			if want == peek(docked) then
				return
			end
			docked:set(want)
			root:SetAttribute(DOCK_ATTRIBUTE, if want then peek(widthGoal) + inset * 2 else 0)
			if props.OnDockChanged then
				props.OnDockChanged(want)
			end
		end
		table.insert(scope, root:GetPropertyChangedSignal("AbsoluteSize"):Connect(update))
		-- A dock limit that changes docks or floats the drawer at once.
		if typeof(dockAt) == "table" then
			table.insert(scope, scope:Observer(dockAt :: any):onChange(update))
		end
		-- A docked drawer that changes width tells the window how far to move the content.
		table.insert(
			scope,
			scope:Observer(widthGoal):onChange(function()
				if peek(docked) then
					root:SetAttribute(DOCK_ATTRIBUTE, peek(widthGoal) + inset * 2)
				end
			end)
		)
		task.defer(update)
	end

	Layer.mount(scope, props, root)
	Focus.trap(scope, root, modal)
	Focus.escape(scope, modal, close)
	return root
end
