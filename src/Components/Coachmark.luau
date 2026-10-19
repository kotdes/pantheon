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
local Layer = require(script.Parent.Parent.Internal.Layer)
local Follow = require(script.Parent.Parent.Internal.Follow)
local place = require(script.Parent.Parent.Internal.Placement)

local Children = Fusion.Children
local peek = Fusion.peek

local ARROW = 14 -- px, side of the rotated square
local PULSE_PERIOD = 1.6

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
	local openS = scope:Spring(
		scope:Computed(function(use)
			return if use(open) then 1 else 0
		end),
		theme.Motion.SpringSpeed,
		theme.Motion.SpringDamping
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
	local function label(
		text: string,
		size: number,
		font: Font,
		transparency: number,
		order: number
	)
		return scope:New("TextLabel")({
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.fromScale(1, 0),
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = font,
			TextSize = size,
			TextColor3 = onCard,
			TextTransparency = transparency,
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
			TextSize = 14,
			TextColor3 = onCard,
			Text = props.ActionText or "Got it",
			[Fusion.OnEvent("Activated")] = function()
				if props.OnAction then
					props.OnAction()
				end
				dismiss()
			end,
			[Children] = {
				scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
				scope:New("UIPadding")({
					PaddingTop = UDim.new(0, 6),
					PaddingBottom = UDim.new(0, 6),
					PaddingLeft = UDim.new(0, 14),
					PaddingRight = UDim.new(0, 14),
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

	local root = scope:New("Frame")({
		Name = "Coachmark",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = props.ZIndex or 150,
		Visible = scope:Computed(function(use)
			return (use(openS) :: number) > 0.01
		end),
		[Children] = {
			scrimTop,
			scrimBottom,
			scrimLeft,
			scrimRight,
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

	local function update(dt: number)
		local target = Layer.asGui(props.Target)
		local layer = Layer.resolve(props)
		if target == nil or layer == nil then
			return
		end
		clock += dt
		local origin = layer.AbsolutePosition
		local W, H = layer.AbsoluteSize.X, layer.AbsoluteSize.Y

		-- Target bounds in layer space, padded.
		local tp = target.AbsolutePosition - origin - Vector2.new(pad, pad)
		local ts = target.AbsoluteSize + Vector2.new(pad * 2, pad * 2)
		local tx, ty = math.max(tp.X, 0), math.max(tp.Y, 0)
		local tw, th = math.min(ts.X, W - tx), math.min(ts.Y, H - ty)

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
		local cx, cy = pos.X.Offset, pos.Y.Offset
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
