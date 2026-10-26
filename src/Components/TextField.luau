--!strict
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

local Children = Fusion.Children
local peek = Fusion.peek
local UserInputService = game:GetService("UserInputService")
local Validators = require(script.Parent.Parent.Internal.Validators)
local Icon = require(script.Parent.Icon)

return function(scope: Types.Scope, props: Types.TextFieldProps): Instance
	local theme = resolveTheme(props)
	local validationError = scope:Value(nil :: string?)
	local errText = scope:Computed(function(use)
		local live = props.Error
		local fromProp = if live == nil
			then nil
			else (if typeof(live) == "table" then use(live) else live)
		if fromProp ~= nil and fromProp ~= "" then
			return fromProp
		end
		return use(validationError)
	end)
	local hasError = scope:Computed(function(use)
		local e = use(errText)
		return e ~= nil and e ~= ""
	end)
	-- Typed text survives a rebuild when the app provides a Persist store (unless the text is
	-- controlled from outside).
	local persistKey = Persist.key("TextField", typeof(props.Text) == "table")
	local persistedText = if persistKey
		then Persist.value(scope, persistKey, "text", props.Text or "")
		else nil
	local disabled = peek(props.Disabled) == true
	local multiline = props.Multiline == true
	local minLines = props.MinLines or (if multiline then 3 else 1)
	local maxLines = props.MaxLines or (if multiline then 12 else 1)
	local lineH = theme.Typography.Body.Size * theme.Typography.Body.LineHeight
	local resize: Types.TextFieldResize = props.Resize or (if multiline then "Y" else "None")
	local focused = scope:Value(0)
	local focusS = scope:Spring(focused, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)

	local minH = minLines * lineH + theme.Metrics.SpaceSm * 2
	local maxH = maxLines * lineH + theme.Metrics.SpaceSm * 2
	-- `Compact` is the small in-widget variant (number boxes, hex fields).
	local compact = props.Compact == true
	local height =
		scope:Value(if multiline then minH else (props.Height or (if compact then 28 else 40)))

	local strokeColor = scope:Computed(function(use)
		local t = use(focusS)
		if use(hasError) then
			return use(theme.Colors.Error)
		end
		return Interaction.lerpColor(use(theme.Colors.Outline), use(theme.Colors.Primary), t, use)
	end)
	local strokeThickness = scope:Computed(function(use)
		return 1 + use(focusS)
	end)

	local padH = if compact then 8 else theme.Metrics.SpaceMd
	local padV = if compact then 2 else theme.Metrics.SpaceSm
	local padL = if props.LeadingIcon then 36 elseif props.Prefix then padH + 14 else padH
	local padR = if props.TrailingIcon then 36 else padH

	local box = scope:TextBox({
		Name = "Input",
		ClearTextOnFocus = false,
		FontFace = theme.Typography.Body.Font,
		TextSize = if compact then 13 else theme.Typography.Body.Size,
		Text = if persistedText then peek(persistedText) else (props.Text or ""),
		PlaceholderText = props.Placeholder or "",
		TextColor3 = theme.Colors.OnSurface,
		PlaceholderColor3 = theme.Colors.OnSurfaceVariant,
		BackgroundColor3 = theme.Colors.SurfaceContainer,
		Size = scope:Computed(function(use)
			return UDim2.new(1, 0, 0, use(height))
		end),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = if multiline then Enum.TextYAlignment.Top else Enum.TextYAlignment.Center,
		MultiLine = multiline,
		TextWrapped = multiline,
		TextEditable = not disabled,
		LayoutOrder = 1,
		-- ClipsDescendants would cut the outline stroke.
		ClipsDescendants = false,
		CornerRadius = props.CornerRadius
			or if props.Pill then theme.Metrics.RadiusPill else theme.Metrics.RadiusSm,
		Padding = { padV, padR, padV, padL },
		Outline = {
			Color = strokeColor,
			Thickness = strokeThickness,
			Mode = Enum.ApplyStrokeMode.Border,
		},
	}) :: TextBox
	if not props.Pill then
		Corners.auto(box, props.CornerRadius, theme.Metrics.RadiusSm)
	end
	Focus.manage(box, theme, true)

	local function runValidation()
		if props.Validators == nil then
			return
		end
		local ok, msg = Validators.run(props.Validators, box.Text)
		validationError:set(if ok then nil else msg)
	end

	table.insert(
		scope,
		box.Focused:Connect(function()
			focused:set(1)
		end)
	)
	table.insert(
		scope,
		box.FocusLost:Connect(function()
			focused:set(0)
			if props.ValidateOnBlur ~= false then
				runValidation()
			end
			if props.OnSubmit then
				props.OnSubmit(box.Text, box)
			end
		end)
	)

	if persistedText then
		table.insert(
			scope,
			box:GetPropertyChangedSignal("Text"):Connect(function()
				persistedText:set(box.Text)
			end)
		)
	end

	-- A Value passed as `Text` follows what the user types.
	if Bind.isWritable(props.Text) then
		table.insert(
			scope,
			box:GetPropertyChangedSignal("Text"):Connect(function()
				if peek(props.Text) ~= box.Text then
					(props.Text :: any):set(box.Text)
				end
			end)
		)
	end

	if props.OnChanged then
		table.insert(
			scope,
			box:GetPropertyChangedSignal("Text"):Connect(function()
				(props.OnChanged :: any)(box.Text)
			end)
		)
	end

	local adornments: { any } = {}
	if props.LeadingIcon then
		table.insert(
			adornments,
			scope:Apply(Icon(scope, {
				Theme = theme,
				Name = props.LeadingIcon,
				IconSize = 18,
				Color = theme.Colors.OnSurfaceVariant,
			}))({
				Position = scope:Computed(function(use)
					return UDim2.new(0, 10, 0, math.floor((use(height) - 18) / 2))
				end),
				ZIndex = 2,
			})
		)
	end
	if props.TrailingIcon then
		table.insert(
			adornments,
			scope:Apply(Icon(scope, {
				Theme = theme,
				Name = props.TrailingIcon,
				IconSize = 18,
				Color = theme.Colors.OnSurfaceVariant,
			}))({
				AnchorPoint = Vector2.new(1, 0),
				Position = scope:Computed(function(use)
					return UDim2.new(1, -10, 0, math.floor((use(height) - 18) / 2))
				end),
				ZIndex = 2,
			})
		)
	end

	if props.Prefix then
		table.insert(
			adornments,
			scope:TextLabel({
				Name = "Prefix",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, padH, 0.5, 0),
				Size = UDim2.fromOffset(14, 20),
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = theme.Fonts.Body,
				TextSize = if compact then 13 else theme.Typography.Body.Size,
				TextColor3 = theme.Colors.OnSurfaceVariant,
				Text = props.Prefix,
				ZIndex = 2,
			})
		)
	end

	local inputWrapKids: { any } = { box }
	for _, a in adornments do
		table.insert(inputWrapKids, a)
	end

	if resize ~= "None" and multiline then
		local handle = scope:TextButton({
			Name = "ResizeHandle",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(16, 16),
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -2, 1, -2),
			ZIndex = 5,
			[Children] = {
				-- MD-style corner grip (two diagonal ticks)
				scope:Frame({
					BackgroundColor3 = theme.Colors.OnSurfaceVariant,
					BackgroundTransparency = 0.35,
					Size = UDim2.fromOffset(10, 2),
					Rotation = -45,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.55, 0.55),
					BorderSizePixel = 0,
				}),
				scope:Frame({
					BackgroundColor3 = theme.Colors.OnSurfaceVariant,
					BackgroundTransparency = 0.5,
					Size = UDim2.fromOffset(6, 2),
					Rotation = -45,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.7, 0.7),
					BorderSizePixel = 0,
				}),
			},
		}) :: TextButton

		table.insert(
			scope,
			handle.InputBegan:Connect(function(input: InputObject)
				if
					input.UserInputType ~= Enum.UserInputType.MouseButton1
					and input.UserInputType ~= Enum.UserInputType.Touch
				then
					return
				end
				local start = input.Position
				local startH = peek(height)
				local startW = box.AbsoluteSize.X
				local move = UserInputService.InputChanged:Connect(function(changed: InputObject)
					if
						changed.UserInputType ~= Enum.UserInputType.MouseMovement
						and changed.UserInputType ~= Enum.UserInputType.Touch
					then
						return
					end
					local dy = changed.Position.Y - start.Y
					local dx = changed.Position.X - start.X
					if resize == "Y" or resize == "Both" then
						height:set(math.clamp(startH + dy, minH, maxH))
					end
					if resize == "X" or resize == "Both" then
						local parent = box.Parent
						if parent and parent:IsA("GuiObject") then
							local newW = math.max(120, startW + dx)
							parent.Size = UDim2.new(0, newW, 0, parent.AbsoluteSize.Y)
						end
					end
				end)
				local ended
				ended = UserInputService.InputEnded:Connect(function(endedInput)
					if
						endedInput.UserInputType == Enum.UserInputType.MouseButton1
						or endedInput.UserInputType == Enum.UserInputType.Touch
					then
						move:Disconnect()
						ended:Disconnect()
					end
				end)
				table.insert(scope, move)
				table.insert(scope, ended)
			end)
		)
		table.insert(inputWrapKids, handle)
	end

	local field = scope:Frame({
		Name = "Field",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		[Children] = inputWrapKids,
	})

	local children = {}
	if props.Label then
		table.insert(
			children,
			scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Label.Font,
				TextSize = theme.Typography.Label.Size,
				TextColor3 = scope:Computed(function(use)
					return if use(hasError)
						then use(theme.Colors.Error)
						else use(theme.Colors.OnSurfaceVariant)
				end),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = props.Label,
				Size = UDim2.new(1, 0, 0, 16),
				LayoutOrder = 1,
			})
		)
	end
	table.insert(children, field)
	table.insert(
		children,
		scope:TextLabel({
			BackgroundTransparency = 1,
			FontFace = theme.Typography.Label.Font,
			TextSize = A.size(theme, 11),
			TextColor3 = scope:Computed(function(use)
				return if use(hasError)
					then use(theme.Colors.Error)
					else use(theme.Colors.OnSurfaceVariant)
			end),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = scope:Computed(function(use)
				local e = use(errText)
				if e and e ~= "" then
					return e
				end
				return props.Helper or ""
			end),
			Visible = scope:Computed(function(use)
				local e = use(errText)
				return (e ~= nil and e ~= "") or (props.Helper ~= nil)
			end),
			Size = UDim2.new(1, 0, 0, 14),
			LayoutOrder = 3,
		})
	)

	return scope:Frame({
		Name = "TextField",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.Space2xs,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = children,
	}) :: Frame
end
