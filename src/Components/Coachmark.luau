--!strict
--[[
	Coachmark: "feature discovery" card that points the user at something new.

	A dimmed spotlight (the target stays bright and clickable), a pulsing ring around
	the target, and a card with an arrow that points at it:

		C.Coachmark(scope, {
			Target = saveButton,
			Open = showTip,                 -- Value<boolean> (set false when dismissed)
			Title = "Save your work",
			Text = "Changes sync automatically, but you can save a snapshot here.",
			Step = "1 of 3",                -- optional
			ActionText = "Got it",
			OnClose = function() ... end,
		})

	Mounts on `Layer` (or the ambient overlay layer) so it floats above the layout.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local CanvasFade = require(script.Parent.Parent.Internal.CanvasFade)
local Motion = require(script.Parent.Parent.Internal.Motion)
local Corners = require(script.Parent.Parent.Internal.Corners)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Follow = require(script.Parent.Parent.Internal.Follow)
local place = require(script.Parent.Parent.Internal.Placement)
local Presence = require(script.Parent.Parent.Internal.Presence)

local Children = Fusion.Children
local peek = Fusion.peek

local ARROW = 14 -- px, side of the rotated square
local PULSE_PERIOD = 1.6

--- Moves `position` towards `target` with a spring of the given speed and damping ratio. The
--- step is split so that a long frame cannot make a stiff spring blow up.
local function spring(
	position: number,
	velocity: number,
	target: number,
	speed: number,
	damping: number,
	dt: number
): (number, number)
	local steps = math.max(1, math.ceil(dt * 240))
	local h = dt / steps
	for _ = 1, steps do
		local acceleration = speed * speed * (target - position) - 2 * damping * speed * velocity
		velocity += acceleration * h
		position += velocity * h
	end
	return position, velocity
end

return function(scope: Types.Scope, props: Types.CoachmarkProps): Instance
	local theme = resolveTheme(props)
	local spotlight = props.Spotlight ~= false
	local dim = props.Dim or 0.55
	local pad = props.TargetPadding or 6
	local gap = props.Gap or 16
	local placement: Types.TooltipPlacement = props.Placement or "Auto"
	local tone = props.Tone or "Primary"

	local cardColor = if tone == "Surface"
		then theme.Colors.SurfaceContainerHigh
		else theme.Colors.Primary
	local onCard = if tone == "Surface" then theme.Colors.OnSurface else theme.Colors.OnPrimary
	local accent = if tone == "Surface" then theme.Colors.Primary else theme.Colors.OnPrimary

	-- Open can be a plain boolean or a state we're allowed to close.
	local open: any = props.Open
	if typeof(open) ~= "table" then
		open = scope:Value(open ~= false)
	end
	local openS = Motion.spring(
		scope,
		scope:Computed(function(use)
			return if use(open) then 1 else 0
		end),
		theme,
		"Gentle"
	)

	local function dismiss()
		if open.set then
			open:set(false)
		end
		if props.OnClose then
			props.OnClose()
		end
	end

	-- Scrim: four rects around a hole, so the target stays visible and clickable
	local function scrimRect(name: string)
		return scope:New("TextButton")({
			Name = name,
			AutoButtonColor = false,
			Text = "",
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = scope:Computed(function(use)
				return 1 - (1 - dim) * math.clamp(use(openS) :: number, 0, 1)
			end),
			BorderSizePixel = 0,
			Active = true,
			Visible = spotlight,
			ZIndex = 1,
			[Fusion.OnEvent("Activated")] = function()
				if props.DismissOnScrim then
					dismiss()
				end
			end,
		}) :: TextButton
	end
	local scrimTop, scrimBottom = scrimRect("ScrimTop"), scrimRect("ScrimBottom")
	local scrimLeft, scrimRight = scrimRect("ScrimLeft"), scrimRect("ScrimRight")

	-- Pulsing ring around the target
	local ringStroke = scope:New("UIStroke")({
		Color = if tone == "Surface" then theme.Colors.Primary else Color3.new(1, 1, 1),
		Thickness = 2,
		Transparency = 1,
	}) :: UIStroke
	local ring = scope:New("Frame")({
		Name = "Pulse",
		BackgroundTransparency = 1,
		ZIndex = 2,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(0, theme.Metrics.RadiusSm) }),
			ringStroke,
		},
	}) :: Frame

	-- Card
	-- Changing the target dips the card's text for a moment, so the new text fades in.
	local dip = scope:Value(0)
	local dipS = scope:Spring(dip, theme.Motion.SpringSpeed * 1.5, 1)
	local function label(text: any, size: number, font: Font, transparency: number, order: number)
		return scope:New("TextLabel")({
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromScale(1, 0),
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = font,
			TextSize = size,
			TextColor3 = onCard,
			TextTransparency = scope:Computed(function(use)
				return 1 - (1 - transparency) * (1 - math.clamp(use(dipS) :: number, 0, 1))
			end),
			Text = text,
			LayoutOrder = order,
		})
	end

	local content: { any } = {}
	if props.Step then
		table.insert(content, label(props.Step, 12, theme.Typography.Label.Font, 0.25, 1))
	end
	if props.Title then
		table.insert(content, label(props.Title, 17, theme.Typography.Label.Font, 0, 2))
	end
	if props.Text then
		table.insert(content, label(props.Text, 14, theme.Fonts.Body, 0.1, 3))
	end
	table.insert(
		content,
		scope:New("TextButton")({
			Name = "Action",
			LayoutOrder = 4,
			AutoButtonColor = true,
			BackgroundColor3 = accent,
			BackgroundTransparency = 0.82,
			AutomaticSize = Enum.AutomaticSize.XY,
			Size = UDim2.fromOffset(0, 0),
			FontFace = theme.Typography.Label.Font,
			TextSize = theme.Typography.Label.Size,
			TextColor3 = onCard,
			Text = props.ActionText or "Got it",
			[Fusion.OnEvent("Activated")] = function()
				if props.OnAction then
					props.OnAction()
				end
				if not props.KeepOpen then
					dismiss()
				end
			end,
			[Children] = {
				scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
				scope:New("UIPadding")({
					PaddingTop = UDim.new(0, theme.Metrics.SpaceXs),
					PaddingBottom = UDim.new(0, theme.Metrics.SpaceXs),
					PaddingLeft = UDim.new(0, theme.Metrics.SpaceMd),
					PaddingRight = UDim.new(0, theme.Metrics.SpaceMd),
				}),
			} :: any,
		})
	)

	local arrow = scope:New("Frame")({
		Name = "Arrow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = cardColor,
		BorderSizePixel = 0,
		Rotation = 45,
		Size = UDim2.fromOffset(ARROW, ARROW),
		ZIndex = 3,
		[Children] = { scope:New("UICorner")({ CornerRadius = UDim.new(0, 3) }) },
	}) :: Frame

	local card = scope:New("Frame")({
		Name = "Card",
		BackgroundColor3 = cardColor,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(props.Width or 280, 0),
		ZIndex = 4,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(0, theme.Metrics.RadiusPanel) }),
			scope:New("UIPadding")({
				PaddingTop = UDim.new(0, theme.Metrics.SpaceMd),
				PaddingBottom = UDim.new(0, theme.Metrics.SpaceMd),
				PaddingLeft = UDim.new(0, theme.Metrics.SpaceMd),
				PaddingRight = UDim.new(0, theme.Metrics.SpaceMd),
			}),
			scope:New("UIListLayout")({
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, theme.Metrics.SpaceSm),
			}),
			content,
		},
	}) :: Frame

	-- Card fades and rises in; the arrow stays attached to the card edge.
	local cardHost = CanvasFade.host(scope, card, openS, { Theme = theme })
	cardHost.ZIndex = 4

	local scrimCorner = scope:New("UICorner")({
		CornerRadius = UDim.new(0, props.ScrimRadius or 0),
	}) :: UICorner
	local scrimGroup = scope:New("CanvasGroup")({
		Name = "Scrim",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 1,
		[Children] = {
			scrimCorner,
			scrimTop,
			scrimBottom,
			scrimLeft,
			scrimRight,
		} :: any,
	}) :: CanvasGroup
	if props.ScrimRadius == nil then
		table.insert(
			scope,
			Corners.followWindow(scrimGroup, function(radius: number)
				scrimCorner.CornerRadius = UDim.new(0, radius)
			end)
		)
	end

	local root = scope:New("Frame")({
		Name = "Coachmark",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = props.ZIndex or 150,
		Visible = scope:Computed(function(use)
			return (use(openS) :: number) > 0.01
		end),
		[Children] = {
			scrimGroup,
			ring :: any,
			arrow :: any,
			cardHost :: any,
		},
	}) :: Frame

	local mounted = Layer.mount(scope, props, root)
	if not mounted then
		warn(
			"[Pantheon.Coachmark] no overlay Layer found; pass `Layer` or call inside Layer.Provide"
		)
	end

	local clock = 0
	-- With `FromOrigin` the spotlight and the card move between targets like a liquid: the two
	-- axes and the size each have a spring of their own, so the shape stretches on the way and
	-- settles with a small wobble. Without it they ease towards the target as they always did.
	local liquid = Presence.fromOrigin(theme)
	local shown: {
		X: number,
		Y: number,
		W: number,
		H: number,
		CX: number,
		CY: number,
		VX: number,
		VY: number,
		VW: number,
		VH: number,
		VCX: number,
		VCY: number,
	}? =
		nil
	local lastTarget: GuiObject? = nil

	local function update(dt: number)
		local target = Layer.asGui(peek(props.Target :: any))
		local layer = Layer.resolve(props)
		if target == nil or layer == nil then
			return
		end
		if lastTarget ~= nil and target ~= lastTarget then
			dipS:setPosition(1)
		end
		lastTarget = target
		clock += dt
		local origin = layer.AbsolutePosition
		local W, H = layer.AbsoluteSize.X, layer.AbsoluteSize.Y

		-- Target bounds in layer space, padded.
		local tp = target.AbsolutePosition - origin - Vector2.new(pad, pad)
		local ts = target.AbsoluteSize + Vector2.new(pad * 2, pad * 2)
		local wantX, wantY = math.max(tp.X, 0), math.max(tp.Y, 0)
		local wantW, wantH = math.min(ts.X, W - wantX), math.min(ts.Y, H - wantY)
		local ease = 1 - math.exp(-math.min(dt, 0.1) * 14)
		local step = math.min(dt, 0.05)
		if shown == nil then
			shown = {
				X = wantX,
				Y = wantY,
				W = wantW,
				H = wantH,
				CX = 0,
				CY = 0,
				VX = 0,
				VY = 0,
				VW = 0,
				VH = 0,
				VCX = 0,
				VCY = 0,
			}
		elseif liquid then
			local moveSpeed, moveDamping = Motion.tuning(theme, "LiquidMove")
			local widthSpeed, widthDamping = Motion.tuning(theme, "LiquidWidth")
			local heightSpeed, heightDamping = Motion.tuning(theme, "LiquidHeight")
			shown.X, shown.VX = spring(shown.X, shown.VX, wantX, moveSpeed, moveDamping, step)
			shown.Y, shown.VY =
				spring(shown.Y, shown.VY, wantY, moveSpeed * 0.82, moveDamping, step)
			shown.W, shown.VW = spring(shown.W, shown.VW, wantW, widthSpeed, widthDamping, step)
			shown.H, shown.VH = spring(shown.H, shown.VH, wantH, heightSpeed, heightDamping, step)
			shown.W, shown.H = math.max(shown.W, 0), math.max(shown.H, 0)
		else
			shown.X += (wantX - shown.X) * ease
			shown.Y += (wantY - shown.Y) * ease
			shown.W += (wantW - shown.W) * ease
			shown.H += (wantH - shown.H) * ease
		end
		local tx, ty, tw, th = shown.X, shown.Y, shown.W, shown.H
		tp = Vector2.new(tx, ty)
		ts = Vector2.new(tw, th)

		scrimTop.Position, scrimTop.Size = UDim2.fromOffset(0, 0), UDim2.fromOffset(W, ty)
		scrimBottom.Position = UDim2.fromOffset(0, ty + th)
		scrimBottom.Size = UDim2.fromOffset(W, math.max(H - (ty + th), 0))
		scrimLeft.Position, scrimLeft.Size = UDim2.fromOffset(0, ty), UDim2.fromOffset(tx, th)
		scrimRight.Position = UDim2.fromOffset(tx + tw, ty)
		scrimRight.Size = UDim2.fromOffset(math.max(W - (tx + tw), 0), th)

		-- Pulse: ring grows outward from the target and fades.
		local u = (clock / PULSE_PERIOD) % 1
		local grow = u * 14
		ring.Position = UDim2.fromOffset(tx - grow, ty - grow)
		ring.Size = UDim2.fromOffset(tw + grow * 2, th + grow * 2)
		ringStroke.Transparency = 1 - (1 - u) * 0.9 * math.clamp(peek(openS) :: number, 0, 1)

		-- Card + arrow. Placed and clamped in the layer's own space, so inside a Window the
		-- card stays within the window (not just within the screen).
		local pos, side = place(placement, tp, ts, cardHost.AbsoluteSize, gap, layer.AbsoluteSize)
		local wantCX, wantCY = pos.X.Offset, pos.Y.Offset
		if shown.CX == 0 and shown.CY == 0 then
			shown.CX, shown.CY = wantCX, wantCY
		elseif liquid then
			-- The card follows a little behind the spotlight.
			local moveSpeed, moveDamping = Motion.tuning(theme, "LiquidMove")
			shown.CX, shown.VCX =
				spring(shown.CX, shown.VCX, wantCX, moveSpeed * 0.85, moveDamping, step)
			shown.CY, shown.VCY =
				spring(shown.CY, shown.VCY, wantCY, moveSpeed * 0.7, moveDamping, step)
		else
			shown.CX += (wantCX - shown.CX) * ease
			shown.CY += (wantCY - shown.CY) * ease
		end
		local cx, cy = shown.CX, shown.CY
		local rise = (1 - math.clamp(peek(openS) :: number, 0, 1)) * 10
		cardHost.Position = UDim2.fromOffset(cx, cy + rise)

		-- Arrow sits on the card edge facing the target, aimed at the target's centre.
		local cs = cardHost.AbsoluteSize
		local centreX = math.clamp(tp.X + ts.X / 2 - cx, 18, math.max(cs.X - 18, 18))
		local centreY = math.clamp(tp.Y + ts.Y / 2 - cy, 18, math.max(cs.Y - 18, 18))
		if side == "Bottom" then
			arrow.Position = UDim2.fromOffset(cx + centreX, cy + rise)
		elseif side == "Top" then
			arrow.Position = UDim2.fromOffset(cx + centreX, cy + cs.Y + rise)
		elseif side == "Right" then
			arrow.Position = UDim2.fromOffset(cx, cy + centreY + rise)
		else
			arrow.Position = UDim2.fromOffset(cx + cs.X, cy + centreY + rise)
		end
		arrow.BackgroundTransparency = 1 - math.clamp(peek(openS) :: number, 0, 1)
	end

	Follow(scope, openS, function(v)
		return v > 0.01
	end, update)

	return root
end
