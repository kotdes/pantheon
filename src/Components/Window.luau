--!strict
--[[
	Rounded app chrome shell (elevated Sheet colors) that hosts AppBar,
	NavigationRail, content, and overlay layers (NavigationDrawer, menus, dialogs).
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Layer = require(script.Parent.Parent.Internal.Layer)
local Corners = require(script.Parent.Parent.Internal.Corners)
local EdgeFade = require(script.Parent.Parent.Internal.EdgeFade)
local ScrollInput = require(script.Parent.Parent.Internal.ScrollInput)
local Resize = require(script.Parent.Parent.Internal.Resize)
local Icon = require(script.Parent.Icon)
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local ALL_HANDLES =
	{ "Left", "Right", "Top", "Bottom", "TopLeft", "TopRight", "BottomLeft", "BottomRight" }
local HANDLE_EDGES: { [string]: Resize.Edges } = {
	Left = { left = true },
	Right = { right = true },
	Top = { top = true },
	Bottom = { bottom = true },
	TopLeft = { left = true, top = true },
	TopRight = { right = true, top = true },
	BottomLeft = { left = true, bottom = true },
	BottomRight = { right = true, bottom = true },
}

-- Cursor glyph shown over each resize handle (the system cursor is hidden meanwhile).
local HANDLE_CURSOR_ICON: { [string]: string } = {
	Left = "move-horizontal",
	Right = "move-horizontal",
	Top = "move-vertical",
	Bottom = "move-vertical",
	TopLeft = "move-diagonal-2",
	BottomRight = "move-diagonal-2",
	TopRight = "move-diagonal",
	BottomLeft = "move-diagonal",
}

local Children = Fusion.Children

-- Matches NavigationRail default horizontal height.
local HORIZONTAL_RAIL_HEIGHT = 52

local function isVerticalRail(rail: Instance?, explicit: ("Vertical" | "Horizontal")?): boolean
	if explicit == "Horizontal" then
		return false
	end
	if explicit == "Vertical" then
		return true
	end
	if rail == nil or not rail:IsA("GuiObject") then
		return true
	end
	-- NavigationRail horizontal default size is UDim2.new(1, 0, 0, 72)
	local s = (rail :: GuiObject).Size
	if s.X.Scale >= 1 and s.Y.Scale == 0 and s.Y.Offset > 0 and s.Y.Offset <= 100 then
		return false
	end
	return true
end

return function(scope: Types.Scope, props: Types.WindowProps): Instance
	local theme = resolveTheme(props)
	local verticalRail = isVerticalRail(props.NavigationRail, props.RailOrientation)
	local hasRail = props.NavigationRail ~= nil
	local function barSize(bar: Instance?, fallback: number): (number, number)
		if bar == nil then
			return 0, 0
		end
		local height = bar:GetAttribute(EdgeFade.HeightAttribute)
		local fade = bar:GetAttribute(EdgeFade.FadeAttribute)
		return if typeof(height) == "number" then height else fallback,
			if typeof(fade) == "number" then fade else 0
	end
	local appBarHeight, appBarFade = barSize(props.AppBar, theme.Metrics.AppBarHeight)
	local footerHeight, footerFade = barSize(props.Footer, theme.Metrics.AppBarHeight)
	local railWidth = if hasRail and verticalRail then theme.Metrics.RailWidth else 0
	local railBottom = if hasRail and not verticalRail then HORIZONTAL_RAIL_HEIGHT else 0
	local radius = props.CornerRadius or theme.Metrics.RadiusPanel
	local elevated = if props.Elevated == nil then true else props.Elevated

	local overlayLayer = scope:Frame({
		Name = "OverlayLayer",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		ZIndex = 50,
	}) :: Frame

	-- A docked NavigationDrawer takes room at the left. The app bar and the content move over,
	-- and a side rail stays under the drawer.
	local dock = scope:Value(0)
	local dockS = scope:Spring(dock, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
	local leftEdge = scope:Computed(function(use)
		local docked = use(dockS) :: number
		return if verticalRail then math.max(railWidth, docked) else docked
	end)

	if props.AppBar then
		-- With a side rail, the rail is full height and the app bar is narrower.
		scope:Apply(props.AppBar)({
			Position = scope:Computed(function(use)
				return UDim2.fromOffset(use(leftEdge), 0)
			end),
			Size = scope:Computed(function(use)
				return UDim2.new(1, -use(leftEdge), 0, appBarHeight)
			end),
			ZIndex = 10,
		})
	end

	if props.Footer then
		scope:Apply(props.Footer)({
			AnchorPoint = Vector2.new(0, 1),
			Position = scope:Computed(function(use)
				return UDim2.new(0, use(leftEdge), 1, -railBottom)
			end),
			Size = scope:Computed(function(use)
				return UDim2.new(1, -use(leftEdge), 0, footerHeight)
			end),
			ZIndex = 10,
		})
	end

	if props.NavigationRail then
		scope:Apply(props.NavigationRail)({
			Position = if verticalRail
				then UDim2.fromOffset(0, 0)
				else scope:Computed(function(use)
					return UDim2.new(0, use(leftEdge), 1, -railBottom)
				end),
			Size = if verticalRail
				then UDim2.new(0, railWidth, 1, 0)
				else scope:Computed(function(use)
					return UDim2.new(1, -use(leftEdge), 0, railBottom)
				end),
			-- The side rail sits above the app bar so its shadow falls on it.
			ZIndex = if verticalRail then 11 else 5,
		})
	end

	local contentTop = if appBarFade > 0 then 0 else appBarHeight
	local contentBottom = railBottom + (if footerFade > 0 then 0 else footerHeight)
	local content = scope:Frame({
		Name = "Content",
		BackgroundTransparency = 1,
		Position = scope:Computed(function(use)
			return UDim2.fromOffset(use(leftEdge), contentTop)
		end),
		Size = scope:Computed(function(use)
			return UDim2.new(1, -use(leftEdge), 1, -(contentTop + contentBottom))
		end),
		ZIndex = 1,
		ClipsDescendants = true,
		[Children] = props.Children,
	})

	local chrome: { any } = {
		content,
		overlayLayer,
		scope:New("UIStroke")({
			Name = "OuterEdge",
			BorderStrokePosition = Enum.BorderStrokePosition.Outer,
			Color = Color3.new(0, 0, 0),
			Transparency = 0.55,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ZIndex = 5,
		}),
		scope:New("UIStroke")({
			Name = "InnerEdge",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Color = Color3.new(1, 1, 1),
			Transparency = 0.8,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ZIndex = 5,
		}),
	}
	if props.AppBar then
		table.insert(chrome, 1, props.AppBar)
	end
	if props.Footer then
		table.insert(chrome, props.Footer)
	end
	if props.NavigationRail then
		table.insert(chrome, props.NavigationRail)
	end

	-- CanvasGroup + CornerRadius clips descendants to the rounded rect (Sheet-equivalent fill).
	local window = scope:Frame({
		Name = "Window",
		BackgroundColor3 = if elevated
			then theme.Colors.SurfaceContainerHigh
			else theme.Colors.Surface,
		BackgroundTransparency = props.BackgroundTransparency or 0,
		Shadow = {
			BlurRadius = if elevated then 24 else 6,
			Offset = UDim2.new(0, 0, 0, 4),
			Transparency = 0.75,
		},
		BorderSizePixel = 0,
		Active = true,
		SizeConstraint = props.SizeConstraint or nil,
		AspectRatio = props.AspectRatio or nil,
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
		Position = props.Position or UDim2.fromScale(0, 0),
		Size = props.Size or UDim2.fromScale(1, 1),
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		ClipsDescendants = true,
		CornerRadius = radius,
		[Children] = chrome,
	}) :: Frame

	-- ClipsDescendants only clips to a rectangle, so the chrome rounds its own corners. With a
	-- side rail, the rail takes both left corners and the app bar the top right. With a bottom
	-- bar, the app bar takes the top corners and the bar the bottom ones.
	local r: number = radius :: any
	if hasRail and verticalRail then
		Corners.apply(props.AppBar, 0, r, 0, 0)
		Corners.apply(props.Footer, 0, 0, 0, r)
		Corners.apply(props.NavigationRail, r, 0, r, 0)
	else
		Corners.apply(props.AppBar, r, r, 0, 0)
		Corners.apply(props.Footer, 0, 0, if hasRail then 0 else r, if hasRail then 0 else r)
		Corners.apply(props.NavigationRail, 0, 0, r, r)
	end

	-- Watch for a docked NavigationDrawer anywhere in the overlay layer. It sets the width it
	-- takes in the `PantheonDockWidth` attribute, and the widest one decides how far to move over.
	local DOCK_ATTRIBUTE = "PantheonDockWidth"
	local dockWidths: { [Instance]: number } = {}
	local function updateDock()
		local widest = 0
		for _, width in dockWidths do
			widest = math.max(widest, width)
		end
		dock:set(widest)
	end
	local function trackDock(inst: Instance)
		if dockWidths[inst] ~= nil or inst:GetAttribute(DOCK_ATTRIBUTE) == nil then
			return
		end
		local function read()
			local width = inst:GetAttribute(DOCK_ATTRIBUTE)
			dockWidths[inst] = if typeof(width) == "number" then width else 0
			updateDock()
		end
		read()
		table.insert(scope, inst:GetAttributeChangedSignal(DOCK_ATTRIBUTE):Connect(read))
	end
	table.insert(scope, overlayLayer.DescendantAdded:Connect(trackDock))
	table.insert(
		scope,
		overlayLayer.DescendantRemoving:Connect(function(inst: Instance)
			if dockWidths[inst] ~= nil then
				dockWidths[inst] = nil
				updateDock()
			end
		end)
	)

	local overlays = props.Overlays
	if overlays then
		for _, overlay in overlays do
			overlay.Parent = overlayLayer
		end
	end

	-- Let floating UI that fills the window (scrims, sheets) match its rounding.
	window:SetAttribute(Corners.WindowRadiusAttribute, r)

	-- The window is dragged by its app bar, or by `DragHandle` when there is no app bar.
	local dragHandle = props.DragHandle or props.AppBar
	if props.Draggable and dragHandle then
		local handle = dragHandle :: GuiObject
		local bounds = props.DragBounds or "Titlebar"
		local keepX = props.DragKeepVisible or 120

		-- Where the window's top-left may go (absolute screen space).
		local function clampTopLeft(topLeft: Vector2): Vector2
			local host = window:FindFirstAncestorWhichIsA("LayerCollector")
			if host == nil or bounds == "Free" then
				return topLeft
			end
			local hostPos = (host :: any).AbsolutePosition :: Vector2
			local hostSize = (host :: any).AbsoluteSize :: Vector2
			local size = window.AbsoluteSize
			local minX, maxX, minY, maxY
			if bounds == "Screen" then
				minX, maxX = hostPos.X, math.max(hostPos.X, hostPos.X + hostSize.X - size.X)
				minY, maxY = hostPos.Y, math.max(hostPos.Y, hostPos.Y + hostSize.Y - size.Y)
			else
				-- Titlebar: most of the window may leave the screen, but never the handle.
				local visibleX = math.min(size.X, keepX)
				local visibleY = math.min(size.Y, handle.AbsoluteSize.Y)
				minX, maxX = hostPos.X - (size.X - visibleX), hostPos.X + hostSize.X - visibleX
				minY, maxY = hostPos.Y, hostPos.Y + hostSize.Y - visibleY
			end
			return Vector2.new(math.clamp(topLeft.X, minX, maxX), math.clamp(topLeft.Y, minY, maxY))
		end

		table.insert(
			scope,
			handle.InputBegan:Connect(function(input: InputObject)
				if
					input.UserInputType ~= Enum.UserInputType.MouseButton1
					and input.UserInputType ~= Enum.UserInputType.Touch
				then
					return
				end
				local startPointer = Vector2.new(input.Position.X, input.Position.Y)
				local startPosition = window.Position
				local startTopLeft = window.AbsolutePosition

				ScrollInput.capture(window, function(move: InputObject)
					return move.UserInputType == Enum.UserInputType.MouseMovement
						or move.UserInputType == Enum.UserInputType.Touch
				end, function(ended: InputObject)
					return ended.UserInputType == Enum.UserInputType.MouseButton1
						or ended.UserInputType == Enum.UserInputType.Touch
				end, function(pointer: Vector3)
					local target = clampTopLeft(
						startTopLeft + (Vector2.new(pointer.X, pointer.Y) - startPointer)
					)
					local delta = target - startTopLeft
					local position = UDim2.new(
						startPosition.X.Scale,
						startPosition.X.Offset + delta.X,
						startPosition.Y.Scale,
						startPosition.Y.Offset + delta.Y
					)
					-- A Value passed as `Position` keeps the position across rebuilds.
					local source: any = props.Position
					if typeof(source) == "table" and source.set then
						source:set(position)
					else
						window.Position = position
					end
				end, function() end)
			end)
		)
	end

	if props.Resizable then
		local minSize: Vector2 = props.MinSize or Vector2.new(240, 160)
		local maxSize: Vector2? = props.MaxSize
		local thickness: number = props.ResizeHandleSize or 6
		local cornerSize = thickness * 2
		local handles: { string } = props.ResizeHandles or ALL_HANDLES
		-- A locked ratio: explicit, else the window's own aspect-ratio constraint.
		local ratio: number? = props.ResizeRatio
		if ratio == nil and props.AspectRatio then
			ratio = (props.AspectRatio :: any).Ratio
		end

		-- (position, size) of each handle: thin strips on the edges, squares on the corners.
		local function geometry(name: string): (UDim2, UDim2)
			local t, c = thickness, cornerSize
			if name == "Left" then
				return UDim2.new(0, 0, 0, c), UDim2.new(0, t, 1, -2 * c)
			elseif name == "Right" then
				return UDim2.new(1, -t, 0, c), UDim2.new(0, t, 1, -2 * c)
			elseif name == "Top" then
				return UDim2.new(0, c, 0, 0), UDim2.new(1, -2 * c, 0, t)
			elseif name == "Bottom" then
				return UDim2.new(0, c, 1, -t), UDim2.new(1, -2 * c, 0, t)
			elseif name == "TopLeft" then
				return UDim2.new(0, 0, 0, 0), UDim2.fromOffset(c, c)
			elseif name == "TopRight" then
				return UDim2.new(1, -c, 0, 0), UDim2.fromOffset(c, c)
			elseif name == "BottomLeft" then
				return UDim2.new(0, 0, 1, -c), UDim2.fromOffset(c, c)
			end
			return UDim2.new(1, -c, 1, -c), UDim2.fromOffset(c, c)
		end

		-- A Value passed as `Size` / `Position` keeps the result across rebuilds.
		local function write(prop: string, value: UDim2)
			local source: any = (props :: any)[prop]
			if typeof(source) == "table" and source.set then
				source:set(value)
			else
				(window :: any)[prop] = value
			end
		end

		-- Resize cursor: a glyph that follows the pointer while it is over a handle or dragging.
		local cursor = scope:New("Frame")({
			Name = "ResizeCursor",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(26, 26),
			BackgroundColor3 = theme.Colors.SurfaceContainer,
			BackgroundTransparency = 0.1,
			Visible = false,
			Active = false,
			ZIndex = 1000,
			[Children] = {
				scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
				scope:New("UIStroke")({ Color = theme.Colors.Outline, Transparency = 0.5 }),
			},
		}) :: Frame
		local cursorIcons: { [string]: Instance } = {}
		for _, iconName in
			{ "move-horizontal", "move-vertical", "move-diagonal", "move-diagonal-2" }
		do
			local icon = scope:Apply(Icon(scope, {
				Theme = theme,
				Name = iconName,
				IconSize = theme.Metrics.IconMd,
				Color = theme.Colors.OnSurface,
			}))({
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Visible = false,
				Parent = cursor,
			})
			cursorIcons[iconName] = icon
		end
		local hovering: { [string]: boolean } = {}
		local draggingHandle: string? = nil
		local hiddenSystemCursor = false

		local function placeCursor()
			local host = window:FindFirstAncestorWhichIsA("LayerCollector") :: any
			if host and cursor.Parent ~= host then
				cursor.Parent = host
			end
			-- GetMouseLocation is in screen space (includes the top bar inset); the GUI space the
			-- cursor lives in only does when the ScreenGui ignores the inset.
			local pointer = UserInputService:GetMouseLocation()
			if not (host and host:IsA("ScreenGui") and host.IgnoreGuiInset) then
				pointer -= GuiService:GetGuiInset()
			end
			cursor.Position = UDim2.fromOffset(pointer.X, pointer.Y)
		end

		local function refreshCursor(show: boolean?)
			local shown: string? = draggingHandle
			if shown == nil then
				for handleName in hovering do
					shown = handleName
					break
				end
			end
			if shown == nil then
				cursor.Visible = false
				if hiddenSystemCursor then
					hiddenSystemCursor = false
					UserInputService.MouseIconEnabled = true
				end
				return
			end
			for iconName, icon in cursorIcons do
				(icon :: any).Visible = iconName == HANDLE_CURSOR_ICON[shown]
			end
			if show ~= false then
				placeCursor()
			end
			cursor.Visible = true
			if not hiddenSystemCursor then
				hiddenSystemCursor = true
				UserInputService.MouseIconEnabled = false
			end
		end

		table.insert(scope, function()
			if hiddenSystemCursor then
				UserInputService.MouseIconEnabled = true
			end
		end)

		for _, name in handles do
			local edges = HANDLE_EDGES[name]
			if edges == nil then
				continue
			end
			local position, size = geometry(name)
			local handle = scope:New("Frame")({
				Name = `Resize{name}`,
				BackgroundTransparency = 1,
				Active = true,
				Position = position,
				Size = size,
				-- Above the chrome, below the overlay layer (dialogs, sheets).
				ZIndex = 40,
				Parent = window,
			}) :: Frame

			table.insert(
				scope,
				handle.MouseEnter:Connect(function()
					hovering[name] = true
					refreshCursor()
				end)
			)
			table.insert(
				scope,
				handle.MouseMoved:Connect(function()
					if hovering[name] or draggingHandle == name then
						refreshCursor()
					end
				end)
			)
			table.insert(
				scope,
				handle.MouseLeave:Connect(function()
					hovering[name] = nil
					refreshCursor(false)
				end)
			)

			table.insert(
				scope,
				handle.InputBegan:Connect(function(input: InputObject)
					if
						input.UserInputType ~= Enum.UserInputType.MouseButton1
						and input.UserInputType ~= Enum.UserInputType.Touch
					then
						return
					end
					local startPointer = Vector2.new(input.Position.X, input.Position.Y)
					local startTopLeft = window.AbsolutePosition
					local startSize = window.AbsoluteSize
					local startPosition = window.Position
					local anchor = window.AnchorPoint

					local host = window:FindFirstAncestorWhichIsA("LayerCollector") :: any
					local hostSize: Vector2 = if host
						then host.AbsoluteSize
						else Vector2.new(math.huge, math.huge)
					local limits: Resize.Limits = {
						minWidth = minSize.X,
						minHeight = minSize.Y,
						maxWidth = if maxSize then maxSize.X else hostSize.X,
						maxHeight = if maxSize then maxSize.Y else hostSize.Y,
						ratio = ratio,
						grid = props.ResizeSnap,
					}

					draggingHandle = name
					refreshCursor()

					ScrollInput.capture(window, function(move: InputObject)
						return move.UserInputType == Enum.UserInputType.MouseMovement
							or move.UserInputType == Enum.UserInputType.Touch
					end, function(ended: InputObject)
						return ended.UserInputType == Enum.UserInputType.MouseButton1
							or ended.UserInputType == Enum.UserInputType.Touch
					end, function(pointer: Vector3)
						refreshCursor()
						local x, y, w, h = Resize.compute(
							edges,
							startTopLeft.X,
							startTopLeft.Y,
							startSize.X,
							startSize.Y,
							pointer.X - startPointer.X,
							pointer.Y - startPointer.Y,
							limits
						)
						-- Position is anchored: move it by how far the anchor point moved.
						local shiftX = (x + anchor.X * w)
							- (startTopLeft.X + anchor.X * startSize.X)
						local shiftY = (y + anchor.Y * h)
							- (startTopLeft.Y + anchor.Y * startSize.Y)
						write(
							"Position",
							UDim2.new(
								startPosition.X.Scale,
								startPosition.X.Offset + shiftX,
								startPosition.Y.Scale,
								startPosition.Y.Offset + shiftY
							)
						)
						write("Size", UDim2.fromOffset(w, h))
						if props.OnResized then
							props.OnResized(Vector2.new(w, h))
						end
					end, function()
						draggingHandle = nil
						refreshCursor(false)
					end)
				end)
			)
		end
	end

	Layer.bind(overlayLayer)

	return window
end
