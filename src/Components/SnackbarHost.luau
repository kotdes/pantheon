--!strict
--[[
	Toast host. Toasts stack with the newest in front and older ones behind it, each peeking out
	a little. Hovering the stack spreads the toasts out, and their timers stop while it is
	spread. Each toast has its own scope, so dismissing one frees its springs and instances.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local Motion = require(script.Parent.Parent.Internal.Motion)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Layer = require(script.Parent.Parent.Internal.Layer)
local ScrollInput = require(script.Parent.Parent.Internal.ScrollInput)
local Snackbar = require(script.Parent.Snackbar)
local GroupFade = require(script.Parent.Parent.Internal.GroupFade)

local Children = Fusion.Children
local peek = Fusion.peek

local RunService = game:GetService("RunService")

local SLIDE = 24 -- px a toast travels while entering and leaving
local EXIT_TIME = 0.4 -- seconds to let the exit spring finish before cleanup
local DEFAULT_DURATION = 3
local DEFAULT_MAX = 5
local DEFAULT_WIDTH = 360
local PEEK = 10 -- px of each toast behind the front one that shows above it
local BEHIND_SHOWN = 2 -- toasts shown behind the front one while the stack is closed
local SHRINK = 0.06 -- how much narrower each toast behind is
local GAP = 8 -- space between toasts while the stack is spread out
local HOVER_MARGIN = 10 -- px around the stack that still counts as hovering it
local LEAVE_DELAY = 0.25 -- seconds after the pointer leaves before the stack closes

type Slot = Instance | (scope: Types.Scope, dismiss: () -> ()) -> Instance

export type ShowOptions = {
	--- Seconds on screen (default 3). `math.huge` keeps it until dismissed.
	Duration: number?,
	--- Element before the message, or a function that builds one in the toast's scope.
	Leading: Slot?,
	--- Lucide icon before the message.
	Icon: string?,
	--- Element after the action button, or a function that builds one.
	Trailing: Slot?,
	--- Show a close button.
	Dismissible: boolean?,
	--- Called when the toast is dismissed by its close button.
	OnClose: (() -> ())?,
}

export type HostApi = {
	Instance: Frame,
	--- Returns a function that dismisses just this toast.
	Show: (
		message: string,
		actionText: string?,
		onAction: (() -> ())?,
		options: ShowOptions?
	) -> () -> (),
	--- Dismiss every visible toast.
	Clear: () -> (),
}

type Entry = { dismiss: () -> (), height: any, remaining: number }

return function(scope: Types.Scope, props: Types.SnackbarHostProps?): HostApi
	local p: Types.SnackbarHostProps = props or {}
	local theme = resolveTheme(p)
	local maxVisible: number = p.MaxVisible or DEFAULT_MAX
	local width: number = p.Width or DEFAULT_WIDTH

	local entries = scope:Value({} :: { Entry }) -- oldest first
	local spread = scope:Value(false)

	local stackHeight = scope:Computed(function(use)
		local list = use(entries) :: { Entry }
		local count = #list
		if count == 0 then
			return 0
		end
		if use(spread) then
			local total = GAP * (count - 1)
			for _, entry in list do
				total += use(entry.height) :: number
			end
			return total
		end
		return (use(list[count].height) :: number) + PEEK * math.min(count - 1, BEHIND_SHOWN)
	end)

	local host = scope:New("Frame")({
		Name = "SnackbarHost",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, -24),
		Size = scope:Computed(function(use)
			return UDim2.fromOffset(width, use(stackHeight))
		end),
		ZIndex = p.ZIndex or 180,
	}) :: Frame

	Layer.mount(scope, p, host)

	local order = 0
	local hostAlive = true
	local ticking: RBXScriptConnection? = nil
	local leftAt: number? = nil

	local function stopTicking()
		if ticking then
			ticking:Disconnect()
			ticking = nil
		end
	end
	table.insert(scope, function()
		hostAlive = false
		stopTicking()
	end)

	--- Each frame while there are toasts: open the stack under the pointer, and count the
	--- timers down unless it is open.
	local function tick(dt: number)
		local list = peek(entries) :: { Entry }
		if #list == 0 then
			stopTicking()
			spread:set(false)
			return
		end
		local mouse = ScrollInput.mouseLocation()
		local origin, extent = host.AbsolutePosition, host.AbsoluteSize
		local inside = mouse.X >= origin.X - HOVER_MARGIN
			and mouse.X <= origin.X + extent.X + HOVER_MARGIN
			and mouse.Y >= origin.Y - HOVER_MARGIN
			and mouse.Y <= origin.Y + extent.Y + HOVER_MARGIN
		if inside then
			leftAt = nil
			if not peek(spread) then
				spread:set(true)
			end
		elseif peek(spread) then
			local now = os.clock()
			leftAt = leftAt or now
			if now - (leftAt :: number) > LEAVE_DELAY then
				spread:set(false)
				leftAt = nil
			end
		end
		if not peek(spread) then
			for _, entry in table.clone(list) do
				entry.remaining -= dt
				if entry.remaining <= 0 then
					entry.dismiss()
				end
			end
		end
	end

	local function show(
		message: string,
		actionText: string?,
		onAction: (() -> ())?,
		options: ShowOptions?
	): () -> ()
		if not hostAlive then
			return function() end
		end
		local opts: ShowOptions = options or {}
		order += 1
		local position = order
		local inner = scope:innerScope()
		local alive = true
		-- Inner scopes are destroyed exactly once: by us after the exit, or by the host's
		-- scope. Track which, so a late timer never cleans a scope that's already gone.
		local innerDead = false
		table.insert(inner, function()
			innerDead = true
		end)

		local shown = inner:Value(0)
		local progress = Motion.spring(inner, shown, theme, "Bouncy")
		local height = inner:Value(56)
		local entry: Entry = {
			dismiss = function() end,
			height = height,
			remaining = opts.Duration or DEFAULT_DURATION,
		}

		local function dismiss()
			if not alive then
				return
			end
			alive = false
			local list = table.clone(peek(entries)) :: { Entry }
			local at = table.find(list, entry)
			if at then
				table.remove(list, at)
				entries:set(list)
			end
			if not innerDead then
				shown:set(0)
			end
			task.delay(EXIT_TIME, function()
				if not innerDead then
					Fusion.doCleanup(inner)
				end
			end)
		end
		entry.dismiss = dismiss

		local function build(slot: Slot?): Instance?
			if slot == nil then
				return nil
			end
			if typeof(slot) == "function" then
				return (slot :: any)(inner, dismiss)
			end
			return slot :: Instance
		end

		local card = Snackbar(inner, {
			Theme = theme,
			Message = message,
			ActionText = actionText,
			Fill = true,
			Icon = opts.Icon,
			Leading = build(opts.Leading),
			Trailing = build(opts.Trailing),
			Dismissible = opts.Dismissible,
			OnClose = function()
				if opts.OnClose then
					opts.OnClose()
				end
				dismiss()
			end,
			OnAction = function()
				if onAction then
					onAction()
				end
			end,
		}) :: Frame
		table.insert(
			inner,
			card:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				if card.AbsoluteSize.Y > 0 then
					height:set(card.AbsoluteSize.Y)
				end
			end)
		)

		-- Where this toast sits now: how far up, how narrow, and how much it is covered. A toast
		-- that has left the list keeps its last place while it fades out.
		local last = { rise = 0, narrow = 0, veil = 0, behind = 0 }
		local layout = inner:Computed(function(use)
			local list = use(entries) :: { Entry }
			local at = table.find(list, entry)
			if at == nil then
				return last
			end
			local count = #list
			local behind = count - at -- 0 for the newest
			local rise, narrow, veil = 0, 0, 0
			if use(spread) then
				for index = at + 1, count do
					rise += (use(list[index].height) :: number) + GAP
				end
			else
				rise = behind * PEEK
				narrow = behind * SHRINK
				veil = if behind > 0 then 1 else 0
			end
			local result = { rise = rise, narrow = narrow, veil = veil, behind = behind }
			last = result
			return result
		end)
		local speed, damping = theme.Motion.SpringSpeed, theme.Motion.SpringDamping
		local rise = inner:Spring(
			inner:Computed(function(use)
				return (use(layout) :: any).rise
			end),
			speed,
			damping
		)
		local narrow = inner:Spring(
			inner:Computed(function(use)
				return (use(layout) :: any).narrow
			end),
			speed,
			damping
		)
		local veil = inner:Spring(
			inner:Computed(function(use)
				return (use(layout) :: any).veil
			end),
			speed,
			damping
		)
		-- Toasts further back than BEHIND_SHOWN fade away while the stack is closed.
		local presence = inner:Spring(
			inner:Computed(function(use)
				local info = use(layout) :: any
				return if not use(spread) and info.behind > BEHIND_SHOWN then 0 else 1
			end),
			speed,
			damping
		)

		-- Plain frame + GroupFade (not a CanvasGroup): a CanvasGroup would clip the card's
		-- shadow. GroupFade fades the card, its text, button and shadow together.
		local fade = inner:New("Frame")({
			Name = "Fade",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			[Children] = {
				card,
				-- The card's colour over its contents hides the text of a toast that is behind
				-- another, and leaves the shape.
				inner:New("Frame")({
					Name = "Veil",
					BackgroundColor3 = theme.Colors.InverseSurface,
					BackgroundTransparency = inner:Computed(function(use)
						return 1 - math.clamp(use(veil) :: number, 0, 1)
					end),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 200,
					Active = false,
					[Children] = {
						inner:New("UICorner")({
							CornerRadius = UDim.new(0, theme.Metrics.RadiusPanel),
						}),
					},
				}),
			} :: any,
		})
		GroupFade.bind(
			inner,
			fade,
			inner:Computed(function(use)
				return (use(progress) :: number) * (use(presence) :: number)
			end)
		)

		inner:New("Frame")({
			Name = "Toast",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 1),
			Position = inner:Computed(function(use)
				local offset = -(use(rise) :: number) + (1 - (use(progress) :: number)) * SLIDE
				return UDim2.new(0.5, 0, 1, offset)
			end),
			Size = inner:Computed(function(use)
				return UDim2.new(1 - math.clamp(use(narrow) :: number, 0, 0.5), 0, 0, 0)
			end),
			AutomaticSize = Enum.AutomaticSize.Y,
			ZIndex = position,
			Parent = host,
			[Children] = { fade },
		})

		local list = table.clone(peek(entries)) :: { Entry }
		table.insert(list, entry)
		entries:set(list)

		task.defer(function()
			if alive and not innerDead then
				shown:set(1)
			end
		end)

		-- Drop the oldest toasts past the cap.
		while #peek(entries) > maxVisible do
			(peek(entries) :: { Entry })[1].dismiss()
		end

		if ticking == nil then
			ticking = RunService.Heartbeat:Connect(tick)
		end
		return dismiss
	end

	return {
		Instance = host,
		Show = show,
		Clear = function()
			for _, e in table.clone(peek(entries)) :: { Entry } do
				e.dismiss()
			end
		end,
	}
end
