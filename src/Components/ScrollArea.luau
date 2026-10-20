--!strict
--[[
	Custom scroll surface with chrome (vertical or horizontal).

	Vertical:                 Horizontal:
		^    
		|                    < ====[]==== >
		|
	   | |
	   | |
		|
		|
		V
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local whileActive = require(script.Parent.Parent.Internal.Follow)
local ScrollInput = require(script.Parent.Parent.Internal.ScrollInput)
local Icon = require(script.Parent.Icon)
local LoadingIndicator = require(script.Parent.LoadingIndicator)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek
local UserInputService = game:GetService("UserInputService")

return function(scope: Types.Scope, props: Types.ScrollAreaProps): Instance
	local theme = resolveTheme(props)
	local horizontal = props.Orientation == "Horizontal"
	local smooth = props.Smooth ~= false
	local inertia = props.Inertia ~= false
	local keyboard = props.Keyboard ~= false
	local autoCanvas = props.AutoCanvas ~= false
	local railClick = props.ScrollBarRail ~= false
	local showRail = if props.ScrollBarRailBackground == nil
		then true
		else props.ScrollBarRailBackground
	local autoHide = props.AutoHideScrollBar ~= false
	-- With an overlay bar the content keeps its full width, and the bar is drawn over it.
	local overlayBar = props.ScrollBarOverlay == true
	local hideDelay = props.AutoHideDelay or 0.85
	local showButtons = props.ScrollButtons == true
	local buttonStep = props.ScrollButtonStep or 64
	local thumbThickness = props.ScrollBarThickness or 8
	local railThickness = props.ScrollBarRailThickness or 2
	local padX = props.ScrollBarPadding or 6
	local buttonSize = if showButtons then 20 else 0
	local chromeInner = math.max(thumbThickness, railThickness, if showButtons then 16 else 0)
	local chromeCross = chromeInner + padX * 2
	local contentLayout = props.ContentLayout or "List"
	local contentPad = if props.ContentPadding ~= nil
		then props.ContentPadding
		else theme.Metrics.SpaceMd
	local listPad = if props.ListPadding ~= nil then props.ListPadding else theme.Metrics.SpaceLg
	local useListLayout = contentLayout ~= "None"
	-- Extra inset so UIStroke near full-bleed children isn't sheared by root clip.
	local padInset = if useListLayout then contentPad + 2 else contentPad

	local idleColor = props.ScrollBarColor or theme.Colors.Outline
	local railIdleColor = props.ScrollBarRailColor or theme.Colors.OutlineVariant
	local activeColor = props.ScrollBarActiveColor or theme.Colors.Primary

	local contentSize = scope:Value(Vector2.new(0, 0))
	local viewSize = scope:Value(Vector2.new(0, 200))
	-- False until the content has been measured once. Before that maxScroll() is 0, so an
	-- initial ScrollOffset (e.g. restored after a rebuild) would look like an overscroll and
	-- the edge-settling loop would snap it back to 0.
	local measured = scope:Value(false)
	local offset = scope:Value(peek(props.ScrollOffset) or 0)
	local velocity = scope:Value(0)
	local target = scope:Value(peek(props.ScrollOffset) or 0)
	local scrollSpring = scope:Spring(
		target,
		if smooth then theme.Motion.SpringSpeed * 1 else theme.Motion.SpringSpeed * 2,
		theme.Motion.SpringDamping
	)

	local barVisible = scope:Value(1)
	local barVisibleS =
		scope:Spring(barVisible, theme.Motion.SpringSpeed * 0.05, theme.Motion.SpringDamping)
	local hoveringBar = scope:Value(0)
	local hoveringBarS =
		scope:Spring(hoveringBar, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
	local draggingBar = scope:Value(0)
	local draggingBarS =
		scope:Spring(draggingBar, theme.Motion.SpringSpeed * 1.2, theme.Motion.SpringDamping)
	local railPressed = scope:Value(0)
	local railPressedS =
		scope:Spring(railPressed, theme.Motion.SpringSpeed * 1.4, theme.Motion.SpringDamping)
	local stretch = scope:Value(0)
	local stretchS =
		scope:Spring(stretch, theme.Motion.SpringSpeed * 0.06, theme.Motion.SpringDamping)
	local lastActivity = scope:Value(os.clock())

	local function axisOf(v: Vector2): number
		return if horizontal then v.X else v.Y
	end

	local function maxScroll(): number
		return math.max(0, axisOf(peek(contentSize)) - axisOf(peek(viewSize)))
	end

	local function bumpActivity()
		lastActivity:set(os.clock())
		if maxScroll() > 0.5 then
			barVisible:set(1)
		else
			barVisible:set(0)
		end
	end

	local needsScroll = scope:Computed(function(use)
		return axisOf(use(contentSize)) - axisOf(use(viewSize)) > 0.5
	end)
	local chromeHeld = scope:Value(false)
	local chromeGutter = scope:Computed(function(use)
		return if use(chromeHeld) then chromeCross else 0
	end)

	table.insert(
		scope,
		scope:Observer(needsScroll):onBind(function()
			if not peek(needsScroll) then
				barVisible:set(0)
				target:set(0)
				offset:set(0)
				velocity:set(0)
			end
		end)
	)

	local overscrollEnabled = if props.Overscroll ~= nil
		then props.Overscroll
		else (inertia or props.OnRefresh ~= nil)
	-- Drag-to-scroll: touch by default; also mouse when pull-action is enabled (desktop).
	local touchDevice = UserInputService.TouchEnabled
	local dragToScroll = if props.DragToScroll == nil
		then (touchDevice or props.OnRefresh ~= nil)
		else props.DragToScroll == true
	local refreshThreshold = props.RefreshThreshold or 72
	local showPullIndicator = if props.PullIndicator ~= nil
		then props.PullIndicator
		else props.OnRefresh ~= nil
	local pullHint = props.PullHint or "Keep scrolling to continue"
	local releaseHint = props.ReleaseHint or "Release to continue"
	local refreshingHint = props.RefreshingHint or "Refreshing…"
	local contentDragging = scope:Value(false)
	local pullDepth = scope:Value(0) -- positive px pulled past top while interacting
	-- While `Refreshing` is true the content rests at the threshold with a spinner (iOS / Android
	-- style) instead of springing straight back.
	local holding = false
	local settlingBack = false -- easing home after a hold; must not re-arm the refresh
	local holdingState = scope:Value(false)
	local function refreshingNow(): boolean
		return props.Refreshing ~= nil and peek(props.Refreshing) == true
	end
	local didPull = false

	-- Wheel / trackpad pull-to-refresh: scrolling up from the very top pulls the content down
	-- (rubber-band); releasing past the threshold refreshes, like a touch drag.
	local wheelGestureAtTop = false -- the current wheel burst began at the very top
	local lastWheelAt = 0
	local wheelPullTravel = 0 -- scroll-up px accumulated at the top this gesture
	local wheelPeak = 0 -- largest delta this gesture, to spot momentum tails
	local wheelRefreshTravel = 32 -- scroll-up travel that reaches the refresh threshold
	local wheelPulling = false
	local wheelReleaseToken = 0
	-- Assigned once settleIfNeeded exists (it is defined after scrollBy).
	local releaseWheelPull: (() -> ())? = nil

	local function emitScroll(y: number)
		if not props.OnScroll then
			return
		end
		local last = (scope :: any)._pantheonLastScroll
		if typeof(last) == "number" and math.abs(y - last) < 0.5 then
			return
		end
		(scope :: any)._pantheonLastScroll = y
		props.OnScroll(y)
	end

	local function resist(y: number): number
		local max = maxScroll()
		-- Top: exponential rubber-band that eases toward a limit (never a hard stop).
		if y < 0 then
			local limit = refreshThreshold * 3
			return -limit * (1 - math.exp(y / limit))
		end
		local shownLimit = math.max(refreshThreshold * 1.15, 88)
		if y > max then
			return math.min(max + (y - max) * 0.28, max + shownLimit)
		end
		return y
	end

	local function clampScroll(y: number): number
		return math.clamp(y, 0, maxScroll())
	end

	local overscrollLimit = math.max(refreshThreshold * 2.5, 180)
	local function clampOverscrollTarget(y: number): number
		local max = maxScroll()
		return math.clamp(y, -overscrollLimit, max + overscrollLimit)
	end

	-- Top-edge pull only (for OnRefresh). Bottom stays hard-clamped on wheel.
	local function clampTopPullTarget(y: number): number
		local max = maxScroll()
		return math.clamp(y, -overscrollLimit, max)
	end

	local function scrollBy(delta: number, raw: boolean?)
		-- No overflow: don't scroll or show chrome (pull-to-refresh may still drag).
		if maxScroll() <= 0.5 and props.OnRefresh == nil then
			return
		end
		if maxScroll() <= 0.5 and not (raw or peek(contentDragging)) then
			return
		end
		bumpActivity()
		local current = peek(target)
		if current >= 0 then
			settlingBack = false
		end
		local max = maxScroll()
		local nextY = current + delta
		if raw or peek(contentDragging) then
			-- Touch / mouse drag: allow capped overscroll for pull-to-refresh.
			if overscrollEnabled then
				nextY = clampOverscrollTarget(nextY)
			else
				nextY = clampScroll(nextY)
			end
			target:set(nextY)
			if not smooth then
				offset:set(if overscrollEnabled then resist(nextY) else nextY)
				emitScroll(peek(offset))
			end
		else
			-- Wheel / trackpad: hard-clamp mid-list + bottom; allow top pull when OnRefresh.
			local now = os.clock()
			if now - lastWheelAt > 0.15 then
				-- A new burst of wheel events: only a burst that *starts* at the top may pull.
				-- (Momentum from a fast scroll up the page must not trigger a refresh.)
				wheelGestureAtTop = current <= 0.5
				wheelPullTravel = 0
				wheelPeak = 0
			end
			lastWheelAt = now

			local canPull = overscrollEnabled
				and not horizontal
				and props.OnRefresh ~= nil
				and not holding
				and not settlingBack
			local topPull = canPull and (wheelGestureAtTop and current <= 0.5 and delta < 0)

			if topPull then
				wheelPulling = true
				contentDragging:set(true)
				velocity:set(0)

				-- Deltas fading well below their peak are the OS momentum tail (fingers already
				-- lifted): stop deepening the pull and let it release.
				local magnitude = math.abs(delta)
				wheelPeak = math.max(wheelPeak, magnitude)
				local tail = magnitude < wheelPeak * 0.45
				if not tail then
					-- Pull follows the scroll-up travel; wheelRefreshTravel of it reaches the
					-- refresh threshold.
					wheelPullTravel = math.max(wheelPullTravel - delta, 0)
					nextY = clampTopPullTarget(
						-wheelPullTravel * (refreshThreshold / wheelRefreshTravel)
					)
					target:set(nextY)
					if nextY < -10 then
						didPull = true
					end
					if not smooth then
						offset:set(if nextY < 0 then resist(nextY) else nextY)
						emitScroll(peek(offset))
					end
					-- Scrolled back down to the top: the pull is over.
					if nextY >= 0 then
						wheelPulling = false
						contentDragging:set(false)
						didPull = false
						return
					end
				end

				-- Like lifting a finger: release (refresh if past the threshold) once the wheel
				-- goes quiet, sooner when it is only momentum.
				wheelReleaseToken += 1
				local mine = wheelReleaseToken
				task.delay(if tail then 0.06 else 0.14, function()
					if mine == wheelReleaseToken and wheelPulling and releaseWheelPull then
						releaseWheelPull()
					end
				end)
				return
			else
				nextY = clampScroll(nextY)
				target:set(nextY)
				if not smooth then
					offset:set(nextY)
					emitScroll(nextY)
				end
				if inertia then
					-- Mild acceleration for precise wheel / trackpad input, with a soft cap.
					local v = peek(velocity)
					local boost = delta * 9 * (1 / (1 + math.abs(v) / 180))
					v = v + boost
					if nextY <= 0 then
						velocity:set(math.max(0, v))
					elseif nextY >= max then
						velocity:set(math.min(0, v))
					else
						velocity:set(math.clamp(v, -280, 280))
					end
				end
			end
			return
		end
		if inertia and not peek(contentDragging) then
			velocity:set(peek(velocity) + delta * 22)
		end
	end

	local function scrollTo(y: number)
		bumpActivity()
		local nextY = clampScroll(y)
		target:set(nextY)
		velocity:set(0)
		contentDragging:set(false)
		if not smooth then
			offset:set(nextY)
			emitScroll(nextY)
		end
	end

	local function endHold()
		if not holding then
			return
		end
		holding = false
		holdingState:set(false)
		settlingBack = true
	end

	if props.Refreshing ~= nil and typeof(props.Refreshing) == "table" then
		table.insert(
			scope,
			scope:Observer(props.Refreshing :: any):onChange(function()
				if not refreshingNow() then
					endHold()
				end
			end)
		)
	end

	local function settleIfNeeded()
		local max = maxScroll()
		local y = peek(target)
		if y < 0 and holding then
			-- Released while refreshing: stay parked at the threshold.
			target:set(-refreshThreshold)
			velocity:set(0)
			return
		end
		if y < 0 then
			local armed = not horizontal and props.OnRefresh ~= nil and y <= -refreshThreshold
			if armed and not settlingBack then
				local onRefresh = props.OnRefresh
				local holdsRefresh = props.Refreshing ~= nil
				if holdsRefresh then
					holding = true
					holdingState:set(true)
				end
				if onRefresh then
					task.defer(function()
						onRefresh()
						-- Never started refreshing: don't leave the content parked.
						if holding and not refreshingNow() then
							endHold()
						end
					end)
				end
				if holdsRefresh then
					didPull = false
					target:set(-refreshThreshold)
					velocity:set(0)
					return
				end
			elseif didPull then
				local onPullCancel = props.OnPullCancel
				if onPullCancel then
					task.defer(onPullCancel)
				end
			end
			didPull = false
			pullDepth:set(0)
			target:set(0)
			velocity:set(0)
		elseif y > max then
			didPull = false
			pullDepth:set(0)
			target:set(max)
			velocity:set(0)
		else
			didPull = false
			pullDepth:set(0)
		end
	end

	-- End of a wheel / trackpad pull: same as lifting a finger after a drag.
	releaseWheelPull = function()
		wheelPulling = false
		wheelPeak = 0
		contentDragging:set(false)
		settleIfNeeded()
	end

	local function activeAmount(use: any): number
		return math.clamp(
			use(draggingBarS) + use(railPressedS) * 0.85 + use(hoveringBarS) * 0.35,
			0,
			1
		)
	end

	table.insert(
		scope,
		scope:Observer(scrollSpring):onBind(function()
			local raw = peek(scrollSpring)
			local y = if overscrollEnabled and peek(contentDragging)
				then resist(raw)
				else clampScroll(raw)
			-- While free-springing past edges, show resisted position then settle
			if overscrollEnabled and not peek(contentDragging) then
				if raw < 0 or raw > maxScroll() then
					y = resist(raw)
					if math.abs(raw - clampScroll(raw)) < 0.5 then
						y = clampScroll(raw)
					end
				end
			end
			offset:set(y)
			emitScroll(y)

			if not horizontal and showPullIndicator then
				local depth = if y < 0 then -y else 0
				if peek(contentDragging) or depth > 1 then
					pullDepth:set(depth)
					if depth > 10 then
						didPull = true
					end
				elseif depth <= 1 then
					pullDepth:set(0)
				end
			end
		end)
	)

	if props.ScrollOffset ~= nil and typeof(props.ScrollOffset) == "table" then
		table.insert(
			scope,
			scope:Observer(props.ScrollOffset :: any):onChange(function()
				local y = peek(props.ScrollOffset)
				if typeof(y) == "number" and math.abs(y - peek(target)) > 0.5 then
					scrollTo(y)
				end
			end)
		)
	end

	-- Step only while something is moving, overscrolled, or the bar is waiting to hide.
	local function scrollStep(dt: number)
		if peek(contentDragging) or holding then
			return
		end
		local v = peek(velocity)
		local y = peek(target)
		local max = maxScroll()
		-- Rubber-band settle when past edges (after coasting stops).
		if overscrollEnabled and (y < 0 or y > max) and math.abs(v) < 0.35 then
			if y < 0 then
				local armed = not horizontal
					and props.OnRefresh ~= nil
					and y <= -refreshThreshold
					and not settlingBack
				if armed then
					settleIfNeeded()
				else
					if didPull and props.OnPullCancel then
						didPull = false
						task.defer(props.OnPullCancel)
					end
					didPull = false
					local nextY = y + (0 - y) * math.min(1, dt * 10)
					if math.abs(nextY) < 0.5 then
						nextY = 0
						velocity:set(0)
						pullDepth:set(0)
						settlingBack = false
					end
					target:set(nextY)
				end
			else
				local nextY = y + (max - y) * math.min(1, dt * 10)
				if math.abs(nextY - max) < 0.5 then
					nextY = max
					velocity:set(0)
				end
				target:set(nextY)
			end
		elseif math.abs(v) >= 0.35 then
			local nextY = y + v * dt
			-- Inertia may finish a touch rubber-band, but wheel momentum hard-stops at edges
			-- (except top pull). Decelerate gently so coast stays controllable.
			local decay = math.max(0, 1 - dt * 3.2)
			if overscrollEnabled and (y < -0.5 or y > max + 0.5) then
				target:set(clampOverscrollTarget(nextY))
				velocity:set(v * decay)
			else
				local clamped = clampScroll(nextY)
				target:set(clamped)
				if clamped ~= nextY then
					velocity:set(0)
				else
					velocity:set(v * decay)
				end
			end
		else
			velocity:set(0)
			if overscrollEnabled and (y < 0 or y > max) then
				settleIfNeeded()
			end
		end

		if autoHide and peek(draggingBar) < 0.5 and peek(hoveringBar) < 0.5 then
			if os.clock() - peek(lastActivity) > hideDelay then
				barVisible:set(0)
			end
		end
	end

	if inertia or autoHide then
		local needsStep = scope:Computed(function(use)
			if not use(measured) then
				return false
			end
			if inertia then
				local y = use(target)
				if use(velocity) ~= 0 or y < 0 or y > maxScroll() then
					return true
				end
			end
			return autoHide and use(barVisible) ~= 0
		end)
		whileActive(scope, needsStep, function(on)
			return on == true
		end, function(dt: number)
			if inertia then
				scrollStep(dt)
			elseif autoHide and peek(draggingBar) < 0.5 and peek(hoveringBar) < 0.5 then
				if os.clock() - peek(lastActivity) > hideDelay then
					barVisible:set(0)
				end
			end
		end)
	end

	local requestCanvasSync: (() -> ())? = nil

	local content = scope:New("Frame")({
		Name = "Content",
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		-- Hug content on the scroll axis. Scroll distance comes from
		-- UIListLayout.AbsoluteContentSize, never from Content.AbsoluteSize
		-- (that collapses to the clipped viewport and kills maxScroll).
		Size = scope:Computed(function(use)
			local gutter = if overlayBar then 0 else use(chromeGutter)
			local cs = use(contentSize) :: Vector2
			if horizontal then
				if autoCanvas then
					return UDim2.new(0, 0, 1, -gutter)
				end
				return UDim2.new(0, math.max(cs.X, 1), 1, -gutter)
			end
			if autoCanvas then
				return UDim2.new(1, -gutter, 0, 0)
			end
			return UDim2.new(1, -gutter, 0, math.max(cs.Y, 1))
		end),
		AutomaticSize = if not autoCanvas
			then Enum.AutomaticSize.None
			elseif horizontal then Enum.AutomaticSize.X
			else Enum.AutomaticSize.Y,
		Position = scope:Computed(function(use)
			local off = use(offset) :: number
			if horizontal then
				return UDim2.fromOffset(-off, 0)
			end
			return UDim2.fromOffset(0, -off)
		end),
		[Children] = {
			if useListLayout
				then scope:New("UIPadding")({
					PaddingTop = UDim.new(0, padInset),
					PaddingBottom = UDim.new(0, padInset),
					PaddingLeft = UDim.new(0, padInset),
					PaddingRight = UDim.new(0, padInset),
				})
				else nil,
			if useListLayout
				then scope:New("UIListLayout")({
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = if horizontal
						then Enum.FillDirection.Horizontal
						else Enum.FillDirection.Vertical,
					Padding = UDim.new(0, listPad),
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				})
				else nil,
			props.Children,
		},
	})

	if autoCanvas then
		local layout = content:FindFirstChildOfClass("UIListLayout")
		local childConns: { RBXScriptConnection } = {}
		local syncQueued = false
		local function measureAlong(): number
			-- Prefer layout AbsoluteContentSize (includes list padding, ignores clip).
			if layout then
				local along = if horizontal
					then layout.AbsoluteContentSize.X
					else layout.AbsoluteContentSize.Y
				-- UIPadding is outside AbsoluteContentSize.
				return math.max(along + padInset * 2, 1)
			end
			local along = padInset * 2
			local visible = 0
			for _, child in content:GetChildren() do
				if child:IsA("GuiObject") and child.Visible and not child:IsA("UIBase") then
					visible += 1
					along += if horizontal then child.AbsoluteSize.X else child.AbsoluteSize.Y
				end
			end
			if visible > 1 then
				along += listPad * (visible - 1)
			end
			return math.max(along, 1)
		end
		local function applyCanvasSize()
			local along = measureAlong()
			local vs = peek(viewSize)
			local nextSize = if horizontal
				then Vector2.new(along, math.max(vs.Y, 1))
				else Vector2.new(math.max(vs.X, 1), along)
			if not peek(measured) and axisOf(vs) > 1 and along > 1 then
				measured:set(true)
			end
			local prev = peek(contentSize)
			local overflow = axisOf(nextSize) - axisOf(vs)
			if overflow > 0.5 then
				chromeHeld:set(true)
			elseif overflow < -(chromeCross + 1) then
				chromeHeld:set(false)
			end
			if math.abs(prev.X - nextSize.X) < 0.5 and math.abs(prev.Y - nextSize.Y) < 0.5 then
				return
			end
			contentSize:set(nextSize)
		end
		-- Never write contentSize from inside an AbsoluteSize / AbsoluteContentSize handler:
		-- gutter + AutomaticSize reflow those same signals and hit Roblox's
		-- re-entrancy cap.
		local function scheduleCanvasSync()
			if syncQueued then
				return
			end
			syncQueued = true
			task.defer(function()
				syncQueued = false
				if content.Parent then
					applyCanvasSize()
				end
			end)
		end
		local function bindChild(child: Instance)
			if not child:IsA("GuiObject") or child:IsA("UIBase") then
				return
			end
			-- Layout already reports AbsoluteContentSize; child AbsoluteSize
			-- would recurse when the gutter reflows the row.
			if layout then
				table.insert(
					childConns,
					child:GetPropertyChangedSignal("Visible"):Connect(scheduleCanvasSync)
				)
				return
			end
			table.insert(
				childConns,
				child:GetPropertyChangedSignal("AbsoluteSize"):Connect(scheduleCanvasSync)
			)
			table.insert(
				childConns,
				child:GetPropertyChangedSignal("Visible"):Connect(scheduleCanvasSync)
			)
		end
		local function rebindChildren()
			for _, conn in childConns do
				conn:Disconnect()
			end
			table.clear(childConns)
			for _, child in content:GetChildren() do
				bindChild(child)
			end
			scheduleCanvasSync()
		end
		if layout then
			table.insert(
				scope,
				layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(scheduleCanvasSync)
			)
		end
		table.insert(scope, content.ChildAdded:Connect(rebindChildren))
		table.insert(scope, content.ChildRemoved:Connect(rebindChildren))
		table.insert(scope, function()
			for _, conn in childConns do
				conn:Disconnect()
			end
		end)
		task.defer(rebindChildren)
		requestCanvasSync = scheduleCanvasSync
	elseif props.CanvasSize then
		table.insert(
			scope,
			scope:Observer(props.CanvasSize :: any):onBind(function()
				local c = peek(props.CanvasSize)
				if typeof(c) == "UDim2" then
					contentSize:set(Vector2.new(c.X.Offset, c.Y.Offset))
				end
			end)
		)
	end

	-- Thin rail line, no accent tint (stays neutral)
	local railLine = scope:New("Frame")({
		Name = "Rail",
		BackgroundColor3 = railIdleColor,
		BackgroundTransparency = scope:Computed(function(use)
			if not showRail then
				return 1
			end
			local hide = (1 - use(barVisibleS)) * 0.35
			return math.clamp(0.4 + hide, 0.15, 0.85)
		end),
		AnchorPoint = if horizontal then Vector2.new(0, 0.5) else Vector2.new(0.5, 0),
		Position = if horizontal then UDim2.new(0, 0, 0.5, 0) else UDim2.new(0.5, 0, 0, 0),
		Size = if horizontal
			then UDim2.new(1, 0, 0, railThickness)
			else UDim2.new(0, railThickness, 1, 0),
		BorderSizePixel = 0,
		ZIndex = 1,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
		},
	})

	local function thumbMetrics(use: any): (number, number, number, number)
		local vs = use(viewSize) :: Vector2
		local cs = use(contentSize) :: Vector2
		local off = use(offset) :: number
		local trackLen = math.max(axisOf(vs) - buttonSize * 2, 1)
		local contentLen = math.max(axisOf(cs), 1)
		local max = math.max(0, contentLen - axisOf(vs))
		local ratio = math.clamp(axisOf(vs) / contentLen, 0.12, 1)
		local t = if max <= 0 then 0 else math.clamp(off / max, 0, 1)
		local baseLen = trackLen * ratio
		local drag = use(draggingBarS) :: number
		local velSx = math.min(math.abs(use(stretchS) :: number), baseLen * 0.7)
		local sx = drag * baseLen * 0.1 + velSx
		local len = math.min(baseLen + sx, trackLen)
		local travel = math.max(trackLen - baseLen, 0)
		local pos = math.clamp(t * travel - (len - baseLen) * 0.5, 0, math.max(trackLen - len, 0))
		local thin = math.max(thumbThickness - drag * 2.5, railThickness + 1)
		return pos, len, thin, trackLen
	end

	-- Thumb sitting on the rail (stretches along scroll axis while dragging)
	local thumb = scope:New("Frame")({
		Name = "Thumb",
		BackgroundColor3 = scope:Computed(function(use)
			return Interaction.lerpColor(idleColor, activeColor, activeAmount(use), use)
		end),
		BackgroundTransparency = scope:Computed(function(use)
			local hide = (1 - use(barVisibleS)) * 0.85
			local boost = activeAmount(use) * 0.4
			return math.clamp(0.25 - boost + hide, 0, 1)
		end),
		AnchorPoint = if horizontal then Vector2.new(0, 0.5) else Vector2.new(0.5, 0),
		Position = scope:Computed(function(use)
			local pos = thumbMetrics(use)
			if horizontal then
				return UDim2.new(0, pos, 0.5, 0)
			end
			return UDim2.new(0.5, 0, 0, pos)
		end),
		Size = scope:Computed(function(use)
			local _, len, thin = thumbMetrics(use)
			if horizontal then
				return UDim2.fromOffset(len, thin)
			end
			return UDim2.fromOffset(thin, len)
		end),
		ZIndex = 2,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
		},
	})

	local track = scope:New("Frame")({
		Name = "ScrollTrack",
		BackgroundTransparency = 1,
		Size = if horizontal
			then UDim2.new(1, -buttonSize * 2, 1, 0)
			else UDim2.new(1, 0, 1, -buttonSize * 2),
		Position = if horizontal
			then UDim2.fromOffset(buttonSize, 0)
			else UDim2.fromOffset(0, buttonSize),
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 1,
		[Children] = {
			railLine,
			thumb,
		},
	})

	local function makeScrollButton(
		name: string,
		iconName: string,
		delta: number,
		startEdge: boolean
	)
		local pressed = scope:Value(0)
		local pressedS = scope:Spring(pressed, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
		local btn = scope:New("TextButton")(P({
			Name = name,
			Text = "",
			BackgroundTransparency = 1,
			Size = if horizontal
				then UDim2.new(0, buttonSize, 1, 0)
				else UDim2.new(1, 0, 0, buttonSize),
			Position = if horizontal
				then (if startEdge then UDim2.fromOffset(0, 0) else UDim2.new(1, -buttonSize, 0, 0))
				else (if startEdge
					then UDim2.fromOffset(0, 0)
					else UDim2.new(0, 0, 1, -buttonSize)),
			BorderSizePixel = 0,
			AutoButtonColor = false,
			[OnEvent("Activated")] = function()
				scrollBy(delta)
			end,
			[OnEvent("MouseButton1Down")] = function()
				pressed:set(1)
				railPressed:set(1)
				bumpActivity()
			end,
			[OnEvent("MouseButton1Up")] = function()
				pressed:set(0)
				railPressed:set(0)
			end,
			[OnEvent("MouseLeave")] = function()
				pressed:set(0)
			end,
			[Children] = {
				scope:Apply(Icon(scope, {
					Theme = theme,
					Name = iconName,
					IconSize = 14,
					Color = scope:Computed(function(use)
						return Interaction.lerpColor(
							use(theme.Colors.OnSurfaceVariant),
							activeColor,
							math.clamp(
								(use(pressedS) :: number) + (use(hoveringBarS) :: number) * 0.5,
								0,
								1
							),
							use
						)
					end),
				}))({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					ImageTransparency = scope:Computed(function(use)
						local hide = (1 - use(barVisibleS)) * 0.7
						return math.clamp(hide, 0, 0.85)
					end),
				}),
			},
		}))
		return btn
	end

	local chrome = scope:New("Frame")({
		Name = "ScrollChrome",
		BackgroundTransparency = 1,
		Visible = needsScroll,
		AnchorPoint = if horizontal then Vector2.new(0, 1) else Vector2.new(1, 0),
		Position = if horizontal then UDim2.new(0, 0, 1, 0) else UDim2.new(1, 0, 0, 0),
		Size = scope:Computed(function(use)
			local gutter = use(chromeGutter)
			if horizontal then
				return UDim2.new(1, 0, 0, gutter)
			end
			return UDim2.new(0, gutter, 1, 0)
		end),
		ZIndex = 5,
		[Children] = {
			scope:New("UIPadding")({
				PaddingLeft = UDim.new(0, if horizontal then 4 else padX),
				PaddingRight = UDim.new(0, if horizontal then 4 else padX),
				PaddingTop = UDim.new(0, if horizontal then padX else 4),
				PaddingBottom = UDim.new(0, if horizontal then padX else 4),
			}),
			scope:New("Frame")({
				Name = "ChromeInner",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				[Children] = {
					if showButtons
						then makeScrollButton(
							if horizontal then "ScrollLeft" else "ScrollUp",
							if horizontal then "chevron-left" else "chevron-up",
							-buttonStep,
							true
						)
						else nil,
					track,
					if showButtons
						then makeScrollButton(
							if horizontal then "ScrollRight" else "ScrollDown",
							if horizontal then "chevron-right" else "chevron-down",
							buttonStep,
							false
						)
						else nil,
				},
			}),
		},
	})

	-- When buttons are off, track should fill the chrome
	if not showButtons then
		track.Size = UDim2.fromScale(1, 1)
		track.Position = UDim2.fromOffset(0, 0)
	end

	-- Shown depth at which releasing refreshes (the resting depth while refreshing).
	local armedDepth = -resist(-refreshThreshold)
	local pullArmed = scope:Computed(function(use)
		return use(pullDepth) >= armedDepth - 0.5
	end)

	local pullIndicator = if showPullIndicator and not horizontal
		then scope:Frame({
			Name = "PullIndicator",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(0, 0),
			Size = scope:Computed(function(use)
				return UDim2.new(1, 0, 0, math.max(use(pullDepth), 0))
			end),
			Visible = scope:Computed(function(use)
				return use(pullDepth) > 1
			end),
			ZIndex = 20,
			ClipsDescendants = true,
			[Children] = {
				-- Centred in the revealed gap; fades in as the pull grows.
				scope:New("CanvasGroup")({
					Name = "IndicatorRow",
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromOffset(0, 0),
					AutomaticSize = Enum.AutomaticSize.XY,
					GroupTransparency = scope:Computed(function(use)
						return 1
							- math.clamp((use(pullDepth) - 8) / math.max(armedDepth - 8, 1), 0, 1)
					end),
					[Children] = {
						scope:New("UIListLayout")({
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Center,
							Padding = UDim.new(0, 8),
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),
						scope:Frame({
							BackgroundTransparency = 1,
							Size = UDim2.fromOffset(20, 20),
							LayoutOrder = 1,
							[Children] = {
								scope:Apply(Icon(scope, {
									Theme = theme,
									Name = "arrow-down",
									IconSize = 18,
									Color = theme.Colors.OnSurfaceVariant,
								}))({
									Visible = scope:Computed(function(use)
										return not use(pullArmed) and not use(holdingState)
									end),
								}),
								scope:Apply(Icon(scope, {
									Theme = theme,
									Name = "arrow-up",
									IconSize = 18,
									Color = theme.Colors.Primary,
								}))({
									Visible = scope:Computed(function(use)
										return use(pullArmed) and not use(holdingState)
									end),
								}),
								scope:Apply(
									LoadingIndicator(scope, { Theme = theme, SizePx = 20 })
								)({
									Visible = holdingState,
								}),
							},
						}),
						scope:TextLabel({
							BackgroundTransparency = 1,
							FontFace = theme.Typography.Label.Font,
							TextSize = theme.Typography.Label.Size,
							TextColor3 = scope:Computed(function(use)
								return if use(pullArmed)
									then use(theme.Colors.Primary)
									else use(theme.Colors.OnSurfaceVariant)
							end),
							Text = scope:Computed(function(use)
								if use(holdingState) then
									return refreshingHint
								end
								return if use(pullArmed) then releaseHint else pullHint
							end),
							AutomaticSize = Enum.AutomaticSize.XY,
							LayoutOrder = 2,
						}),
					},
				}),
			},
		})
		else nil

	local root = scope:New("Frame")({
		Name = "ScrollArea",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Active = true,
		Size = props.Size or UDim2.fromScale(1, 1),
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		[Children] = {
			content,
			chrome,
			pullIndicator,
		},
	}) :: Frame

	-- Route wheel to the deepest scroll area under the pointer; sink so camera doesn't zoom.
	table.insert(
		scope,
		ScrollInput.register({
			root = root,
			horizontal = horizontal,
			scrollBy = scrollBy,
		})
	)

	local function onKey(input: InputObject)
		if horizontal then
			if input.KeyCode == Enum.KeyCode.Right then
				scrollBy(56)
			elseif input.KeyCode == Enum.KeyCode.Left then
				scrollBy(-56)
			elseif input.KeyCode == Enum.KeyCode.PageDown then
				scrollBy(axisOf(peek(viewSize)) * 0.9)
			elseif input.KeyCode == Enum.KeyCode.PageUp then
				scrollBy(-axisOf(peek(viewSize)) * 0.9)
			elseif input.KeyCode == Enum.KeyCode.Home then
				scrollTo(0)
			elseif input.KeyCode == Enum.KeyCode.End then
				scrollTo(maxScroll())
			end
		else
			if input.KeyCode == Enum.KeyCode.Down then
				scrollBy(56)
			elseif input.KeyCode == Enum.KeyCode.Up then
				scrollBy(-56)
			elseif input.KeyCode == Enum.KeyCode.PageDown then
				scrollBy(axisOf(peek(viewSize)) * 0.9)
			elseif input.KeyCode == Enum.KeyCode.PageUp then
				scrollBy(-axisOf(peek(viewSize)) * 0.9)
			elseif input.KeyCode == Enum.KeyCode.Home then
				scrollTo(0)
			elseif input.KeyCode == Enum.KeyCode.End then
				scrollTo(maxScroll())
			end
		end
	end

	table.insert(
		scope,
		root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			viewSize:set(root.AbsoluteSize)
			if requestCanvasSync then
				requestCanvasSync()
			end
		end)
	)
	-- seed once
	task.defer(function()
		if root.Parent then
			viewSize:set(root.AbsoluteSize)
		end
	end)

	-- Drag-to-scroll / pull action (wheel hard-clamps; overscroll is drag-only).
	if dragToScroll then
		local function isDragInput(input: InputObject): boolean
			if input.UserInputType == Enum.UserInputType.Touch then
				return true
			end
			-- Mouse drag when pull-action is enabled (desktop Studio / no touch).
			return props.OnRefresh ~= nil and input.UserInputType == Enum.UserInputType.MouseButton1
		end

		table.insert(
			scope,
			root.InputBegan:Connect(function(input)
				if not isDragInput(input) then
					return
				end
				-- Ignore if starting on scrollbar chrome
				if horizontal then
					if input.Position.Y >= chrome.AbsolutePosition.Y then
						return
					end
				elseif input.Position.X >= chrome.AbsolutePosition.X then
					return
				end
				-- Wait until every handler has seen the press. If a control inside the area captured it
				-- (slider, colour picker), don't scroll.
				local capturesBefore = ScrollInput.captureCount()
				local startPosition = input.Position
				task.defer(function()
					if ScrollInput.captureCount() ~= capturesBefore then
						return
					end
					contentDragging:set(true)
					didPull = false
					velocity:set(0)
					local lastPos = if horizontal then startPosition.X else startPosition.Y
					local lastT = os.clock()
					local pointerType = input.UserInputType
					local stopCapture = ScrollInput.capture(root, function(changed)
						return changed.UserInputType == pointerType
							or (pointerType == Enum.UserInputType.MouseButton1 and changed.UserInputType == Enum.UserInputType.MouseMovement)
							or (
								pointerType == Enum.UserInputType.Touch
								and changed.UserInputType == Enum.UserInputType.Touch
							)
					end, function(endedInput)
						return endedInput.UserInputType == pointerType
					end, function(pos)
						local now = os.clock()
						local dt = math.max(now - lastT, 1 / 240)
						local cur = if horizontal then pos.X else pos.Y
						local d = cur - lastPos
						lastPos = cur
						lastT = now
						scrollBy(-d, true)
						velocity:set(-d / dt)
					end, function()
						contentDragging:set(false)
						settleIfNeeded()
					end)
					table.insert(scope, stopCapture)
				end)
			end)
		)
	end

	table.insert(
		scope,
		chrome.MouseEnter:Connect(function()
			hoveringBar:set(1)
			bumpActivity()
		end)
	)
	table.insert(
		scope,
		chrome.MouseLeave:Connect(function()
			if peek(draggingBar) < 0.5 then
				hoveringBar:set(0)
				railPressed:set(0)
			end
		end)
	)

	table.insert(
		scope,
		track.InputBegan:Connect(function(input: InputObject)
			if
				input.UserInputType ~= Enum.UserInputType.MouseButton1
				and input.UserInputType ~= Enum.UserInputType.Touch
			then
				return
			end
			bumpActivity()
			local trackLen = if horizontal then track.AbsoluteSize.X else track.AbsoluteSize.Y
			local contentLen = math.max(axisOf(peek(contentSize)), 1)
			local view = axisOf(peek(viewSize))
			local max = math.max(0, contentLen - view)
			if max <= 0 then
				return
			end
			local thumbRatio = math.clamp(view / contentLen, 0.12, 1)
			local thumbPx = thumbRatio * trackLen
			local localPos = if horizontal
				then input.Position.X - track.AbsolutePosition.X
				else input.Position.Y - track.AbsolutePosition.Y
			local thumbStart = (peek(offset) / max) * (trackLen - thumbPx)
			local onThumb = localPos >= thumbStart - 2 and localPos <= thumbStart + thumbPx + 2

			if onThumb then
				draggingBar:set(1)
				hoveringBar:set(1)
				local grabOffset = localPos - thumbStart
				local lastAxis = if horizontal then input.Position.X else input.Position.Y
				local lastT = os.clock()
				local travel = math.max(trackLen - thumbPx, 1)

				local stopCapture = ScrollInput.capture(root, function(changed)
					return changed.UserInputType == Enum.UserInputType.MouseMovement
						or changed.UserInputType == Enum.UserInputType.Touch
				end, function(endedInput)
					return endedInput.UserInputType == Enum.UserInputType.MouseButton1
						or endedInput.UserInputType == Enum.UserInputType.Touch
				end, function(pos)
					local now = os.clock()
					local dt = math.max(now - lastT, 1 / 240)
					local cur = if horizontal then pos.X else pos.Y
					local vel = (cur - lastAxis) / dt
					lastAxis = cur
					lastT = now
					stretch:set(math.clamp(vel * 0.055, -36, 36))

					local p = cur
						- (if horizontal then track.AbsolutePosition.X else track.AbsolutePosition.Y)
						- grabOffset
					local t = math.clamp(p / travel, 0, 1)
					scrollTo(t * max)
				end, function()
					draggingBar:set(0)
					stretch:set(0)
				end)
				table.insert(scope, stopCapture)
			elseif railClick then
				railPressed:set(1)
				local t =
					math.clamp((localPos - thumbPx * 0.5) / math.max(trackLen - thumbPx, 1), 0, 1)
				scrollTo(t * max)
				task.delay(0.12, function()
					railPressed:set(0)
				end)
			end
		end)
	)

	if keyboard then
		table.insert(
			scope,
			UserInputService.InputBegan:Connect(function(input, processed)
				if processed then
					return
				end
				onKey(input)
			end)
		)
	end

	bumpActivity()
	return root
end
