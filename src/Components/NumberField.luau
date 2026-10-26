--!strict
--[[
	Number input with a label that scrubs: drag the label sideways to change the value.
	See docs/Components/Forms/NumberField.md.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Corners = require(script.Parent.Parent.Internal.Corners)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Focus = require(script.Parent.Parent.Internal.Focus)
local ScrollInput = require(script.Parent.Parent.Internal.ScrollInput)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local UserInputService = game:GetService("UserInputService")

local LABEL_WIDTH = 26
local SCRUB_THRESHOLD = 3 -- px before a press on the label counts as a drag

--- Decimal places needed to show a step, so a step of 0.05 shows two.
local function decimalsFor(step: number): number
	local places = 0
	local scaled = step
	while places < 6 and math.abs(scaled - math.floor(scaled + 0.5)) > 1e-9 do
		scaled *= 10
		places += 1
	end
	return places
end

local function snap(value: number, step: number, anchor: number): number
	return anchor + math.floor((value - anchor) / step + 0.5) * step
end

return function(scope: Types.Scope, props: Types.NumberFieldProps): Instance
	local theme = resolveTheme(props)
	local minValue = props.Min or -math.huge
	local maxValue = props.Max or math.huge
	local step = props.Step or 1
	local decimals = props.Decimals or decimalsFor(step)
	local disabled = peek(props.Disabled) == true
	local finiteRange = minValue > -math.huge and maxValue < math.huge

	local function clamp(n: number): number
		return math.clamp(n, minValue, maxValue)
	end
	-- Round to the decimals shown, so 0.1 + 0.2 doesn't leave 0.30000000000000004 in a state.
	local function tidy(n: number): number
		local factor = 10 ^ decimals
		return math.floor(n * factor + 0.5) / factor
	end

	local persistKey = Persist.key("NumberField", typeof(props.Value) == "table")
	local value = Persist.value(scope, persistKey, "value", clamp(peek(props.Value) or 0))
	Bind.link(scope, props.Value, value)

	local function commit(n: number)
		n = tidy(clamp(n))
		if n ~= peek(value) then
			value:set(n)
			if props.OnChanged then
				props.OnChanged(n)
			end
		end
	end

	local function formatted(use: any): string
		return string.format(`%.{decimals}f`, use(value) :: number)
	end

	local focused = scope:Value(0)
	local scrubbing = scope:Value(0)
	local hovered = scope:Value(0)
	local focusS = scope:Spring(focused, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
	local scrubS = scope:Spring(scrubbing, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
	local hoverS = scope:Spring(hovered, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)

	local box: TextBox
	box = scope:New("TextBox")({
		Name = "Input",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		TextEditable = not disabled,
		FontFace = theme.Fonts.Body,
		TextSize = A.size(theme, 14),
		TextColor3 = if disabled then theme.Colors.OnSurfaceVariant else theme.Colors.OnSurface,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = scope:Computed(formatted),
		LayoutOrder = 2,
		Size = UDim2.fromOffset(0, 0),
		[OnEvent("Focused")] = function()
			focused:set(1)
		end,
		[OnEvent("FocusLost")] = function()
			focused:set(0)
			local typed = tonumber(box.Text)
			if typed then
				commit(typed)
			end
			box.Text = string.format(`%.{decimals}f`, peek(value))
		end,
		[Children] = {
			scope:New("UIFlexItem")({ FlexMode = Enum.UIFlexMode.Fill }),
			scope:New("UIPadding")({ PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
		} :: any,
	}) :: TextBox
	box.Size = UDim2.new(0, 0, 1, 0)

	-- Up and Down arrows step the value while the box has focus. Shift is ×10 and Alt ×0.1.
	table.insert(
		scope,
		box.InputBegan:Connect(function(input: InputObject)
			local direction = if input.KeyCode == Enum.KeyCode.Up
				then 1
				elseif input.KeyCode == Enum.KeyCode.Down then -1
				else 0
			if direction == 0 then
				return
			end
			local scale = if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
				then 10
				elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then 0.1
				else 1
			commit((tonumber(box.Text) or peek(value)) + direction * step * scale)
			box.Text = string.format(`%.{decimals}f`, peek(value))
		end)
	)

	-- The label is the scrub handle.
	local ix = Interaction.bind(scope, theme, { Disabled = disabled })
	local label: GuiObject? = nil
	if props.Label then
		local handle = scope:New("TextButton")({
			Name = "Scrub",
			Text = props.Label,
			AutoButtonColor = false,
			Active = not disabled,
			FontFace = theme.Typography.Label.Font,
			TextSize = A.size(theme, 13),
			TextColor3 = scope:Computed(function(use)
				return Interaction.lerpColor(
					use(theme.Colors.OnSurfaceVariant),
					use(theme.Colors.Primary),
					math.clamp((use(scrubS) :: number) + (use(hoverS) :: number) * 0.5, 0, 1),
					use
				)
			end),
			BackgroundColor3 = theme.Colors.SurfaceContainerHigh,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.new(0, LABEL_WIDTH, 1, 0),
			LayoutOrder = 1,
			[OnEvent("MouseEnter")] = function()
				hovered:set(1)
			end,
			[OnEvent("MouseLeave")] = function()
				hovered:set(0)
			end,
			[Children] = {
				scope:New("UICorner")({ CornerRadius = UDim.new(0, theme.Metrics.RadiusSm) }),
			} :: any,
		}) :: TextButton
		ix.wire(handle)
		label = handle

		if not disabled then
			-- Speed: a finite range crosses in about 300 px, otherwise a step per 4 px.
			local perPixel = props.ScrubSpeed
				or (if finiteRange then (maxValue - minValue) / 300 else step / 4)
			table.insert(
				scope,
				handle.InputBegan:Connect(function(input: InputObject)
					if
						input.UserInputType ~= Enum.UserInputType.MouseButton1
						and input.UserInputType ~= Enum.UserInputType.Touch
					then
						return
					end
					local startX = input.Position.X
					local startValue = peek(value) :: number
					local dragged = false
					ScrollInput.capture(handle, function(changed: InputObject)
						return changed.UserInputType == Enum.UserInputType.MouseMovement
							or changed.UserInputType == Enum.UserInputType.Touch
					end, function(ended: InputObject)
						return ended.UserInputType == Enum.UserInputType.MouseButton1
							or ended.UserInputType == Enum.UserInputType.Touch
					end, function(position: Vector3)
						local dx = position.X - startX
						if not dragged and math.abs(dx) < SCRUB_THRESHOLD then
							return
						end
						dragged = true
						scrubbing:set(1)
						local scale = if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
							then 10
							elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then 0.1
							else 1
						commit(
							snap(
								startValue + dx * perPixel * scale,
								step * (if scale < 1 then scale else 1),
								0
							)
						)
					end, function()
						scrubbing:set(0)
						if not dragged then
							box:CaptureFocus()
						end
					end)
				end)
			)
		end
	end

	local strokeColor = scope:Computed(function(use)
		return Interaction.lerpColor(
			use(theme.Colors.Outline),
			use(theme.Colors.Primary),
			use(focusS) :: number,
			use
		)
	end)

	local field = scope:Frame({
		Name = "NumberField",
		BackgroundColor3 = theme.Colors.SurfaceContainer,
		BackgroundTransparency = if disabled then 0.4 else 0,
		Size = props.Size or UDim2.new(1, 0, 0, 32),
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		ClipsDescendants = true,
		CornerRadius = props.CornerRadius or theme.Metrics.RadiusSm,
		Outline = {
			Color = strokeColor,
			Thickness = scope:Computed(function(use)
				return 1 + use(focusS) :: number
			end),
			Mode = Enum.ApplyStrokeMode.Border,
		},
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			label,
			box,
			if props.Suffix
				then scope:New("TextLabel")({
					Name = "Suffix",
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					FontFace = theme.Fonts.Body,
					TextSize = A.size(theme, 13),
					TextColor3 = theme.Colors.OnSurfaceVariant,
					Text = props.Suffix,
					LayoutOrder = 3,
					[Children] = scope:New("UIPadding")({ PaddingRight = UDim.new(0, 8) }),
				})
				else nil,
		} :: any,
	}) :: Frame
	Corners.auto(field, props.CornerRadius, theme.Metrics.RadiusSm)
	Focus.manage(box, theme, true)
	return field
end
