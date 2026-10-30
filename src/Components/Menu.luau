--!strict
--[[
	Menu panel: chrome, scroll, overlay. Compose with MenuSection / MenuButton /
	MenuPage, or pass Items / Sections for a data-driven list.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local Defaults = require(script.Parent.Parent.Internal.Defaults)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local CanvasFade = require(script.Parent.Parent.Internal.CanvasFade)
local Corners = require(script.Parent.Parent.Internal.Corners)
local Layer = require(script.Parent.Parent.Internal.Layer)
local MenuNav = require(script.Parent.Parent.Internal.MenuNav)
local ScrollArea = require(script.Parent.ScrollArea)
local MenuSection = require(script.Parent.MenuSection)
local Button = require(script.Parent.Button)
local Divider = require(script.Parent.Divider)

local Children = Fusion.Children
local peek = Fusion.peek

local PAGE_ID = "PantheonMenuPageId"
local PAGE_TITLE = "PantheonMenuPageTitle"

local function resolveSections(props: Types.MenuProps): { Types.MenuSectionProps }
	if props.Sections ~= nil and #props.Sections > 0 then
		return props.Sections
	end
	return { { Items = props.Items or {} } }
end

local function collectInstances(value: any, out: { Instance })
	if typeof(value) == "Instance" then
		table.insert(out, value)
	elseif typeof(value) == "table" then
		for _, child in value do
			collectInstances(child, out)
		end
	end
end

local function copyStack(stack: { string }): { string }
	local nextStack = table.create(#stack)
	for i, id in stack do
		nextStack[i] = id
	end
	return nextStack
end

return function(scope: Types.Scope, props: Types.MenuProps): Instance
	local theme = resolveTheme(props)
	local outlined = Defaults.outlined(theme, "Menu", props.Outlined)
	local open = if props.Open == nil then true else props.Open
	local openS = scope:Spring(
		scope:Computed(function(use)
			local o = open
			local isOpen = if typeof(o) == "table" then use(o) else o
			return if isOpen then 1 else 0
		end),
		theme.Motion.SpringSpeed,
		theme.Motion.SpringDamping
	)

	local hasHeader = props.Header ~= nil
	local fill = props.Fill == true
	local maxHeight = props.MaxHeight
	-- The menu is as tall as its content, up to `MaxHeight`, and changes height with a spring.
	local autoHeight = props.AutoHeight ~= false and not fill

	--- A spring that follows a measured content height, never above `maxHeight`. It gives
	--- `fallback` until the content has been measured.
	local function followHeight(natural: any, fallback: number): any
		local target = scope:Computed(function(use)
			local measured = use(natural) :: number
			if measured <= 0 then
				return fallback
			end
			return if maxHeight ~= nil and maxHeight > 0
				then math.min(measured, maxHeight)
				else measured
		end)
		return scope:Spring(target, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
	end
	local pad = props.Padding or 4
	local compact = not hasHeader
	local radius = props.CornerRadius or theme.Metrics.RadiusPanel

	local composed: { Instance } = {}
	collectInstances(props.Children, composed)

	local pageInsts: { Instance } = {}
	local restKids: { any } = {}
	for _, inst in composed do
		local id = inst:GetAttribute(PAGE_ID)
		if typeof(id) == "string" and id ~= "" then
			table.insert(pageInsts, inst)
		else
			table.insert(restKids, inst)
		end
	end

	local listKids: { any } = {}
	local hasData = (props.Sections ~= nil and #props.Sections > 0)
		or (props.Items ~= nil and #(props.Items :: { Types.MenuItemProps }) > 0)

	if hasData then
		local rowsBefore = 0
		for sectionIndex, section in resolveSections(props) do
			table.insert(
				listKids,
				MenuSection(scope, {
					Theme = theme,
					Layer = props.Layer,
					Title = section.Title,
					Icon = section.Icon,
					Items = section.Items,
					Children = section.Children,
					Collapsible = section.Collapsible == true,
					Expanded = section.Expanded,
					OnChanged = section.OnChanged,
					Compact = if section.Compact ~= nil then section.Compact else compact,
					OnClose = props.OnClose,
					Progress = openS,
					StaggerFrom = rowsBefore,
					LayoutOrder = sectionIndex,
				})
			)
			rowsBefore += #(section.Items or {})
		end
	end

	for _, inst in restKids do
		table.insert(listKids, inst)
	end

	if fill then
		table.insert(
			listKids,
			scope:Frame({
				Name = "CornerClearance",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, math.max(radius - pad, 8)),
				LayoutOrder = 10_000,
			})
		)
	end

	local function makeScroll(kids: any, order: number, stretch: boolean): Instance
		local useScroll = stretch or fill or (maxHeight ~= nil and maxHeight > 0) or #pageInsts > 0
		if not useScroll then
			return scope:Frame({
				Name = "MenuList",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = order,
				Layout = {
					Kind = "List",
					Padding = 1,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = kids,
			})
		end
		local bodySize: any = if stretch or fill
			then UDim2.new(1, 0, 0, 0)
			else UDim2.new(1, 0, 0, maxHeight :: number)
		local bodyKids = kids
		if not stretch and not fill and autoHeight then
			-- Measure the content, and give the scroll area that height, up to `maxHeight`.
			local natural = scope:Value(0)
			local content = scope:Frame({
				Name = "MenuContent",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Layout = {
					Kind = "List",
					Padding = 6,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = kids,
			}) :: GuiObject
			table.insert(
				scope,
				content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					-- The scroll area insets its content by 2 px on each side.
					natural:set(content.AbsoluteSize.Y + 4)
				end)
			)
			local height = followHeight(natural, maxHeight :: number)
			bodySize = scope:Computed(function(use)
				return UDim2.new(1, 0, 0, math.floor((use(height) :: number) + 0.5))
			end)
			bodyKids = { content }
		end
		local body = ScrollArea(scope, {
			Theme = theme,
			Size = bodySize,
			LayoutOrder = order,
			ContentLayout = "List" :: "List",
			ContentPadding = 0,
			ListPadding = 6,
			ScrollBarThickness = 4,
			ScrollBarPadding = 4,
			ScrollBarRailBackground = false,
			ScrollButtons = false,
			AutoHideScrollBar = true,
			ScrollBarHidden = props.HideScrollBar,
			Children = bodyKids,
		})
		body.Name = "MenuScroll"
		if stretch or fill then
			local flex = Instance.new("UIFlexItem")
			flex.FlexMode = Enum.UIFlexMode.Fill
			flex.Parent = body
		end
		return body
	end

	local listBody: Instance
	if #pageInsts > 0 then
		local pageById: { [string]: Instance } = {}
		local pageOrder: { string } = {}
		for _, inst in pageInsts do
			local id = inst:GetAttribute(PAGE_ID) :: string
			pageById[id] = inst
			table.insert(pageOrder, id)
		end

		if #listKids > 0 then
			local rootId = props.RootPage or pageOrder[1] or "root"
			if not pageById[rootId] then
				local implicit = scope:Frame({
					Name = "MenuPage",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Layout = {
						Kind = "List",
						Padding = 1,
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					[Children] = listKids,
				})
				implicit:SetAttribute(PAGE_ID, rootId)
				pageById[rootId] = implicit
				table.insert(pageOrder, 1, rootId)
			else
				-- Data/rest content lives on the root page: parent into it.
				for _, kid in listKids do
					if typeof(kid) == "Instance" then
						kid.Parent = pageById[rootId]
					end
				end
			end
		end

		local initial = props.RootPage or pageOrder[1]
		local stack = scope:Value({ initial } :: { string })
		local depth = scope:Computed(function(use)
			return #use(stack)
		end)
		local depthS = scope:Spring(depth, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
		local lastIndex: { [string]: number } = {}
		lastIndex[initial] = 1

		local function remember(s: { string })
			for n, id in s do
				lastIndex[id] = n
			end
		end

		local function currentId(): string?
			local s = peek(stack)
			return s[#s]
		end

		local function emitPage()
			if props.OnChanged then
				local id = currentId()
				if id then
					props.OnChanged(id)
				end
			end
		end

		local function push(id: string)
			if not pageById[id] then
				return
			end
			local s = copyStack(peek(stack))
			if s[#s] == id then
				return
			end
			table.insert(s, id)
			remember(s)
			stack:set(s)
			emitPage()
		end

		local function pop()
			local s = copyStack(peek(stack))
			if #s <= 1 then
				return
			end
			table.remove(s)
			remember(s)
			stack:set(s)
			emitPage()
		end

		if props.Page ~= nil then
			table.insert(
				scope,
				scope
					:Observer(scope:Computed(function(use)
						local p = props.Page
						return if typeof(p) == "table" then use(p) else p
					end))
					:onBind(function()
						local want = peek(props.Page)
						if typeof(want) ~= "string" or want == "" then
							return
						end
						local s = peek(stack)
						for i = #s, 1, -1 do
							if s[i] == want then
								if i == #s then
									return
								end
								local nextStack = table.create(i)
								for j = 1, i do
									nextStack[j] = s[j]
								end
								stack:set(nextStack)
								remember(nextStack)
								emitPage()
								return
							end
						end
						push(want)
					end)
			)
		end

		local slides: { any } = {}
		-- The height each page wants, so the menu can follow the page that is showing.
		local pageHeights = scope:Value({} :: { [string]: number })
		for _, pageId in pageOrder do
			local pageInst = pageById[pageId]
			local titleAttr = pageInst:GetAttribute(PAGE_TITLE)
			local hasTitle = typeof(titleAttr) == "string" and titleAttr ~= ""

			local backBar = nil
			if hasTitle then
				backBar = scope:Frame({
					Name = "BackBar",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					LayoutOrder = 1,
					Visible = scope:Computed(function(use)
						return #use(stack) > 1
					end),
					Layout = {
						Kind = "List",
						Padding = theme.Metrics.Space2xs,
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					Padding = { 0, 0, theme.Metrics.Space2xs, 0 },
					[Children] = {
						scope:Apply(Button(scope, {
							Theme = theme,
							Variant = "Text" :: "Text",
							Text = titleAttr :: string,
							LeadingIcon = "chevron-left",
							OnClick = pop,
							CornerRadius = theme.Metrics.RadiusPanel - 4,
							Padding = { 0, theme.Metrics.SpaceSm },
							Size = UDim2.new(1, 0, 0, 40),
							HorizontalAlignment = Enum.HorizontalAlignment.Left,
						}))({
							LayoutOrder = 1,
							AutomaticSize = Enum.AutomaticSize.None,
						}),
						-- Bleed past Menu chrome padding so the rule hits the panel edge.
						scope:Frame({
							Name = "BackBarDivider",
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 1),
							LayoutOrder = 2,
							ClipsDescendants = false,
							[Children] = {
								scope:Apply(Divider(scope, {
									Theme = theme,
								}))({
									Size = UDim2.new(1, pad * 2, 0, 1),
									Position = UDim2.fromOffset(-pad, 0),
								}),
							},
						}),
					},
				})
			end

			if autoHeight then
				local function measure()
					-- The scroll area insets its content by 2 px on each side.
					local height = (pageInst :: GuiObject).AbsoluteSize.Y + 4
					if backBar and (backBar :: GuiObject).Visible then
						height += (backBar :: GuiObject).AbsoluteSize.Y
					end
					local heights = table.clone(peek(pageHeights))
					heights[pageId] = height
					pageHeights:set(heights)
				end
				table.insert(
					scope,
					(pageInst :: GuiObject)
						:GetPropertyChangedSignal("AbsoluteSize")
						:Connect(measure)
				)
				if backBar then
					table.insert(
						scope,
						(backBar :: GuiObject)
							:GetPropertyChangedSignal("AbsoluteSize")
							:Connect(measure)
					)
					table.insert(
						scope,
						(backBar :: GuiObject):GetPropertyChangedSignal("Visible"):Connect(measure)
					)
				end
			end

			local scrollKids: { any } = { pageInst }
			if fill then
				table.insert(
					scrollKids,
					scope:Frame({
						Name = "CornerClearance",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, math.max(radius - pad, 8)),
						LayoutOrder = 10_000,
					})
				)
			end

			local function slotOf(s: { string }): number
				for n, id in s do
					if id == pageId then
						return n
					end
				end
				return lastIndex[pageId] or (#s + 1)
			end

			table.insert(
				slides,
				scope:Frame({
					Name = "PageSlide_" .. pageId,
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Position = scope:Computed(function(use)
						local s = use(stack) :: { string }
						local t = use(depthS) :: number
						return UDim2.fromScale(slotOf(s) - t, 0)
					end),
					Visible = scope:Computed(function(use)
						local s = use(stack) :: { string }
						for _, id in s do
							if id == pageId then
								return true
							end
						end
						return false
					end),
					ClipsDescendants = true,
					Layout = {
						Kind = "List",
						Padding = 0,
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					[Children] = { backBar, makeScroll(scrollKids, 2, true) },
				})
			)
		end

		local hostHeight: any
		if fill then
			hostHeight = UDim2.new(1, 0, 0, 0)
		elseif autoHeight then
			local wanted = scope:Computed(function(use)
				local s = use(stack) :: { string }
				return (use(pageHeights) :: { [string]: number })[s[#s]] or 0
			end)
			local height = followHeight(wanted, maxHeight or 280)
			hostHeight = scope:Computed(function(use)
				return UDim2.new(1, 0, 0, math.floor((use(height) :: number) + 0.5))
			end)
		else
			hostHeight = UDim2.new(1, 0, 0, maxHeight or 280)
		end
		listBody = scope:Frame({
			Name = "PageHost",
			BackgroundTransparency = 1,
			Size = hostHeight,
			ClipsDescendants = true,
			LayoutOrder = 10,
			[Children] = slides,
		})
		if fill then
			local flex = Instance.new("UIFlexItem")
			flex.FlexMode = Enum.UIFlexMode.Fill
			flex.Parent = listBody
		end

		-- Bind after instance exists; menu is created below so we bind on listBody's parent later.
		(scope :: any)._pantheonMenuNav = { push = push, pop = pop, page = currentId }
	else
		listBody = makeScroll(listKids, 10, false)
	end

	local kids: { any } = {}
	if props.Header then
		local flex = Instance.new("UIFlexItem")
		flex.FlexMode = Enum.UIFlexMode.None
		flex.Parent = props.Header
		table.insert(kids, props.Header)
	end
	table.insert(kids, listBody)
	if props.Footer then
		local flex = Instance.new("UIFlexItem")
		flex.FlexMode = Enum.UIFlexMode.None
		flex.Parent = props.Footer;
		(props.Footer :: any).LayoutOrder = 20
		table.insert(kids, props.Footer)
	end

	local menu = scope:TextButton({
		Name = "Menu",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = props.Background or theme.Colors.Surface,
		Shadow = {
			BlurRadius = 8,
			Transparency = 0.9,
		},
		Size = props.Size or UDim2.fromOffset(220, 0),
		AutomaticSize = if fill then Enum.AutomaticSize.None else Enum.AutomaticSize.Y,
		Visible = CanvasFade.shown(scope, openS, nil, { Theme = theme }),
		BackgroundTransparency = props.BackgroundTransparency
			or CanvasFade.surfaceTransparency(scope, openS, { Theme = theme }),
		Active = true,
		ClipsDescendants = fill or #pageInsts > 0,
		ZIndex = props.ZIndex or 80,
		LayoutOrder = props.LayoutOrder or 0,
		-- `Corners` lets docked panels round only some corners ({tl, tr, bl, br}).
		CornerRadius = props.Corners or radius,
		Outline = if outlined
			then {
				Color = props.BorderColor
					or (if hasHeader then theme.Colors.OutlineVariant else theme.Colors.Outline),
				Thickness = 1,
				Mode = Enum.ApplyStrokeMode.Border,
			}
			else nil,
		Padding = pad,
		Layout = {
			Kind = "List",
			Padding = if hasHeader then theme.Metrics.SpaceSm else 1,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalFlex = if fill then Enum.UIFlexAlignment.Fill else nil,
		},
		[Children] = kids,
	}) :: TextButton
	-- The menu is a container: its rows round themselves to fit its corners, and not to the window
	-- that it floats over.
	Corners.setContainer(menu, radius)

	local nav = (scope :: any)._pantheonMenuNav
	if nav then
		MenuNav.bind(menu, nav);
		(scope :: any)._pantheonMenuNav = nil
	end

	local host = CanvasFade.host(scope, menu, openS, { Theme = theme })
	if props.Embedded ~= true then
		Layer.mount(scope, props, host)
	end
	return host
end
