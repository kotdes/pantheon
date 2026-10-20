--!strict
--[[
	Panes separated by draggable dividers. See docs/Components/Layout/SplitPane.md.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Focus = require(script.Parent.Parent.Internal.Focus)
local ScrollInput = require(script.Parent.Parent.Internal.ScrollInput)

local Children = Fusion.Children
local peek = Fusion.peek

local KEY_STEP = 0.02 -- fraction a divider moves per arrow key press
local DOUBLE_CLICK = 0.35 -- seconds between presses that reset the divider

local function normalised(ratios: { number }?, count: number): { number }
	local out: { number } = {}
	local sum = 0
	for index = 1, count do
		local value = if ratios and ratios[index] and ratios[index] > 0 then ratios[index] else 1
		out[index] = value
		sum += value
	end
	for index = 1, count do
		out[index] /= sum
	end
	return out
end

local function sameRatios(a: { number }, b: { number }): boolean
	if #a ~= #b then
		return false
	end
	for index, value in a do
		if math.abs(value - b[index]) > 1e-6 then
			return false
		end
	end
	return true
end

return function(scope: Types.Scope, props: Types.SplitPaneProps): Instance
	local theme = resolveTheme(props)
	local panes = props.Panes
	local count = #panes
	local horizontal = props.Orientation ~= "Vertical" -- panes side by side
	local dividerSize = props.DividerSize or 8
	local minPanel = props.MinSize or 80

	local initial = normalised(peek(props.Ratios), count)
	local persistKey = Persist.key("SplitPane", typeof(props.Ratios) == "table")
	local ratios = Persist.value(scope, persistKey, "ratios", initial)
	Bind.link(scope, props.Ratios, ratios, {
		toInternal = function(value: { number })
			return normalised(value, count)
		end,
		equals = sameRatios,
	})

	local holders: { Frame } = {}
	local dividers: { TextButton } = {}
	local lines: { Frame } = {}
	local active = scope:Value(0) -- index of the divider being dragged, or 0

	local container = scope:New("Frame")({
		Name = "SplitPane",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Size = props.Size or UDim2.fromScale(1, 1),
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
	}) :: Frame

	local function along(size: Vector2): number
		return if horizontal then size.X else size.Y
	end

	--- Place the panes and dividers for the current size and ratios.
	local function layout()
		local size = container.AbsoluteSize
		local total = math.max(along(size) - dividerSize * (count - 1), 1)
		local list = peek(ratios) :: { number }
		local cursor = 0
		for index = 1, count do
			local extent = list[index] * total
			local holder = holders[index]
			if horizontal then
				holder.Position = UDim2.fromOffset(cursor, 0)
				holder.Size = UDim2.new(0, extent, 1, 0)
			else
				holder.Position = UDim2.fromOffset(0, cursor)
				holder.Size = UDim2.new(1, 0, 0, extent)
			end
			cursor += extent
			local divider = dividers[index]
			if divider then
				if horizontal then
					divider.Position = UDim2.fromOffset(cursor, 0)
					divider.Size = UDim2.new(0, dividerSize, 1, 0)
				else
					divider.Position = UDim2.fromOffset(0, cursor)
					divider.Size = UDim2.new(1, 0, 0, dividerSize)
				end
				cursor += dividerSize
			end
		end
	end

	local function setRatios(list: { number })
		if sameRatios(list, peek(ratios)) then
			return
		end
		ratios:set(list)
		layout()
		if props.OnResized then
			props.OnResized(list)
		end
	end

	--- Move divider `index` by `delta` as a fraction of the room for panes, keeping both
	--- neighbours at least `MinSize` px.
	local function nudge(index: number, from: { number }, delta: number)
		local total = math.max(along(container.AbsoluteSize) - dividerSize * (count - 1), 1)
		local floor = math.min(minPanel / total, 0.45)
		local moved = math.clamp(delta, floor - from[index], from[index + 1] - floor)
		local list = table.clone(from)
		list[index] = from[index] + moved
		list[index + 1] = from[index + 1] - moved
		setRatios(list)
	end

	for index = 1, count do
		local holder = scope:New("Frame")({
			Name = `Pane{index}`,
			BackgroundTransparency = 1,
			ClipsDescendants = true,
		}) :: Frame
		holders[index] = holder
		local pane = scope:Apply(panes[index])({ Parent = holder })
		if pane:IsA("GuiObject") then
			local gui = pane :: GuiObject
			gui.Size = UDim2.fromScale(1, 1)
			gui.Position = UDim2.fromScale(0, 0)
		end
		holder.Parent = container
	end

	for index = 1, count - 1 do
		local ix = Interaction.bind(scope, theme, {})
		local line = scope:New("Frame")({
			Name = "Line",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = if horizontal then UDim2.new(0, 1, 1, 0) else UDim2.new(1, 0, 0, 1),
			BorderSizePixel = 0,
			BackgroundColor3 = scope:Computed(function(use)
				local pulled =
					math.max(use(ix.Hover) :: number, if use(active) == index then 1 else 0)
				return Interaction.lerpColor(
					use(theme.Colors.OutlineVariant),
					use(theme.Colors.Primary),
					pulled,
					use
				)
			end),
		}) :: Frame
		lines[index] = line
		local lastPress = 0
		local divider = scope:New("TextButton")({
			Name = `Divider{index}`,
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 5,
			[Children] = line,
		}) :: TextButton
		ix.wire(divider)
		divider.Parent = container
		dividers[index] = divider

		table.insert(
			scope,
			divider.InputBegan:Connect(function(input: InputObject)
				if
					input.UserInputType ~= Enum.UserInputType.MouseButton1
					and input.UserInputType ~= Enum.UserInputType.Touch
				then
					return
				end
				-- A quick second press puts the panes back to their starting sizes.
				local now = os.clock()
				if now - lastPress < DOUBLE_CLICK then
					lastPress = 0
					setRatios(initial)
					return
				end
				lastPress = now
				local origin = peek(ratios) :: { number }
				local startAt = if horizontal then input.Position.X else input.Position.Y
				active:set(index)
				ScrollInput.capture(divider, function(changed: InputObject)
					return changed.UserInputType == Enum.UserInputType.MouseMovement
						or changed.UserInputType == Enum.UserInputType.Touch
				end, function(ended: InputObject)
					return ended.UserInputType == Enum.UserInputType.MouseButton1
						or ended.UserInputType == Enum.UserInputType.Touch
				end, function(position: Vector3)
					local at = if horizontal then position.X else position.Y
					local total =
						math.max(along(container.AbsoluteSize) - dividerSize * (count - 1), 1)
					nudge(index, origin, (at - startAt) / total)
				end, function()
					active:set(0)
				end)
			end)
		)

		-- Arrow keys move a focused divider.
		Focus.onKey(divider, function(input: InputObject): boolean
			local back = if horizontal then Enum.KeyCode.Left else Enum.KeyCode.Up
			local forward = if horizontal then Enum.KeyCode.Right else Enum.KeyCode.Down
			if input.KeyCode == back then
				nudge(index, peek(ratios), -KEY_STEP)
				return true
			elseif input.KeyCode == forward then
				nudge(index, peek(ratios), KEY_STEP)
				return true
			end
			return false
		end)
	end

	table.insert(scope, container:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout))
	table.insert(
		scope,
		scope:Observer(ratios):onChange(function()
			layout()
		end)
	)
	task.defer(layout)
	return container
end
