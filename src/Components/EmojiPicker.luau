--!strict

--[[
	EmojiPicker.luau

	Docs: docs/Components/Overlays/EmojiPicker.md
]]

local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local tr = require(script.Parent.Parent.Internal.Translate).t
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Groups = require(script.Parent.Parent.Internal.Emoji)
local AppSheet = require(script.Parent.AppSheet)
local Icon = require(script.Parent.Icon)
local IconButton = require(script.Parent.IconButton)
local MenuButton = require(script.Parent.MenuButton)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Popover = require(script.Parent.Popover)
local Roll = require(script.Parent.Parent.Internal.Roll)
local ScrollArea = require(script.Parent.ScrollArea)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local CELL = 40
local TAB = 32
local POPOVER_PADDING = 6
local MENU_LIFT = 20

return function(scope: Types.Scope, props: Types.EmojiPickerProps): Instance
	local theme = resolveTheme(props)
	local wantsPopover = props.Variant == "Popover"
	local closeOnPick = props.CloseOnPick ~= false
	local openRef = props.Open
	local open = scope:Computed(function(use)
		if openRef == nil then
			return true
		end
		return (if typeof(openRef) == "table" then use(openRef) else openRef) == true
	end)

	local category = scope:Value(Groups[1].Name)
	local request = scope:Value({ Name = Groups[1].Name })
	local menuOpen = scope:Value(false)
	local categoryOrder = scope:Computed(function(use)
		local name = use(category)
		for order, group in Groups do
			if group.Name == name then
				return order
			end
		end
		return 1
	end)
	-- While a jump scrolls past the categories in between, the one that was asked for stays selected.
	local settleAt = 0

	local function close()
		if props.OnClose then
			props.OnClose()
		end
	end

	local function pick(emoji: string)
		if props.OnPick then
			props.OnPick(emoji)
		end
		if closeOnPick then
			close()
		end
	end

	local function jumpTo(name: string)
		settleAt = os.clock() + 0.8
		category:set(name)
		request:set({ Name = name })
	end

	local function content(inner: any, height: number?, withTabs: boolean): Instance
		local alive = true
		table.insert(inner, function()
			alive = false
		end)
		local offset = inner:Value(0)
		local sections: { [string]: Frame } = {}
		local grids: { [string]: Instance } = {}
		local rows: { any } = {}

		for order, group in Groups do
			local grid = inner:Frame({
				Name = "Grid",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 2,
				[Children] = {
					inner:New("UIGridLayout")({
						CellSize = UDim2.fromOffset(CELL, CELL),
						CellPadding = UDim2.fromOffset(2, 2),
						SortOrder = Enum.SortOrder.LayoutOrder,
					}),
				},
			})
			grids[group.Name] = grid
			local section = inner:Frame({
				Name = group.Name,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = order,
				Layout = {
					Kind = "List",
					Padding = theme.Metrics.SpaceXs,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = {
					inner:TextLabel({
						Name = "Header",
						BackgroundTransparency = 1,
						FontFace = theme.Typography.Label.Font,
						TextSize = theme.Typography.Label.Size,
						TextColor3 = theme.Colors.OnSurfaceVariant,
						TextXAlignment = Enum.TextXAlignment.Left,
						Text = group.Name,
						Size = UDim2.new(1, 0, 0, 20),
						LayoutOrder = 1,
					}),
					grid,
				},
			}) :: Frame
			sections[group.Name] = section
			table.insert(rows, section)
		end

		task.spawn(function()
			for _, group in Groups do
				if not alive then
					return
				end
				for index, emoji in group.Emojis do
					local cell: any = {
						Name = `E{index}`,
						Text = emoji,
						TextSize = 24, -- token-ok
						AutoButtonColor = true,
						BackgroundTransparency = 1,
						LayoutOrder = index,
						Parent = grids[group.Name],
					}
					cell[OnEvent("Activated")] = function()
						pick(emoji)
					end
					inner:TextButton(cell)
				end
				task.wait()
			end
		end)

		table.insert(
			inner,
			inner:Observer(request):onChange(function()
				local target, first = sections[peek(request).Name], sections[Groups[1].Name]
				if target and first then
					offset:set(target.AbsolutePosition.Y - first.AbsolutePosition.Y)
				end
			end)
		)

		-- The category at the top of the list is the selected one.
		local function follow(position: number)
			if os.clock() < settleAt then
				return
			end
			local first = sections[Groups[1].Name]
			if first == nil then
				return
			end
			local current = Groups[1].Name
			for _, group in Groups do
				local section = sections[group.Name]
				if
					section
					and section.AbsolutePosition.Y - first.AbsolutePosition.Y <= position + 8
				then
					current = group.Name
				end
			end
			if current ~= peek(category) then
				category:set(current)
			end
		end

		local list = ScrollArea(inner, {
			Theme = theme,
			OnScroll = follow,
			Size = UDim2.fromScale(1, 1),
			ContentPadding = theme.Metrics.SpaceMd,
			ListPadding = theme.Metrics.SpaceMd,
			ScrollOffset = offset,
			Children = rows,
		})

		local parts: { any } = {}
		if withTabs then
			local tabs: { any } = {}
			for order, group in Groups do
				table.insert(
					tabs,
					IconButton(inner, {
						Theme = theme,
						Name = group.Icon,
						Size = UDim2.fromOffset(TAB, TAB),
						LayoutOrder = order,
						Selected = inner:Computed(function(use)
							return use(category) == group.Name
						end),
						OnClick = function()
							jumpTo(group.Name)
						end,
					})
				)
			end
			table.insert(
				parts,
				inner:Frame({
					Name = "Tabs",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, TAB),
					LayoutOrder = 1,
					Layout = {
						Kind = "List",
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = 2,
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					[Children] = tabs,
				})
			)
		end
		table.insert(
			parts,
			inner:Frame({
				Name = "Body",
				BackgroundTransparency = 1,
				Size = if height
					then UDim2.new(
						1,
						0,
						0,
						height - (if withTabs then TAB + theme.Metrics.SpaceXs else 0)
					)
					else UDim2.fromScale(1, 1),
				LayoutOrder = 2,
				[Children] = { list },
			})
		)
		return inner:Frame({
			Name = "Emojis",
			BackgroundTransparency = 1,
			Size = if height then UDim2.new(1, 0, 0, height) else UDim2.fromScale(1, 1),
			Layout = {
				Kind = "List",
				Padding = theme.Metrics.SpaceXs,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			[Children] = parts,
		})
	end

	local function lazy(shown: any, height: number?, withTabs: boolean): any
		return scope:Computed(function(use, inner)
			if not use(shown) then
				return nil
			end
			return content(inner, height, withTabs)
		end)
	end

	-- The popover needs room. When the layer that it is in is small, such as a window that is
	-- sized down, the picker is a sheet instead. It follows the size of the layer as it changes.
	local layer = Layer.resolve(props)
	local compact = scope:Value(false)
	local height = props.Height or 360
	if wantsPopover and layer then
		local width = props.SheetBelow or 560
		local function measure()
			local size = layer.AbsoluteSize
			compact:set(size.X < width or size.Y < height + POPOVER_PADDING * 2 + 48)
		end
		measure()
		table.insert(scope, layer:GetPropertyChangedSignal("AbsoluteSize"):Connect(measure))
	end
	local popoverOpen = scope:Computed(function(use)
		return use(open) and not use(compact)
	end)
	local sheetOpen = scope:Computed(function(use)
		return use(open) and (not wantsPopover or use(compact))
	end)

	local popoverRoot: Instance? = nil
	if wantsPopover then
		popoverRoot = Popover(scope, {
			Theme = theme,
			Layer = props.Layer,
			Target = props.Target,
			MorphTarget = props.MorphTarget,
			Open = popoverOpen,
			Placement = props.Placement or "Auto",
			Width = props.Width or 328,
			MaxHeight = height + POPOVER_PADDING * 2,
			ZIndex = props.ZIndex,
			Children = {
				scope:Frame({
					Name = "Content",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, height),
					[Children] = { lazy(popoverOpen, height, true) },
				}),
			},
			OnClose = close,
		})
	end

	local titleButton: any = {
		Name = "Category",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(0, TAB),
		AutomaticSize = Enum.AutomaticSize.X,
		CornerRadius = theme.Metrics.RadiusSm,
		Padding = { 0, theme.Metrics.SpaceXs },
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = theme.Metrics.SpaceXs,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			Roll.label(scope, {
				Theme = theme,
				Text = category,
				Order = categoryOrder,
				Height = TAB,
				Font = theme.Typography.Title.Font,
				TextSize = theme.Typography.Title.Size,
				Color = theme.Colors.OnSurface,
				LayoutOrder = 1,
			}),
			Icon(scope, {
				Theme = theme,
				Name = "chevron-down",
				IconSize = theme.Metrics.IconLg,
				Color = theme.Colors.OnSurfaceVariant,
				LayoutOrder = 2,
			}),
		},
	}
	titleButton[OnEvent("Activated")] = function()
		menuOpen:set(not peek(menuOpen))
	end
	local title = scope:TextButton(titleButton)

	local entries: { any } = {}
	for order, group in Groups do
		table.insert(
			entries,
			MenuButton(scope, {
				Theme = theme,
				Layer = props.Layer,
				Text = group.Name,
				LeadingIcon = group.Icon,
				LayoutOrder = order,
				OnClick = function()
					menuOpen:set(false)
					jumpTo(group.Name)
				end,
			})
		)
	end
	Popover(scope, {
		Theme = theme,
		Layer = props.Layer,
		Target = title,
		Open = menuOpen,
		Placement = "Auto",
		Width = 220,
		MaxHeight = 320,
		ZIndex = (props.ZIndex or 110) + MENU_LIFT,
		Children = entries,
		OnClose = function()
			menuOpen:set(false)
		end,
	})

	local sheet = AppSheet(scope, {
		Theme = theme,
		Layer = props.Layer,
		Open = sheetOpen,
		Title = props.Title or tr("emoji.title", "Emojis"),
		TitleContent = title,
		Detent = props.Detent or 0.6,
		ZIndex = props.ZIndex,
		Children = { lazy(sheetOpen, nil, false) },
		OnClose = close,
	})
	return popoverRoot or sheet
end
