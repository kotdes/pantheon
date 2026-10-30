--!strict
--[[
	iOS-style UISegmentedControl: traveling selection pill with stretch.
	Indicator is measured against the segments host (no padding double-count).
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local Defaults = require(script.Parent.Parent.Internal.Defaults)
local Motion = require(script.Parent.Parent.Internal.Motion)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Focus = require(script.Parent.Parent.Internal.Focus)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local ScrollInput = require(script.Parent.Parent.Internal.ScrollInput)
local Icon = require(script.Parent.Icon)
local P = require(script.Parent.Parent.Internal.props)
local UserInputService = game:GetService("UserInputService")

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local INSET = 3

return function(scope: Types.Scope, props: Types.SegmentedControlProps): Instance
	local theme = resolveTheme(props)
	local outlined = Defaults.outlined(theme, "SegmentedControl", props.Outlined)
	local disabled = peek(props.Disabled) == true
	local initialId = peek(props.Selected) or (props.Items[1] and props.Items[1].Id) or ""
	local selected = Persist.value(
		scope,
		Persist.key("SegmentedControl", typeof(props.Selected) == "table"),
		"selected",
		initialId
	)
	Bind.link(scope, props.Selected, selected)

	local indicatorX = scope:Value(0)
	local indicatorW = scope:Value(0)
	local stretch = scope:Value(0)
	local stretchS = Motion.spring(scope, stretch, theme, "Snappy", 1.55)
	local xS = Motion.spring(scope, indicatorX, theme, "Snappy", 0.8)
	local wS = Motion.spring(scope, indicatorW, theme, "Snappy", 0.8)
	local dragging = scope:Value(0)
	local draggingS =
		scope:Spring(dragging, theme.Motion.SpringSpeed, theme.Motion.SpringDamping * 0.8)

	local segments: { TextButton } = {}
	local host: Frame

	local function syncIndicator(animateStretch: boolean?)
		local id = peek(selected)
		local idx = 1
		for i, item in props.Items do
			if item.Id == id then
				idx = i
				break
			end
		end
		local seg = segments[idx]
		if not seg or not host or host.Parent == nil then
			return
		end
		-- Measure in host space (the indicator is a child of host, no UIPadding here)
		local relX = seg.AbsolutePosition.X - host.AbsolutePosition.X
		local w = seg.AbsoluteSize.X
		if w < 1 then
			return
		end
		if animateStretch then
			local travel = math.abs(relX - peek(indicatorX))
			stretch:set(math.clamp(travel * 0.3, 6, 32))
			task.delay(0.12, function()
				stretch:set(0)
			end)
		end
		indicatorX:set(relX)
		indicatorW:set(w)
	end

	local function nearestId(absX: number): string
		local best = (props.Items[1] and props.Items[1].Id) or peek(selected)
		local bestDist = math.huge
		for i, seg in segments do
			local cx = seg.AbsolutePosition.X + seg.AbsoluteSize.X * 0.5
			local dist = math.abs(absX - cx)
			if dist < bestDist then
				bestDist = dist
				best = props.Items[i].Id
			end
		end
		return best
	end

	local function selectId(id: string, animateStretch: boolean)
		if id == "" then
			return
		end
		local prev = peek(selected)
		if prev ~= id then
			selected:set(id)
			if props.OnChanged then
				props.OnChanged(id)
			end
		end
		task.defer(function()
			syncIndicator(animateStretch and prev ~= id)
		end)
	end

	local function beginPointer(startId: string, input: InputObject)
		if disabled then
			return
		end
		if ScrollInput.findPluginGui(host) ~= nil then
			return
		end
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		local startX = input.Position.X
		local lastX = startX
		local dragged = false
		local grab = peek(indicatorW) * 0.5
		local cancelCapture: (() -> ())? = nil
		local endedConn: RBXScriptConnection? = nil
		local focusConn: RBXScriptConnection? = nil
		local function clearDrag(finalize: boolean)
			if endedConn then
				endedConn:Disconnect()
				endedConn = nil
			end
			if focusConn then
				focusConn:Disconnect()
				focusConn = nil
			end
			if cancelCapture then
				cancelCapture()
				cancelCapture = nil
			end
			dragging:set(0)
			stretch:set(0)
			if finalize then
				if dragged then
					selectId(nearestId(lastX), true)
				else
					selectId(startId, true)
				end
			end
		end
		cancelCapture = ScrollInput.capture(host, function(changed)
			return changed.UserInputType == Enum.UserInputType.MouseMovement
				or changed.UserInputType == Enum.UserInputType.Touch
		end, function(endedInput)
			return endedInput.UserInputType == Enum.UserInputType.MouseButton1
				or endedInput.UserInputType == Enum.UserInputType.Touch
		end, function(pos)
			lastX = pos.X
			if not dragged and math.abs(pos.X - startX) < 8 then
				return
			end
			dragged = true
			dragging:set(1)
			local rel = pos.X - host.AbsolutePosition.X - grab
			local maxX = math.max(host.AbsoluteSize.X - peek(indicatorW), 0)
			indicatorX:set(math.clamp(rel, 0, maxX))
		end, function()
			clearDrag(true)
		end)
		endedConn = UserInputService.InputEnded:Connect(function(endedInput)
			if
				endedInput.UserInputType == Enum.UserInputType.MouseButton1
				or endedInput.UserInputType == Enum.UserInputType.Touch
			then
				clearDrag(true)
			end
		end)
		focusConn = UserInputService.WindowFocusReleased:Connect(function()
			clearDrag(false)
		end)
		table.insert(scope, function()
			clearDrag(false)
		end)
	end

	for i, item in props.Items do
		local isOn = scope:Computed(function(use)
			return use(selected) == item.Id
		end)
		local selectedS = Motion.spring(
			scope,
			scope:Computed(function(use)
				return if use(isOn) then 1 else 0
			end),
			theme,
			"Snappy"
		)

		local ix = Interaction.bind(scope, theme, {
			Disabled = disabled,
			StateColor = theme.Colors.OnSurface,
		})

		local kids: { any } = {}
		if item.Icon then
			table.insert(
				kids,
				scope:Apply(Icon(scope, {
					Theme = theme,
					Name = item.Icon,
					IconSize = theme.Metrics.IconSm,
					Color = scope:Computed(function(use)
						return Interaction.lerpColor(
							use(theme.Colors.OnSurfaceVariant),
							use(theme.Colors.Primary),
							use(selectedS),
							use
						)
					end),
				}))({
					LayoutOrder = 1,
				})
			)
		end
		table.insert(
			kids,
			scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Label.Font,
				TextSize = theme.Typography.Label.Size,
				Text = item.Label,
				TextColor3 = scope:Computed(function(use)
					return Interaction.lerpColor(
						use(theme.Colors.OnSurfaceVariant),
						use(theme.Colors.Primary),
						use(selectedS),
						use
					)
				end),
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
			})
		)

		local hoverT = ix.fillTransparency(1)
		local seg = scope:TextButton(P({
			Name = "Segment_" .. item.Id,
			Text = "",
			AutoButtonColor = false,
			Active = not disabled,
			-- Hover pill on inactive segments; selected fill comes from traveling indicator
			BackgroundColor3 = theme.Colors.OnSurface,
			BackgroundTransparency = scope:Computed(function(use)
				if use(isOn) then
					return 1
				end
				return use(hoverT)
			end),
			Size = UDim2.new(1, 0, 1, 0),
			LayoutOrder = i,
			ZIndex = 2,
			ClipsDescendants = true,
			CornerRadius = theme.Metrics.RadiusPill,
			Padding = { theme.Metrics.Space2xs, theme.Metrics.SpaceXs },
			Layout = {
				Kind = "List",
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = 4,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			[OnEvent("Activated")] = function()
				if disabled or peek(dragging) > 0.5 then
					return
				end
				selectId(item.Id, true)
			end,
			[Children] = kids,
		})) :: TextButton

		local flex = Instance.new("UIFlexItem")
		flex.FlexMode = Enum.UIFlexMode.Fill
		flex.Parent = seg
		ix.wire(seg)
		-- Left and right arrows move to the neighbouring segment.
		Focus.onKey(seg, function(input: InputObject): boolean
			local step = if input.KeyCode == Enum.KeyCode.Left
				then -1
				elseif input.KeyCode == Enum.KeyCode.Right then 1
				else 0
			local neighbour = props.Items[i + step]
			if step == 0 or neighbour == nil or disabled then
				return step ~= 0
			end
			selectId(neighbour.Id, true)
			if segments[i + step] then
				Focus.select(segments[i + step])
			end
			return true
		end)
		table.insert(segments, seg)
		table.insert(
			scope,
			seg.InputBegan:Connect(function(input)
				beginPointer(item.Id, input)
			end)
		)
	end

	host = scope:Frame({
		Name = "SegmentsHost",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		[Children] = {
			scope:Frame({
				Name = "Indicator",
				BackgroundTransparency = 1,
				ZIndex = scope:Computed(function(use)
					return if use(draggingS) > 0.2 then 3 else 1
				end),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = scope:Computed(function(use)
					local extra = (use(stretchS) :: number) + (use(draggingS) :: number) * 10
					local x = (
						if (use(draggingS) :: number) > 0.45 then use(indicatorX) else use(xS)
					) :: number
					return UDim2.new(0, x - extra * 0.5, 0.5, 0)
				end),
				Size = scope:Computed(function(use)
					local lift = use(draggingS) :: number
					local extra = (use(stretchS) :: number) + lift * 10
					return UDim2.new(0, math.max((use(wS) :: number) + extra, 8), 1, lift * 10)
				end),
				[Children] = {
					scope:Frame({
						Name = "Pill",
						BackgroundColor3 = theme.Colors.Surface,
						BackgroundTransparency = scope:Computed(function(use)
							return 0 + (use(draggingS) :: number) * 0.4
						end),
						Size = UDim2.fromScale(1, 1),
						ZIndex = 1,
						CornerRadius = theme.Metrics.RadiusPill,
						Shadow = {
							BlurRadius = scope:Computed(function(use)
								return (use(draggingS) :: number) * 8
							end),
							Transparency = scope:Computed(function(use)
								return 1 - (use(draggingS) :: number) * 0.2
							end),
						},
						Outline = if outlined
							then {
								Color = theme.Colors.Outline,
								Thickness = scope:Computed(function(use)
									return 2 - (use(draggingS) :: number) * 2
								end),
								Transparency = scope:Computed(function(use)
									return (use(draggingS) :: number) * 0.1
								end),
								Mode = Enum.ApplyStrokeMode.Border,
							}
							else nil,
					}),
				},
			}),
			scope:Frame({
				Name = "Segments",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = 2,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = segments,
			}),
		},
	}) :: Frame

	local track = scope:Frame({
		Name = "SegmentedControl",
		BackgroundColor3 = theme.Colors.OnSurfaceVariant,
		BackgroundTransparency = 0.9,
		Size = props.Size or UDim2.new(1, 0, 0, 36),
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		ClipsDescendants = false,
		CornerRadius = theme.Metrics.RadiusPill,
		Padding = { INSET, INSET },
		[Children] = { host },
	}) :: Frame

	table.insert(
		scope,
		host:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			syncIndicator(false)
		end)
	)
	for _, seg in segments do
		table.insert(
			scope,
			seg:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				syncIndicator(false)
			end)
		)
	end
	task.defer(function()
		syncIndicator(false)
		task.delay(0.05, function()
			syncIndicator(false)
		end)
	end)

	return track
end
