--!strict
--[[
	Navigation drawer: AvatarMenu-style: rounded profile sheet on top, action
	buttons below (with optional categories + scroll).
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Focus = require(script.Parent.Parent.Internal.Focus)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Overlay = require(script.Parent.Overlay)
local Menu = require(script.Parent.Menu)

local Children = Fusion.Children

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
			})
		end
	end
	return out
end

return function(scope: Types.Scope, props: Types.NavigationDrawerProps): Instance
	local theme = resolveTheme(props)
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
		theme.Motion.SpringSpeed,
		theme.Motion.SpringDamping
	)

	local width = theme.Metrics.DrawerWidth
	local inset = props.Inset or 0
	local cornerRadius = props.CornerRadius
		or (if inset > 0 then theme.Metrics.RadiusPanel + 4 else theme.Metrics.RadiusPanel)
	local flatItems = if props.Sections then nil else normalizeItems(props.Items :: any)

	local menu = Menu(scope, {
		Theme = theme,
		Embedded = true,
		Open = open,
		OnClose = props.OnClose,
		Sections = props.Sections,
		Items = flatItems,
		Children = props.Children,
		RootPage = props.RootPage,
		Page = props.Page,
		OnChanged = props.OnChanged,
		MaxHeight = props.MaxHeight,
		Fill = props.MaxHeight == nil,
		Size = UDim2.new(0, width, 1, -inset * 2),
		CornerRadius = cornerRadius,
		-- Flush against the screen edge: only the inner corners are rounded.
		Corners = if inset > 0 then nil else { 0, cornerRadius, 0, cornerRadius },
		ZIndex = 61,
	})

	scope:Apply(menu)({
		Name = "DrawerPanel",
		Position = scope:Computed(function(use)
			local t = use(openS) :: number
			return UDim2.new(0, inset + (t - 1) * (width + inset), 0, inset)
		end),
		-- CanvasGroup wrap must stay transparent; the inner Menu is already opaque.
		BackgroundTransparency = if menu:IsA("CanvasGroup") then 1 else 0,
		ClipsDescendants = true,
	})

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
				OnClick = props.OnClose,
				CornerRadius = cornerRadius + inset,
				ZIndex = 60,
			}))({
				BackgroundTransparency = scope:Computed(function(use)
					local t = use(openS) :: number
					return 1 - t * 0.55
				end),
			}),
			menu,
		},
	}) :: Frame

	Layer.mount(scope, props, root)
	Focus.trap(scope, root, open)
	Focus.escape(scope, open, Focus.closer(props))
	return root
end
