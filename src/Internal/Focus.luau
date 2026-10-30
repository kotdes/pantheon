--!strict
--[[
	Keyboard and gamepad focus.

	Controls that react to input register here (Interaction.wire does it for the buttons). The
	module then gives them:

	  - a focus ring around the control that has focus, drawn by us instead of Roblox's white box;
	  - Tab and Shift+Tab to move between controls, in reading order, once focus is in one of
	    ours (otherwise Tab stays with Roblox, which uses it for the leaderboard);
	  - Enter and Space to activate the focused control;
	  - Escape and gamepad B to close the open overlay;
	  - `trap`, which keeps focus inside a modal while it is open and puts it back afterwards.

	Gamepad focus is Roblox's own `GuiService.SelectedObject`, so the A button already activates
	a focused button. We use the same property for the keyboard.

	Enter and Space need the handler of a control's `Activated` event, and an event can't be
	fired from a script. So the module wraps the `Activated` key of Fusion's `OnEvent` once, and
	remembers the handler given for each instance.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)

local GuiService = game:GetService("GuiService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local peek = Fusion.peek

type Info = { theme: Types.Theme, textBox: boolean }

local Focus = {}

local managed: { [GuiObject]: Info } = setmetatable({}, { __mode = "k" }) :: any
local activations: { [Instance]: (...any) -> () } = setmetatable({}, { __mode = "k" }) :: any
local keyHandlers: { [GuiObject]: (input: InputObject) -> boolean } = setmetatable(
	{},
	{ __mode = "k" }
) :: any
local traps: { { root: GuiObject } } = {}
local escapes: { () -> () } = {}

local started = false
local ring: Frame? = nil
local ringStroke: UIStroke? = nil
local ringCorner: UICorner? = nil
local following: RBXScriptConnection? = nil
local blank: Frame? = nil

-- Fusion hook

--- Remember the handler of every `Activated` event Fusion connects.
local function hookActivated()
	local key = (Fusion.OnEvent :: any)("Activated")
	if key.pantheonHooked then
		return
	end
	key.pantheonHooked = true
	local original = key.apply
	key.apply = function(self: any, scope: any, callback: any, applyTo: Instance)
		if typeof(callback) == "function" then
			activations[applyTo] = callback
		end
		return original(self, scope, callback, applyTo)
	end
end

-- the ring

local function layerOf(gui: Instance): LayerCollector?
	return gui:FindFirstAncestorWhichIsA("LayerCollector")
end

local function hideRing()
	if following then
		following:Disconnect()
		following = nil
	end
	if ring then
		ring.Visible = false
	end
end

local function ensureRing(theme: Types.Theme): Frame
	if ring == nil then
		local frame = Instance.new("Frame")
		frame.Name = "PantheonFocusRing"
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Active = false
		frame.Visible = false
		frame.ZIndex = 10000
		local corner = Instance.new("UICorner")
		corner.Parent = frame
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = frame
		-- The ring lives in whichever screen gui has focus. When that gui is destroyed the ring
		-- goes with it, so make a new one next time.
		frame.Destroying:Connect(function()
			if ring == frame then
				ring, ringStroke, ringCorner = nil, nil, nil
			end
		end)
		ring, ringStroke, ringCorner = frame, stroke, corner
	end
	(ringStroke :: UIStroke).Color = peek(theme.Colors.Primary :: any)
	return ring :: Frame
end

local RING_GAP = 2

--- Like `:focus-visible` on the web: the ring shows when the keyboard or a gamepad moved focus,
--- and not when a pointer or a touch did, or when a dialog took focus on its own.
local function keyboardDriven(): boolean
	local last = UserInputService:GetLastInputType()
	return last == Enum.UserInputType.Keyboard
		or string.find(tostring(last), "Gamepad", 1, true) ~= nil
end

local function showRing(target: GuiObject, info: Info)
	local layer = layerOf(target)
	if layer == nil then
		return hideRing()
	end
	local frame = ensureRing(info.theme)
	frame.Parent = layer
	-- Match the rounding of the control: pills stay pills.
	local sourceCorner = target:FindFirstChildOfClass("UICorner")
	if ringCorner then
		local radius = if sourceCorner then sourceCorner.CornerRadius else UDim.new(0, 8)
		ringCorner.CornerRadius = UDim.new(radius.Scale, radius.Offset + RING_GAP)
	end
	frame.Visible = true
	if following then
		following:Disconnect()
	end
	following = RunService.RenderStepped:Connect(function()
		if target.Parent == nil or not frame.Parent then
			hideRing()
			return
		end
		local origin = (layer :: any).AbsolutePosition :: Vector2
		local at = target.AbsolutePosition - origin
		local size = target.AbsoluteSize
		frame.Position = UDim2.fromOffset(at.X - RING_GAP, at.Y - RING_GAP)
		frame.Size = UDim2.fromOffset(size.X + 2 * RING_GAP, size.Y + 2 * RING_GAP)
	end)
end

local function refreshRing()
	local selected = GuiService.SelectedObject
	local info = if selected and selected:IsA("GuiObject") then managed[selected] else nil
	if selected and info and (info.textBox or keyboardDriven()) then
		showRing(selected :: GuiObject, info)
	else
		hideRing()
	end
end

-- moving focus

local function isShown(gui: GuiObject): boolean
	if not gui:IsDescendantOf(game) then
		return false
	end
	local current: Instance? = gui
	while current and not current:IsA("LayerCollector") do
		if current:IsA("GuiObject") and not current.Visible then
			return false
		end
		current = current.Parent
	end
	return true
end

function Focus.select(gui: GuiObject?)
	-- GuiService only selects inside a PlayerGui. In a plugin widget, such as a story preview, it
	-- raises an error, so there the control only takes a text box's focus.
	if gui == nil or gui:FindFirstAncestorWhichIsA("PlayerGui") ~= nil then
		GuiService.SelectedObject = gui
	end
	if gui and gui:IsA("TextBox") then
		(gui :: TextBox):CaptureFocus()
	end
end

--- Controls that can take focus, in reading order. Inside a trap, only that trap's controls.
local function candidates(): { GuiObject }
	local trap = traps[#traps]
	local list: { GuiObject } = {}
	for gui in managed do
		if isShown(gui) and (trap == nil or gui:IsDescendantOf(trap.root)) then
			table.insert(list, gui)
		end
	end
	table.sort(list, function(a, b)
		local pa, pb = a.AbsolutePosition, b.AbsolutePosition
		if math.abs(pa.Y - pb.Y) > 8 then
			return pa.Y < pb.Y
		end
		return pa.X < pb.X
	end)
	return list
end

local function move(step: number)
	local list = candidates()
	if #list == 0 then
		return
	end
	local current = GuiService.SelectedObject
	local at = if current then table.find(list, current :: any) else nil
	local nextIndex = if at then ((at - 1 + step) % #list) + 1 elseif step > 0 then 1 else #list
	Focus.select(list[nextIndex])
end

local TAB_ACTION = "PantheonFocusTab"

--- Tab belongs to us only while focus is in our controls. Anywhere else it stays with Roblox,
--- which uses it for the leaderboard.
local function ownsTab(): boolean
	local typing = UserInputService:GetFocusedTextBox()
	if typing then
		return managed[typing] ~= nil and typing:GetAttribute("KeepTab") ~= true
	end
	if #traps > 0 then
		return true
	end
	local selected = GuiService.SelectedObject
	return selected ~= nil and managed[selected] ~= nil
end

local function onTab(_: string, state: Enum.UserInputState): Enum.ContextActionResult
	if state ~= Enum.UserInputState.Begin or not ownsTab() then
		return Enum.ContextActionResult.Pass
	end
	local typing = UserInputService:GetFocusedTextBox()
	if typing and typing.MultiLine then
		return Enum.ContextActionResult.Pass
	end
	if typing then
		typing:ReleaseFocus()
	end
	move(if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then -1 else 1)
	return Enum.ContextActionResult.Sink
end

local function onInput(input: InputObject, processed: boolean)
	local code = input.KeyCode
	if code == Enum.KeyCode.Escape or code == Enum.KeyCode.ButtonB then
		local close = escapes[#escapes]
		if close then
			close()
		end
		return
	end
	local typing = UserInputService:GetFocusedTextBox()
	if processed or typing then
		return
	end
	local selected = GuiService.SelectedObject
	if selected == nil or not selected:IsA("GuiObject") or managed[selected] == nil then
		return
	end
	local handler = keyHandlers[selected]
	if handler and handler(input) then
		return
	end
	if code == Enum.KeyCode.Return or code == Enum.KeyCode.Space then
		local activate = activations[selected]
		if activate then
			task.spawn(activate)
		end
	end
end

local function start()
	if started then
		return
	end
	started = true
	hookActivated()
	GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(refreshRing)
	UserInputService.LastInputTypeChanged:Connect(refreshRing)
	UserInputService.InputBegan:Connect(onInput)
	ContextActionService:BindActionAtPriority(
		TAB_ACTION,
		onTab,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.KeyCode.Tab
	)
end

-- public

--- Make `gui` a focusable control. `textBox` is for inputs, which take keyboard focus too.
function Focus.manage(gui: GuiObject, theme: Types.Theme, textBox: boolean?)
	start()
	gui.Selectable = true
	if blank == nil then
		-- Replace Roblox's own selection box; the ring above is drawn instead.
		local frame = Instance.new("Frame")
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Size = UDim2.fromScale(1, 1)
		blank = frame
	end
	gui.SelectionImageObject = blank :: Frame
	managed[gui] = { theme = theme, textBox = textBox == true }
end

--- Handle keys while `gui` has focus. Return `true` from `handler` for a key it used.
function Focus.onKey(gui: GuiObject, handler: (input: InputObject) -> boolean)
	keyHandlers[gui] = handler
end

--- While `open` is true, keep Tab inside `root`: focus moves to its first control when it
--- opens, and goes back to where it was when it closes.
function Focus.trap(scope: Types.Scope, root: GuiObject, open: any)
	start()
	local entry = { root = root }
	local previous: GuiObject? = nil
	local active = false
	local function update()
		local isOpen = (if typeof(open) == "table" then peek(open) else open) == true
		if isOpen and not active then
			active = true
			previous = GuiService.SelectedObject :: any
			table.insert(traps, entry)
			task.defer(function()
				if active then
					local first = candidates()[1]
					if first then
						Focus.select(first)
					end
				end
			end)
		elseif not isOpen and active then
			active = false
			local at = table.find(traps, entry)
			if at then
				table.remove(traps, at)
			end
			local back = previous
			previous = nil
			if back and back.Parent then
				Focus.select(back)
			else
				GuiService.SelectedObject = nil
			end
		end
	end
	if typeof(open) == "table" then
		table.insert(scope, scope:Observer(open):onChange(update))
	end
	update()
	table.insert(scope, function()
		active = false
		local at = table.find(traps, entry)
		if at then
			table.remove(traps, at)
		end
	end)
end

--- While `open` is true, Escape and the gamepad B button call `close`. The most recently
--- opened overlay is the one that closes.
function Focus.escape(scope: Types.Scope, open: any, close: () -> ())
	start()
	local entry = function()
		close()
	end
	local registered = false
	local function update()
		local isOpen = (if typeof(open) == "table" then peek(open) else open) == true
		if isOpen and not registered then
			registered = true
			table.insert(escapes, entry)
		elseif not isOpen and registered then
			registered = false
			local at = table.find(escapes, entry)
			if at then
				table.remove(escapes, at)
			end
		end
	end
	if typeof(open) == "table" then
		table.insert(scope, scope:Observer(open):onChange(update))
	end
	update()
	table.insert(scope, function()
		registered = false
		local at = table.find(escapes, entry)
		if at then
			table.remove(escapes, at)
		end
	end)
end

--- A function that closes an overlay: it calls `OnClose`, or sets a `Value` passed as `Open` to false.
function Focus.closer(props: any): () -> ()
	return function()
		if props.OnClose then
			props.OnClose()
		elseif
			Fusion.peek(props.Open) == true
			and typeof(props.Open) == "table"
			and typeof(props.Open.set) == "function"
		then
			props.Open:set(false)
		end
	end
end

return Focus
