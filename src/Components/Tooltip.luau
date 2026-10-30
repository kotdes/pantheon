--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local Motion = require(script.Parent.Parent.Internal.Motion)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local CanvasFade = require(script.Parent.Parent.Internal.CanvasFade)
local Color = require(script.Parent.Parent.Internal.Color)
local Defaults = require(script.Parent.Parent.Internal.Defaults)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Follow = require(script.Parent.Parent.Internal.Follow)
local place = require(script.Parent.Parent.Internal.Placement)

local Children = Fusion.Children
local peek = Fusion.peek
local GuiService = game:GetService("GuiService")

local TAIL = 10 -- side of the rotated square that makes the tail
local HAND_OVER = 0.35 -- seconds after a tooltip is left in which the next one takes over from it

-- The tooltip that is shown now, or that was left a moment ago. The next one starts from it.
type Snapshot = { Position: Vector2, Size: Vector2, Color: Color3, Ink: Color3, Text: string }
local current: {
	snapshot: () -> Snapshot,
	hide: () -> (),
	layer: Instance?,
	left: number?,
}? =
	nil

local function plain(scope: Types.Scope, props: Types.TooltipProps): Instance
	local theme = resolveTheme(props)
	local visible = scope:Value(0)
	local visibleS = Motion.spring(scope, visible, theme, "Snappy")
	local placement: Types.TooltipPlacement = props.Placement or "Auto"
	local gap = props.Gap or 8

	local tip = scope:New("Frame")({
		Name = "Tooltip",
		BackgroundColor3 = theme.Colors.SurfaceContainerHigh,
		AutomaticSize = Enum.AutomaticSize.XY,
		Visible = CanvasFade.shown(scope, visibleS, nil, { Theme = theme }),
		BackgroundTransparency = CanvasFade.surfaceTransparency(scope, visibleS, { Theme = theme }),
		ZIndex = props.ZIndex or 160,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(0, theme.Metrics.RadiusSm) }),
			scope:New("UIPadding")({
				PaddingTop = UDim.new(0, theme.Metrics.SpaceXs),
				PaddingBottom = UDim.new(0, theme.Metrics.SpaceXs),
				PaddingLeft = UDim.new(0, theme.Metrics.SpaceSm),
				PaddingRight = UDim.new(0, theme.Metrics.SpaceSm),
			}),
			scope:New("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = theme.Colors.Outline,
				Thickness = 1,
			}),
			scope:New("TextLabel")({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Label.Font,
				TextSize = theme.Typography.Label.Size,
				TextColor3 = theme.Colors.OnSurface,
				Text = props.Text,
				AutomaticSize = Enum.AutomaticSize.XY,
			}),
		},
	}) :: Frame

	local host = CanvasFade.host(scope, tip, visibleS, { Theme = theme })
	Layer.mount(scope, props, host)

	local function updatePosition()
		local target = Layer.asGui(props.Target)
		if target == nil then
			return
		end
		local layer = Layer.resolve(props)
		local abs = target.AbsolutePosition
		local size = target.AbsoluteSize
		if layer then
			-- Place and clamp in the layer's own space, so inside a Window the tip stays
			-- within the window rather than only within the screen.
			local origin = layer.AbsolutePosition
			local pos, _ = place(
				placement,
				Vector2.new(abs.X - origin.X, abs.Y - origin.Y),
				size,
				host.AbsoluteSize,
				gap,
				layer.AbsoluteSize
			)
			host.Position = pos
		else
			local inset = GuiService:GetGuiInset()
			local camera = workspace.CurrentCamera
			local viewport = if camera then camera.ViewportSize else Vector2.new(1920, 1080)
			local pos, _ = place(
				placement,
				Vector2.new(abs.X, abs.Y),
				size,
				host.AbsoluteSize,
				gap,
				viewport - inset
			)
			host.Position = pos
		end
	end

	local hoverTarget = Layer.asGui(props.Target)
	if hoverTarget then
		table.insert(
			scope,
			hoverTarget.MouseEnter:Connect(function()
				if props.Enabled ~= nil and not Fusion.peek(props.Enabled) then
					return
				end
				visible:set(1)
				task.defer(updatePosition)
			end)
		)
		table.insert(
			scope,
			hoverTarget.MouseLeave:Connect(function()
				visible:set(0)
			end)
		)
		Follow(scope, visible, function(v)
			return v > 0.5
		end, updatePosition)
	end

	return host
end

--[[
	A tooltip with a tail that points at its target. The tail sits on the edge that faces the target
	and slides along it as the tooltip moves. When the pointer goes from one target to another, the
	next tooltip does not appear: it starts as the shape the last one had, and moves, resizes and
	changes colour and text on the way to its own.
]]
local function tailed(scope: Types.Scope, props: Types.TooltipProps): Instance
	local theme = resolveTheme(props)
	local placement: Types.TooltipPlacement = props.Placement or "Auto"
	local gap = (props.Gap or 8) + TAIL / 2

	local role = if props.Color ~= nil
		then Color.resolve(peek(props.Color :: any) :: Types.ColorInput?, theme, "primary")
		else nil
	local fill: Color3 = if role then role.Base else peek(theme.Colors.InverseSurface)
	local ink: Color3 = if role then role.OnBase else peek(theme.Colors.InverseOnSurface)

	-- A layer that comes from `Layer.provide` can only be found while the component is made, not
	-- later when the pointer enters, so it is kept here.
	local layerAtCreation = Layer.resolve(props)
	local function layerNow(): GuiObject?
		return Layer.resolve(props) or layerAtCreation
	end

	local visible = scope:Value(0)
	local visibleS = Motion.spring(scope, visible, theme, "Snappy")
	local shownAlpha = scope:Computed(function(use)
		return math.clamp(use(visibleS) :: number, 0, 1)
	end)

	-- Where the tooltip goes, how big it is, and how it faces the target. Each has a spring.
	local goalX, goalY = scope:Value(0), scope:Value(0)
	local goalW, goalH = scope:Value(0), scope:Value(0)
	local x = Motion.spring(scope, goalX, theme, "LiquidMove")
	local y = Motion.spring(scope, goalY, theme, "LiquidMove", 0.82)
	local w = Motion.spring(scope, goalW, theme, "LiquidWidth")
	local h = Motion.spring(scope, goalH, theme, "LiquidHeight")
	local centre = scope:Value(Vector2.zero) -- middle of the target, in the layer
	local side = scope:Value("Bottom" :: string)

	-- The colour and the text start as the last tooltip's and become this one's.
	local fromColor, fromInk = scope:Value(fill), scope:Value(ink)
	local blendGoal = scope:Value(1)
	local blend = Motion.spring(scope, blendGoal, theme, "LiquidShape")
	local oldText = scope:Value("")
	local swapGoal = scope:Value(1)
	local swap = Motion.spring(scope, swapGoal, theme, "LiquidShape")
	local slide = scope:Value(1) -- which way the old text leaves

	local colour = scope:Computed(function(use)
		return (use(fromColor) :: Color3):Lerp(fill, math.clamp(use(blend) :: number, 0, 1))
	end)
	local inkNow = scope:Computed(function(use)
		return (use(fromInk) :: Color3):Lerp(ink, math.clamp(use(blend) :: number, 0, 1))
	end)

	local function label(name: string, text: any, colourOf: any, offset: any, alpha: any): Instance
		return scope:New("TextLabel")({
			Name = name,
			BackgroundTransparency = 1,
			FontFace = theme.Typography.Label.Font,
			TextSize = theme.Typography.Label.Size,
			TextColor3 = colourOf,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = text,
			Position = scope:Computed(function(use)
				return UDim2.fromOffset(use(offset) :: number, 0)
			end),
			TextTransparency = scope:Computed(function(use)
				return 1 - use(alpha) :: number
			end),
		})
	end
	-- The text that is being left fills the box and is clipped by it. It does not set the size.
	local leaving = label(
		"Leaving",
		oldText,
		fromInk,
		scope:Computed(function(use)
			return -use(slide) * math.clamp(use(swap) :: number, 0, 1) * 14
		end),
		scope:Computed(function(use)
			return 1 - math.clamp(use(swap) :: number, 0, 1)
		end)
	)
	scope:Apply(leaving)({ Size = UDim2.fromScale(1, 1) })
	local arriving = label(
		"Text",
		props.Text,
		inkNow,
		scope:Computed(function(use)
			return use(slide) * (1 - math.clamp(use(swap) :: number, 0, 1)) * 14
		end),
		scope:Computed(function(use)
			return math.clamp(use(swap) :: number, 0, 1) * (use(shownAlpha) :: number)
		end)
	)
	scope:Apply(arriving)({ AutomaticSize = Enum.AutomaticSize.XY })

	-- The text sets the natural size. The tip is a box of the size that the springs give it.
	local content = scope:Frame({
		Name = "Content",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.fromOffset(0, 0),
		[Children] = {
			scope:New("UIPadding")({
				PaddingTop = UDim.new(0, theme.Metrics.SpaceXs),
				PaddingBottom = UDim.new(0, theme.Metrics.SpaceXs),
				PaddingLeft = UDim.new(0, theme.Metrics.SpaceSm),
				PaddingRight = UDim.new(0, theme.Metrics.SpaceSm),
			}),
			leaving,
			arriving,
		} :: any,
	}) :: Frame

	local tip = scope:Frame({
		Name = "Tip",
		BorderSizePixel = 0,
		ClipsDescendants = true,
		BackgroundColor3 = colour,
		BackgroundTransparency = scope:Computed(function(use)
			return 1 - use(shownAlpha) :: number
		end),
		Position = scope:Computed(function(use)
			return UDim2.fromOffset(use(x) :: number, use(y) :: number)
		end),
		Size = scope:Computed(function(use)
			return UDim2.fromOffset(math.max(use(w) :: number, 0), math.max(use(h) :: number, 0))
		end),
		ZIndex = (props.ZIndex or 160) + 1,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(0, theme.Metrics.RadiusSm) }),
			content,
		},
	}) :: Frame

	-- The tail is on the edge that faces the target, as far along it as the target's middle is.
	local tail = scope:Frame({
		Name = "Tail",
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Rotation = 45,
		Size = UDim2.fromOffset(TAIL, TAIL),
		BackgroundColor3 = colour,
		BackgroundTransparency = scope:Computed(function(use)
			return 1 - use(shownAlpha) :: number
		end),
		Position = scope:Computed(function(use)
			local px, py = use(x) :: number, use(y) :: number
			local pw, ph = use(w) :: number, use(h) :: number
			local at = use(centre) :: Vector2
			local along = math.clamp(at.X - px, 14, math.max(pw - 14, 14))
			local down = math.clamp(at.Y - py, 14, math.max(ph - 14, 14))
			local facing = use(side) :: string
			if facing == "Bottom" then
				return UDim2.fromOffset(px + along, py)
			elseif facing == "Top" then
				return UDim2.fromOffset(px + along, py + ph)
			elseif facing == "Right" then
				return UDim2.fromOffset(px, py + down)
			end
			return UDim2.fromOffset(px + pw, py + down)
		end),
		ZIndex = props.ZIndex or 160,
		[Children] = { scope:New("UICorner")({ CornerRadius = UDim.new(0, 2) }) },
	}) :: Frame

	local root = scope:Frame({
		Name = "Tooltip",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Active = false,
		-- It is never hidden. A hidden tooltip is not laid out, so its size could not be measured
		-- when the pointer enters. It is made invisible by its transparency.
		ZIndex = props.ZIndex or 160,
		[Children] = { tail, tip } :: any,
	}) :: Frame
	Layer.mount(scope, props, root)

	-- The springs start from the last tooltip's shape, or from the place that this one goes to, and
	-- never from the corner of the layer. That is set by the first update that can measure the
	-- tooltip, which is why it waits for a size.
	local handedOver: Snapshot? = nil
	local startPending = true
	local function update()
		local target = Layer.asGui(props.Target)
		local layer = layerNow()
		if target == nil or layer == nil then
			return
		end
		local natural = content.AbsoluteSize
		local origin = layer.AbsolutePosition
		local at, facing = place(
			placement,
			target.AbsolutePosition - origin,
			target.AbsoluteSize,
			natural,
			gap,
			layer.AbsoluteSize
		)
		local goal = Vector2.new(at.X.Offset, at.Y.Offset)
		centre:set(target.AbsolutePosition - origin + target.AbsoluteSize / 2)
		side:set(facing)
		goalX:set(goal.X)
		goalY:set(goal.Y)
		goalW:set(natural.X)
		goalH:set(natural.Y)
		if startPending and natural.X > 0 then
			startPending = false
			local start = handedOver
			if start then
				x:setPosition(start.Position.X)
				y:setPosition(start.Position.Y)
				w:setPosition(start.Size.X)
				h:setPosition(start.Size.Y)
			else
				x:setPosition(goal.X)
				y:setPosition(goal.Y)
				w:setPosition(natural.X)
				h:setPosition(natural.Y)
			end
		end
	end

	local function snapshot(): Snapshot
		return {
			Position = Vector2.new(peek(x) :: number, peek(y) :: number),
			Size = Vector2.new(peek(w) :: number, peek(h) :: number),
			Color = peek(colour) :: Color3,
			Ink = peek(inkNow) :: Color3,
			Text = peek(props.Text :: any) :: string,
		}
	end
	local function hideNow()
		visible:set(0)
		visibleS:setPosition(0)
	end
	local me = {
		snapshot = snapshot,
		hide = hideNow,
		layer = layerAtCreation :: Instance?,
		left = nil :: number?,
	}

	local hoverTarget = Layer.asGui(props.Target)
	if hoverTarget then
		table.insert(
			scope,
			hoverTarget.MouseEnter:Connect(function()
				if props.Enabled ~= nil and not peek(props.Enabled :: any) then
					return
				end
				local layer = layerNow()
				me.layer = layer
				handedOver = nil
				startPending = true
				local before = current
				if
					before
					and before ~= me
					and before.layer == layer
					and (before.left == nil or os.clock() - before.left < HAND_OVER)
				then
					-- Take over from the tooltip that was shown: its shape, colour and text.
					handedOver = before.snapshot()
					before.hide()
				end
				me.left = nil
				current = me
				local start = handedOver
				if start then
					fromColor:set(start.Color)
					fromInk:set(start.Ink)
					oldText:set(start.Text)
					slide:set(if start.Position.X <= peek(goalX) then 1 else -1)
					blendGoal:set(0)
					blend:setPosition(0)
					blendGoal:set(1)
					swapGoal:set(0)
					swap:setPosition(0)
					swapGoal:set(1)
				else
					fromColor:set(fill)
					fromInk:set(ink)
					oldText:set("")
					blend:setPosition(1)
					swap:setPosition(1)
				end
				visible:set(1)
				-- Now, so there is no frame at the old place, and once more after the layout.
				update()
				task.defer(update)
			end)
		)
		table.insert(
			scope,
			hoverTarget.MouseLeave:Connect(function()
				visible:set(0)
				me.left = os.clock()
			end)
		)
		Follow(scope, visible, function(v)
			return v > 0.5
		end, update)
	end
	table.insert(scope, function()
		if current == me then
			current = nil
		end
	end)

	return root
end

return function(scope: Types.Scope, props: Types.TooltipProps): Instance
	local theme = resolveTheme(props)
	local withTail = if props.Tail ~= nil
		then props.Tail
		else Defaults.get(theme, "Tooltip", "Tail") == true
	return (if withTail then tailed else plain)(scope, props)
end
