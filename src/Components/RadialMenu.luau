--!strict
--[[
	A ring of choices around the pointer. Point at one and release (or click) to pick it.
	See docs/Components/Overlays/RadialMenu.md.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Focus = require(script.Parent.Parent.Internal.Focus)
local Layer = require(script.Parent.Parent.Internal.Layer)
local ScrollInput = require(script.Parent.Parent.Internal.ScrollInput)
local Icon = require(script.Parent.Icon)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local DEAD_ZONE = 0.32 -- fraction of the radius around the centre where nothing is chosen
local STICK_THRESHOLD = 0.5

return function(scope: Types.Scope, props: Types.RadialMenuProps): Instance
	local theme = resolveTheme(props)
	local items = props.Items
	local count = #items
	local radius = props.Radius or 96
	local itemSize = props.ItemSize or 52
	local persistKey = Persist.key("RadialMenu", true)
	local open = Persist.value(scope, persistKey, "open", peek(props.Open) == true)
	Bind.link(scope, props.Open, open)

	local hovered = scope:Value(0) -- index of the choice the pointer is over, or 0
	local origin = scope:Value(Vector2.zero) -- centre of the ring, in the space of the layer
	local openS = scope:Spring(
		scope:Computed(function(use)
			return if use(open) then 1 else 0
		end),
		theme.Motion.SpringSpeed * 1.2,
		0.65
	)

	local layer = scope:New("TextButton")({
		Name = "RadialMenu",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = theme.Colors.Scrim,
		BackgroundTransparency = scope:Computed(function(use)
			return 1 - 0.35 * math.clamp(use(openS) :: number, 0, 1)
		end),
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = props.ZIndex or 80,
		Active = true,
		Visible = scope:Computed(function(use)
			return (use(openS) :: number) > 0.01
		end),
		LayoutOrder = props.LayoutOrder or 0,
	}) :: TextButton
	local mounted = Layer.mount(scope, props, layer)

	local function choose(index: number)
		local item = items[index]
		if item == nil or peek(item.Disabled) == true then
			return
		end
		open:set(false)
		if item.OnSelect then
			item.OnSelect()
		end
		if props.OnSelect then
			props.OnSelect(item.Id)
		end
	end

	-- the ring
	local ring = scope:New("Frame")({
		Name = "Ring",
		BackgroundColor3 = theme.Colors.Surface,
		BackgroundTransparency = scope:Computed(function(use)
			return 1 - 0.85 * math.clamp(use(openS) :: number, 0, 1)
		end),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = scope:Computed(function(use)
			local at = use(origin) :: Vector2
			return UDim2.fromOffset(at.X, at.Y)
		end),
		Size = scope:Computed(function(use)
			local reach = (radius + itemSize / 2 + 10) * 2 * math.max(use(openS) :: number, 0)
			return UDim2.fromOffset(reach, reach)
		end),
		BorderSizePixel = 0,
		Parent = layer,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
			scope:New("UIStroke")({
				Color = theme.Colors.OutlineVariant,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			}),
		},
	}) :: Frame

	-- The name of the choice under the pointer, in the middle.
	scope:New("TextLabel")({
		Name = "Center",
		Parent = layer,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = ring.Position,
		Size = UDim2.fromOffset(radius * DEAD_ZONE * 2, 40),
		FontFace = theme.Typography.Label.Font,
		TextSize = A.size(theme, 14),
		TextWrapped = true,
		TextColor3 = theme.Colors.OnSurface,
		TextTransparency = scope:Computed(function(use)
			return 1 - math.clamp(use(openS) :: number, 0, 1)
		end),
		Text = scope:Computed(function(use)
			local item = items[use(hovered) :: number]
			return if item then (item.Text or item.Id) else (props.Title or "")
		end),
	})

	local buttons: { GuiObject } = {}
	for index, item in items do
		local angle = math.rad((index - 1) * 360 / count - 90)
		local disabled = peek(item.Disabled) == true
		local ix = Interaction.bind(scope, theme, { Disabled = disabled })
		local isHovered = scope:Computed(function(use)
			return use(hovered) == index
		end)
		-- Each choice springs out from the middle, a little later than the one before it.
		local reach = scope:Spring(
			scope:Computed(function(use)
				return if use(open) then 1 else 0
			end),
			theme.Motion.SpringSpeed * (1.1 - 0.04 * index),
			0.62
		)
		local lift = scope:Spring(
			scope:Computed(function(use)
				return if use(isHovered) and not disabled then 1 else 0
			end),
			theme.Motion.SpringSpeed * 1.4,
			0.7
		)
		local button = scope:New("TextButton")({
			Name = item.Id,
			Text = "",
			AutoButtonColor = false,
			Active = not disabled,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = scope:Computed(function(use)
				local at = use(origin) :: Vector2
				local r = radius * (use(reach) :: number)
				return UDim2.fromOffset(at.X + math.cos(angle) * r, at.Y + math.sin(angle) * r)
			end),
			Size = scope:Computed(function(use)
				local size = itemSize
					* (0.55 + 0.45 * math.clamp(use(reach) :: number, 0, 1.15))
					* (1 + 0.14 * (use(lift) :: number))
				return UDim2.fromOffset(size, size)
			end),
			BackgroundColor3 = scope:Computed(function(use)
				local base = use(theme.Colors.SurfaceContainerHigh)
				return Interaction.lerpColor(
					base,
					use(theme.Colors.Primary),
					math.clamp(use(lift) :: number, 0, 1),
					use
				)
			end),
			BackgroundTransparency = scope:Computed(function(use)
				return 1 - math.clamp(use(reach) :: number, 0, 1) * (if disabled then 0.5 else 1)
			end),
			BorderSizePixel = 0,
			ZIndex = 2,
			Parent = layer,
			[OnEvent("Activated")] = function()
				choose(index)
			end,
			[OnEvent("MouseEnter")] = function()
				hovered:set(index)
			end,
			[Children] = {
				scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
				if item.Icon
					then scope:Apply(Icon(scope, {
						Theme = theme,
						Name = item.Icon,
						IconSize = 22,
						Color = scope:Computed(function(use)
							return Interaction.lerpColor(
								use(theme.Colors.OnSurface),
								use(theme.Colors.OnPrimary),
								math.clamp(use(lift) :: number, 0, 1),
								use
							)
						end),
					}))({
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
					})
					else scope:New("TextLabel")({
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						FontFace = theme.Typography.Label.Font,
						TextSize = A.size(theme, 13),
						TextColor3 = theme.Colors.OnSurface,
						Text = item.Text or item.Id,
					}),
			} :: any,
		}) :: TextButton
		ix.wire(button)
		buttons[index] = button
	end

	-- choosing by direction
	--- Which choice lies in the direction of `offset` from the centre: 0 for none.
	local function choiceAt(offset: Vector2): number
		if offset.Magnitude < radius * DEAD_ZONE then
			return 0
		end
		-- 0 at 12 o'clock, clockwise.
		local angle = math.atan2(offset.X, -offset.Y)
		if angle < 0 then
			angle += 2 * math.pi
		end
		local step = 2 * math.pi / count
		return (math.floor((angle + step / 2) / step) % count) + 1
	end

	local following: RBXScriptConnection? = nil
	local function stopFollowing()
		if following then
			following:Disconnect()
			following = nil
		end
	end
	local function startFollowing()
		stopFollowing()
		following = RunService.RenderStepped:Connect(function()
			-- A thumbstick, when one is pushed, wins over the pointer.
			local stick = Vector2.zero
			for _, input in UserInputService:GetGamepadState(Enum.UserInputType.Gamepad1) do
				if input.KeyCode == Enum.KeyCode.Thumbstick1 then
					stick = Vector2.new(input.Position.X, -input.Position.Y)
				end
			end
			if stick.Magnitude > STICK_THRESHOLD then
				hovered:set(choiceAt(stick.Unit * radius))
				return
			end
			if UserInputService.MouseEnabled or UserInputService.TouchEnabled then
				local parent = layer.Parent
				local base = if parent and parent:IsA("GuiObject")
					then (parent :: GuiObject).AbsolutePosition
					else Vector2.zero
				local pointer = ScrollInput.mouseLocation() - base
				hovered:set(choiceAt(pointer - peek(origin)))
			end
		end)
	end

	table.insert(
		scope,
		scope:Observer(open):onChange(function()
			if peek(open) then
				-- Open where the pointer is, kept far enough from the edges to show the whole ring.
				local parent = layer.Parent
				local box = if parent and parent:IsA("GuiObject")
					then (parent :: GuiObject).AbsoluteSize
					else Vector2.new(800, 600)
				local base = if parent and parent:IsA("GuiObject")
					then (parent :: GuiObject).AbsolutePosition
					else Vector2.zero
				local at = props.Origin or (ScrollInput.mouseLocation() - base)
				local margin = radius + itemSize / 2 + 12
				origin:set(
					Vector2.new(
						math.clamp(at.X, margin, math.max(box.X - margin, margin)),
						math.clamp(at.Y, margin, math.max(box.Y - margin, margin))
					)
				)
				hovered:set(0)
				startFollowing()
			else
				stopFollowing()
			end
		end)
	)
	table.insert(scope, stopFollowing)

	-- A press outside the choices closes the ring, or picks the one under the pointer when it
	-- was opened by a held key.
	table.insert(
		scope,
		layer.Activated:Connect(function()
			if props.Hotkey == nil then
				open:set(false)
				if props.OnClose then
					props.OnClose()
				end
			end
		end)
	)

	if props.Hotkey then
		table.insert(
			scope,
			UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
				if not processed and input.KeyCode == props.Hotkey and not peek(open) then
					open:set(true)
				end
			end)
		)
		table.insert(
			scope,
			UserInputService.InputEnded:Connect(function(input: InputObject)
				if input.KeyCode == props.Hotkey and peek(open) then
					local index = peek(hovered) :: number
					if index > 0 then
						choose(index)
					else
						open:set(false)
						if props.OnClose then
							props.OnClose()
						end
					end
				end
			end)
		)
	end
	-- Gamepad: A picks the highlighted choice.
	table.insert(
		scope,
		UserInputService.InputBegan:Connect(function(input: InputObject)
			if peek(open) and input.KeyCode == Enum.KeyCode.ButtonA then
				local index = peek(hovered) :: number
				if index > 0 then
					choose(index)
				end
			end
		end)
	)
	Focus.escape(scope, open, function()
		open:set(false)
		if props.OnClose then
			props.OnClose()
		end
	end)

	if not mounted then
		warn(
			"[Pantheon.RadialMenu] no overlay Layer found; pass `Layer` or call inside Layer.Provide"
		)
	end
	return layer
end
