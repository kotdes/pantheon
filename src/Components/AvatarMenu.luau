--!strict
--[[
	Avatar account sheet / popover: profile header + Menu actions.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local Motion = require(script.Parent.Parent.Internal.Motion)
local Morph = require(script.Parent.Parent.Internal.Morph)
local Presence = require(script.Parent.Parent.Internal.Presence)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Focus = require(script.Parent.Parent.Internal.Focus)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Follow = require(script.Parent.Parent.Internal.Follow)
local Overlay = require(script.Parent.Overlay)
local Avatar = require(script.Parent.Avatar)
local Menu = require(script.Parent.Menu)
local GroupFade = require(script.Parent.Parent.Internal.GroupFade)

local Children = Fusion.Children
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.AvatarMenuProps): Instance
	local theme = resolveTheme(props)
	local openRef = props.Open
	local open = scope:Computed(function(use)
		if openRef == nil then
			return true
		end
		return (if typeof(openRef) == "table" then use(openRef) else openRef) == true
	end)
	local width = 280
	local pos = scope:Value(UDim2.fromOffset(16, 72))

	local header = scope:Frame({
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.SpaceSm,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		Padding = { 0, 0, 4, 0 },
		[Children] = {
			scope:Frame({
				Name = "Profile",
				BackgroundTransparency = 0,
				BackgroundColor3 = theme.Colors.SurfaceDim,
				CornerRadius = theme.Metrics.RadiusPanel - 4 / 2,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 1,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = theme.Metrics.SpaceSm,
				},
				Padding = { theme.Metrics.SpaceMd, 0 },
				[Children] = {
					Avatar(scope, {
						Theme = theme,
						Image = props.Image,
						Initials = props.Initials or "?",
						AvatarSize = 52,
					}),
					scope:Frame({
						BackgroundTransparency = 1,
						AutomaticSize = Enum.AutomaticSize.XY,
						Layout = {
							Kind = "List",
							Padding = 2,
							SortOrder = Enum.SortOrder.LayoutOrder,
						},
						[Children] = {
							scope:TextLabel({
								BackgroundTransparency = 1,
								FontFace = theme.Typography.Title.Font,
								TextSize = theme.Typography.Title.Size,
								TextColor3 = theme.Colors.OnSurface,
								TextXAlignment = Enum.TextXAlignment.Left,
								Text = props.Name or "Account",
								AutomaticSize = Enum.AutomaticSize.XY,
								LayoutOrder = 1,
							}),
							if props.Subtitle
								then scope:TextLabel({
									BackgroundTransparency = 1,
									FontFace = theme.Typography.Body.Font,
									TextSize = theme.Typography.Label.Size,
									TextColor3 = theme.Colors.OnSurfaceVariant,
									TextXAlignment = Enum.TextXAlignment.Left,
									Text = props.Subtitle,
									AutomaticSize = Enum.AutomaticSize.XY,
									LayoutOrder = 2,
								})
								else nil,
						},
					}),
				},
			}),
		},
	})

	-- TODO: When AvatarMenu is nested, the return to main content button in the nested page component may have additional spacing at the top.
	local onRoot = scope:Value(true)
	local rootId = props.RootPage or "root"
	local profileShown = Motion.spring(
		scope,
		scope:Computed(function(use)
			return if use(onRoot) then 1 else 0
		end),
		theme,
		"Soft"
	)
	local natural = scope:Value(0)
	local function measure()
		natural:set(header.AbsoluteSize.Y)
	end
	table.insert(scope, header:GetPropertyChangedSignal("AbsoluteSize"):Connect(measure))
	task.defer(measure)
	scope:Apply(header)({
		Position = scope:Computed(function(use)
			return UDim2.fromScale(-(1 - math.clamp(use(profileShown), 0, 1)), 0)
		end),
	})
	GroupFade.bind(
		scope,
		header,
		scope:Computed(function(use)
			return math.clamp(use(profileShown), 0, 1)
		end)
	)
	local headerSlot = scope:Frame({
		Name = "HeaderSlot",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		LayoutOrder = 1,
		Size = scope:Computed(function(use)
			local t = math.clamp(use(profileShown), 0, 1)
			return UDim2.new(1, 0, 0, math.floor(use(natural) * t + 0.5))
		end),
		[Children] = { header },
	})

	local menu = Menu(scope, {
		Theme = theme,
		Embedded = true,
		OnChanged = function(id: string)
			onRoot:set(id == rootId)
		end,
		Open = open,
		OnClose = props.OnClose,
		Items = props.Items or {},
		Sections = props.Sections,
		Children = props.Children,
		RootPage = props.RootPage,
		Header = headerSlot,
		MaxHeight = props.MaxHeight,
		Size = UDim2.fromOffset(width, 0),
		ZIndex = (props.ZIndex or 95) + 1,
	})

	local shape = if Presence.fromOrigin(theme)
		then Morph.create(scope, {
			Theme = theme,
			Open = open,
			Content = menu :: GuiObject,
			ZIndex = (props.ZIndex or 95) + 1,
		})
		else nil
	local presence = if shape
		then shape.Presence
		else Presence.create(scope, open, theme, "Bouncy", 0.9)
	local openS = presence.Progress

	scope:Apply(menu)({
		Name = "AvatarMenuPanel",
		Position = if shape then UDim2.fromOffset(0, 0) else pos,
	})

	if not shape then
		local grow = Instance.new("UIScale")
		grow.Parent = menu
		table.insert(
			scope,
			scope:Observer(openS):onBind(function()
				grow.Scale = Presence.scaleAt(theme, peek(openS))
			end)
		)
	end

	local function updatePosition()
		local target = Layer.asGui(props.Target)
		local layer = Layer.resolve(props)
		if target == nil or layer == nil then
			return
		end
		local tp = target.AbsolutePosition
		local ts = target.AbsoluteSize
		local lp = layer.AbsolutePosition
		local x = tp.X - lp.X + ts.X - width
		local y = tp.Y - lp.Y + ts.Y + 8
		local at = Vector2.new(math.max(12, x), math.max(12, y))
		pos:set(UDim2.fromOffset(at.X, at.Y))
		if shape then
			shape.measure(
				Layer.asGui(props.MorphTarget) or target,
				layer,
				at,
				(menu :: GuiObject).AbsoluteSize
			)
		end
	end

	Follow(scope, open, function(v)
		return v == true
	end, updatePosition)

	local root = scope:Frame({
		Name = "AvatarMenu",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = scope:Computed(function(use)
			return use(presence.Mounted)
		end),
		ZIndex = props.ZIndex or 95,
		[Children] = {
			scope:Apply(Overlay(scope, {
				Theme = theme,
				OnClick = props.OnClose,
				ZIndex = props.ZIndex or 95,
			}))({
				BackgroundTransparency = scope:Computed(function(use)
					return 1 - math.clamp(use(openS) :: number, 0, 1) * 0.4
				end),
			}),
			if shape then shape.Instance else menu,
		},
	}) :: Frame

	Layer.mount(scope, props, root)
	Focus.trap(scope, root, open)
	Focus.escape(scope, open, Focus.closer(props))
	return root
end
