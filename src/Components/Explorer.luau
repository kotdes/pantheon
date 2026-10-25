--!strict
--[[
	A tree of Instances, like the Explorer of Studio: expand, filter, select several, rename,
	and drag to reparent. See docs/Components/Layout/Explorer.md.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Focus = require(script.Parent.Parent.Internal.Focus)
local ScrollInput = require(script.Parent.Parent.Internal.ScrollInput)
local Icon = require(script.Parent.Icon)
local VirtualList = require(script.Parent.VirtualList)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local UserInputService = game:GetService("UserInputService")

local DRAG_THRESHOLD = 6
local DOUBLE_CLICK = 0.35

type Row = { instance: Instance, depth: number, expandable: boolean, open: boolean }

--- Icon for a class, by the most specific class that has one.
local ICONS: { [string]: string } = {
	Workspace = "globe",
	Terrain = "mountain",
	Camera = "camera",
	Players = "users",
	Player = "user",
	Humanoid = "person-standing",
	Tool = "wrench",
	Model = "package",
	Folder = "folder",
	Script = "file-code",
	LocalScript = "file-code",
	ModuleScript = "file-code",
	Sound = "volume-2",
	Light = "lightbulb",
	ScreenGui = "monitor",
	SurfaceGui = "monitor",
	BillboardGui = "monitor",
	Frame = "square",
	ScrollingFrame = "square",
	TextLabel = "type",
	TextButton = "mouse-pointer",
	TextBox = "type",
	ImageLabel = "image",
	ImageButton = "image",
	BasePart = "box",
	Attachment = "crosshair",
	ParticleEmitter = "sparkles",
	Sky = "sun",
	Fire = "flame",
}
local CLASS_ORDER = {
	"Workspace",
	"Terrain",
	"Camera",
	"Players",
	"Player",
	"Humanoid",
	"Tool",
	"Model",
	"Folder",
	"Script",
	"LocalScript",
	"ModuleScript",
	"Sound",
	"Light",
	"ScreenGui",
	"SurfaceGui",
	"BillboardGui",
	"ScrollingFrame",
	"Frame",
	"TextLabel",
	"TextButton",
	"TextBox",
	"ImageLabel",
	"ImageButton",
	"BasePart",
	"Attachment",
	"ParticleEmitter",
	"Sky",
	"Fire",
}

local function defaultIcon(instance: Instance): string
	for _, class in CLASS_ORDER do
		if instance:IsA(class) then
			return ICONS[class]
		end
	end
	return "box"
end

local function sameSet(a: { [Instance]: boolean }, b: { [Instance]: boolean }): boolean
	for key in a do
		if not b[key] then
			return false
		end
	end
	for key in b do
		if not a[key] then
			return false
		end
	end
	return true
end

return function(scope: Types.Scope, props: Types.ExplorerProps): Instance
	local theme = resolveTheme(props)
	local rowHeight = props.RowHeight or 24
	local indent = props.Indent or 14
	local iconFor: (Instance) -> string = props.Icon or defaultIcon
	local roots = props.Roots

	local expanded = scope:Value({} :: { [Instance]: boolean })
	local selected = scope:Value({} :: { [Instance]: boolean })
	local anchor: Instance? = nil
	local renaming = scope:Value(nil :: Instance?)
	local version = scope:Value(0) -- bumped when the tree or a name changes
	local scrollOffset = scope:Value(0)
	local scrolled = 0
	local viewHeight = 240

	if props.ExpandRoots ~= false then
		local first = {}
		for _, root in roots do
			first[root] = true
		end
		expanded:set(first)
	end

	-- what changes the list
	local pending = false
	local function bump()
		if pending then
			return
		end
		pending = true
		task.defer(function()
			pending = false
			version:set(peek(version) + 1)
		end)
	end
	for _, root in roots do
		table.insert(scope, root.DescendantAdded:Connect(bump))
		table.insert(scope, root.DescendantRemoving:Connect(bump))
	end
	local nameWatch: { [Instance]: RBXScriptConnection } = {}
	table.insert(scope, function()
		for _, connection in nameWatch do
			connection:Disconnect()
		end
		table.clear(nameWatch)
	end)

	-- the flat list of rows
	local function matches(instance: Instance, text: string): boolean
		return string.find(string.lower(instance.Name), text, 1, true) ~= nil
			or (props.Match ~= nil and props.Match(instance, text) == true)
	end

	local rows = scope:Computed(function(use)
		use(version)
		local open = use(expanded) :: { [Instance]: boolean }
		local filter =
			string.lower(tostring(if props.Filter ~= nil then use(props.Filter) else "") or "")
		local include = props.Include
		local list: { Row } = {}

		--- Adds `instance` and what is under it. With a filter, only branches that hold a match.
		--- Returns whether anything was added.
		local function visit(instance: Instance, depth: number): boolean
			if include and not include(instance) then
				return false
			end
			local kids = instance:GetChildren()
			local start = #list + 1
			local hereMatches = filter == "" or matches(instance, filter)
			table.insert(
				list,
				{ instance = instance, depth = depth, expandable = #kids > 0, open = false }
			)
			local anyChild = false
			if filter ~= "" or open[instance] then
				for _, child in kids do
					if visit(child, depth + 1) then
						anyChild = true
					end
				end
			end
			if filter ~= "" then
				if not hereMatches and not anyChild then
					-- Nothing here matches: take this branch back out.
					for at = #list, start, -1 do
						table.remove(list, at)
					end
					return false
				end
				list[start].open = anyChild
			else
				list[start].open = open[instance] == true
			end
			return true
		end
		for _, root in roots do
			visit(root, 0)
		end

		-- Watch the names of what is listed.
		local present: { [Instance]: boolean } = {}
		for _, row in list do
			present[row.instance] = true
			if not nameWatch[row.instance] then
				nameWatch[row.instance] =
					row.instance:GetPropertyChangedSignal("Name"):Connect(bump)
			end
		end
		for instance, connection in nameWatch do
			if not present[instance] then
				connection:Disconnect()
				nameWatch[instance] = nil
			end
		end
		return list
	end)

	-- selection
	local function selectedList(): { Instance }
		local ordered: { Instance } = {}
		local set = peek(selected) :: { [Instance]: boolean }
		for _, row in peek(rows) :: { Row } do
			if set[row.instance] then
				table.insert(ordered, row.instance)
			end
		end
		return ordered
	end
	local function setSelected(set: { [Instance]: boolean })
		if sameSet(set, peek(selected)) then
			return
		end
		selected:set(set)
		if props.OnSelect then
			props.OnSelect(selectedList())
		end
	end
	Bind.link(scope, props.Selected, selected, {
		toInternal = function(list: { Instance })
			local set = {}
			for _, instance in list do
				set[instance] = true
			end
			return set
		end,
		toProp = function(set: { [Instance]: boolean })
			local list = {}
			for _, row in peek(rows) :: { Row } do
				if set[row.instance] then
					table.insert(list, row.instance)
				end
			end
			return list
		end,
		equals = function(a: any, b: any): boolean
			-- Compare as sets whichever form each is in.
			local function asSet(value: any): { [Instance]: boolean }
				local set = {}
				if typeof(value) == "table" then
					for key, item in value do
						if typeof(key) == "Instance" then
							set[key] = true
						elseif typeof(item) == "Instance" then
							set[item] = true
						end
					end
				end
				return set
			end
			return sameSet(asSet(a), asSet(b))
		end,
	})

	local function indexOfRow(instance: Instance): number?
		for index, row in peek(rows) :: { Row } do
			if row.instance == instance then
				return index
			end
		end
		return nil
	end

	local function revealRow(index: number)
		local top = (index - 1) * rowHeight
		if top < scrolled then
			scrollOffset:set(top)
		elseif top + rowHeight > scrolled + viewHeight then
			scrollOffset:set(top + rowHeight - viewHeight)
		end
	end

	local function toggle(instance: Instance)
		local copy = table.clone(peek(expanded)) :: { [Instance]: boolean? }
		copy[instance] = if copy[instance] then nil else true
		expanded:set(copy)
	end

	local function press(row: Row)
		local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
			or UserInputService:IsKeyDown(Enum.KeyCode.LeftMeta)
		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
		local set = table.clone(peek(selected)) :: { [Instance]: boolean? }
		if shift and anchor then
			local a, b = indexOfRow(anchor), indexOfRow(row.instance)
			if a and b then
				set = if ctrl then set else {}
				for index = math.min(a, b), math.max(a, b) do
					set[(peek(rows) :: { Row })[index].instance] = true
				end
			end
		elseif ctrl then
			set[row.instance] = if set[row.instance] then nil else true
			anchor = row.instance
		else
			set = { [row.instance] = true }
			anchor = row.instance
		end
		setSelected(set :: { [Instance]: boolean })
	end

	-- Open the branches above an instance and scroll to it, when `Reveal` is set to one.
	if props.Reveal ~= nil and Bind.isState(props.Reveal) then
		table.insert(
			scope,
			scope:Observer(props.Reveal :: any):onChange(function()
				local target = peek(props.Reveal :: any) :: Instance?
				if target == nil then
					return
				end
				local open = table.clone(peek(expanded)) :: { [Instance]: boolean? }
				local above: Instance? = target.Parent
				while above do
					open[above] = true
					above = above.Parent
				end
				expanded:set(open :: { [Instance]: boolean })
				task.defer(function()
					local at = indexOfRow(target)
					if at then
						revealRow(at)
					end
				end)
			end)
		)
	end

	-- renaming
	local function finishRename(instance: Instance, text: string, apply: boolean)
		renaming:set(nil)
		if apply and text ~= "" and text ~= instance.Name then
			if props.OnRename then
				props.OnRename(instance, text)
			else
				pcall(function()
					instance.Name = text
				end)
			end
			bump()
		end
	end

	-- dragging to reparent
	local rowButtons: { [number]: GuiObject } = {}
	local dropTarget = scope:Value(nil :: Instance?)
	local function rowUnder(point: Vector3): Row?
		local list = peek(rows) :: { Row }
		for index, button in rowButtons do
			local at, size = button.AbsolutePosition, button.AbsoluteSize
			if
				button.Parent
				and point.X >= at.X
				and point.X <= at.X + size.X
				and point.Y >= at.Y
				and point.Y <= at.Y + size.Y
			then
				return list[index]
			end
		end
		return nil
	end

	local function reparent(instance: Instance, parent: Instance)
		if instance == parent or parent:IsDescendantOf(instance) or instance.Parent == parent then
			return
		end
		if props.OnReparent then
			props.OnReparent(instance, parent)
		else
			pcall(function()
				instance.Parent = parent
			end)
		end
		local copy = table.clone(peek(expanded)) :: { [Instance]: boolean? }
		copy[parent] = true
		expanded:set(copy)
		bump()
	end

	-- a row
	local function renderRow(sc: any, index: number): Instance
		local row = sc:Computed(function(use)
			return (use(rows) :: { Row })[index]
		end)
		local ix = Interaction.bind(sc, theme, {})
		local isSelected = sc:Computed(function(use)
			local current = use(row) :: Row?
			return current ~= nil
				and (use(selected) :: { [Instance]: boolean })[current.instance] == true
		end)
		local isTarget = sc:Computed(function(use)
			local current = use(row) :: Row?
			return current ~= nil and (use(dropTarget) :: Instance?) == current.instance
		end)

		local arrow = sc:New("TextButton")({
			Name = "Arrow",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(18, rowHeight),
			LayoutOrder = 1,
			[OnEvent("Activated")] = function()
				local current = peek(row) :: Row?
				if current then
					toggle(current.instance)
				end
			end,
			[Children] = sc:Apply(Icon(sc, {
				Theme = theme,
				Name = "chevron-right",
				IconSize = 14,
				Color = theme.Colors.OnSurfaceVariant,
			}))({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Visible = sc:Computed(function(use)
					local current = use(row) :: Row?
					return current ~= nil and current.expandable == true
				end),
				Rotation = sc:Computed(function(use)
					local current = use(row) :: Row?
					return if current and current.open then 90 else 0
				end),
			}),
		}) :: TextButton

		local label = sc:New("TextLabel")({
			Name = "Label",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.None,
			LayoutOrder = 3,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			FontFace = theme.Fonts.Body,
			TextSize = A.size(theme, 13),
			TextColor3 = sc:Computed(function(use)
				return if use(isSelected)
					then use(theme.Colors.OnPrimaryContainer)
					else use(theme.Colors.OnSurface)
			end),
			Visible = sc:Computed(function(use)
				local current = use(row) :: Row?
				return not (current ~= nil and (use(renaming) :: Instance?) == current.instance)
			end),
			Text = sc:Computed(function(use)
				local current = use(row) :: Row?
				return if current then current.instance.Name else ""
			end),
			[Children] = sc:New("UIFlexItem")({ FlexMode = Enum.UIFlexMode.Fill }),
		}) :: TextLabel

		local editor = sc:New("TextBox")({
			Name = "Rename",
			BackgroundColor3 = theme.Colors.Surface,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, -4),
			LayoutOrder = 3,
			ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = theme.Fonts.Body,
			TextSize = A.size(theme, 13),
			TextColor3 = theme.Colors.OnSurface,
			Visible = sc:Computed(function(use)
				local current = use(row) :: Row?
				return current ~= nil and (use(renaming) :: Instance?) == current.instance
			end),
			[Children] = {
				sc:New("UIFlexItem")({ FlexMode = Enum.UIFlexMode.Fill }),
				sc:New("UICorner")({ CornerRadius = UDim.new(0, 4) }),
				sc:New("UIStroke")({ Color = theme.Colors.Primary, Thickness = 1 }),
			},
		}) :: TextBox
		table.insert(
			sc,
			sc:Observer(renaming):onChange(function()
				local current = peek(row) :: Row?
				if current and peek(renaming) == current.instance then
					editor.Text = current.instance.Name
					editor:CaptureFocus()
					editor.CursorPosition = #editor.Text + 1
					editor.SelectionStart = 1
				end
			end)
		)
		table.insert(
			sc,
			editor.FocusLost:Connect(function(enter: boolean)
				local current = peek(row) :: Row?
				if current and peek(renaming) == current.instance then
					finishRename(current.instance, editor.Text, enter)
				end
			end)
		)

		local iconName = sc:Computed(function(use)
			local current = use(row) :: Row?
			return if current then iconFor(current.instance) else "box"
		end)
		-- Icons are looked up by name, so a changing row swaps them through a computed child.
		local iconHost = sc:New("Frame")({
			Name = "Icon",
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(20, rowHeight),
			LayoutOrder = 2,
			[Children] = sc:Computed(function(use, inner: any)
				return inner:Apply(Icon(inner, {
					Theme = theme,
					Name = use(iconName),
					IconSize = 16,
					Color = use(theme.Colors.OnSurfaceVariant),
				}))({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
				})
			end),
		}) :: Frame

		local button = sc:New("TextButton")({
			Name = `Row{index}`,
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = sc:Computed(function(use)
				if use(isTarget) then
					return Interaction.lerpColor(
						use(theme.Colors.Surface),
						use(theme.Colors.Primary),
						0.25,
						use
					)
				end
				local base = if use(isSelected)
					then use(theme.Colors.PrimaryContainer)
					else use(theme.Colors.Surface)
				return Interaction.lerpColor(base, use(theme.Colors.OnSurface), ix.alpha(use), use)
			end),
			BackgroundTransparency = sc:Computed(function(use)
				return if use(isSelected) or use(isTarget)
					then 0
					else 1 - math.clamp(ix.alpha(use) * 6, 0, 1)
			end),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			[Children] = {
				sc:New("UIListLayout")({
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				sc:New("UIPadding")({
					PaddingLeft = sc:Computed(function(use)
						local current = use(row) :: Row?
						return UDim.new(0, 4 + (if current then current.depth * indent else 0))
					end),
					PaddingRight = UDim.new(0, 6),
				}),
				arrow,
				iconHost,
				label,
				editor,
			} :: any,
		}) :: TextButton
		ix.wire(button)
		-- Tell the caller which instance the pointer is over.
		if props.OnHover then
			table.insert(
				sc,
				button.MouseEnter:Connect(function()
					local current = peek(row) :: Row?
					if current and props.OnHover then
						props.OnHover(current.instance)
					end
				end)
			)
			table.insert(
				sc,
				button.MouseLeave:Connect(function()
					if props.OnHover then
						props.OnHover(nil)
					end
				end)
			)
		end
		rowButtons[index] = button
		table.insert(sc, function()
			if rowButtons[index] == button then
				rowButtons[index] = nil
			end
		end)

		-- Press selects. A second quick press activates. Moving past the threshold drags.
		local lastPress = 0
		table.insert(
			sc,
			button.InputBegan:Connect(function(input: InputObject)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
					return
				end
				local current = peek(row) :: Row?
				if not current then
					return
				end
				local now = os.clock()
				if now - lastPress < DOUBLE_CLICK then
					lastPress = 0
					if props.OnActivate then
						props.OnActivate(current.instance)
					end
					return
				end
				lastPress = now
				press(current)
				if props.AllowReparent ~= true then
					return
				end
				local start = input.Position
				local dragging = false
				ScrollInput.capture(button, function(changed: InputObject)
					return changed.UserInputType == Enum.UserInputType.MouseMovement
				end, function(ended: InputObject)
					return ended.UserInputType == Enum.UserInputType.MouseButton1
				end, function(position: Vector3)
					if not dragging and (position - start).Magnitude > DRAG_THRESHOLD then
						dragging = true
					end
					if dragging then
						local under = rowUnder(position)
						dropTarget:set(
							if under and under.instance ~= current.instance
								then under.instance
								else nil
						)
					end
				end, function()
					local target = peek(dropTarget)
					dropTarget:set(nil)
					if dragging and target then
						reparent(current.instance, target)
					end
				end)
			end)
		)
		return button
	end

	-- the list and its keyboard
	local list = VirtualList(scope, {
		Theme = theme,
		Size = UDim2.fromScale(1, 1),
		ItemCount = scope:Computed(function(use)
			return #(use(rows) :: { Row })
		end),
		ItemHeight = rowHeight,
		ScrollOffset = scrollOffset,
		OnScroll = function(y: number)
			scrolled = y
		end,
		RenderItem = renderRow,
	}) :: GuiObject
	table.insert(
		scope,
		list:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			viewHeight = list.AbsoluteSize.Y
		end)
	)

	local root = scope:New("Frame")({
		Name = "Explorer",
		BackgroundColor3 = theme.Colors.Surface,
		BorderSizePixel = 0,
		Size = props.Size or UDim2.fromScale(1, 1),
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		ClipsDescendants = true,
		Selectable = true,
		[Children] = list,
	}) :: Frame
	Focus.manage(root, theme)

	-- Arrow keys move the selection, Left and Right close and open, Enter activates, F2 renames.
	Focus.onKey(root, function(input: InputObject): boolean
		local items = peek(rows) :: { Row }
		local current = (selectedList())[1]
		local at = if current then indexOfRow(current) else nil
		local code = input.KeyCode
		local function choose(index: number)
			index = math.clamp(index, 1, #items)
			local row = items[index]
			if row then
				anchor = row.instance
				setSelected({ [row.instance] = true })
				revealRow(index)
			end
		end
		if code == Enum.KeyCode.Down then
			choose((at or 0) + 1)
		elseif code == Enum.KeyCode.Up then
			choose((at or 2) - 1)
		elseif code == Enum.KeyCode.Right and at then
			local row = items[at]
			if row.expandable and not row.open then
				toggle(row.instance)
			else
				choose(at + 1)
			end
		elseif code == Enum.KeyCode.Left and at then
			local row = items[at]
			if row.open then
				toggle(row.instance)
			elseif row.instance.Parent then
				local parentAt = indexOfRow(row.instance.Parent :: Instance)
				if parentAt then
					choose(parentAt)
				end
			end
		elseif code == Enum.KeyCode.Return and current and props.OnActivate then
			props.OnActivate(current)
		elseif code == Enum.KeyCode.F2 and current and props.AllowRename ~= false then
			renaming:set(current)
		else
			return false
		end
		return true
	end)

	return root
end
