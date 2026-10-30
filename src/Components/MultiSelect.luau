--!strict
--[[
	Multi-select dropdown: chips (default) or "N selected" summary.
	Menu items built once to avoid Interaction leaks.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local Defaults = require(script.Parent.Parent.Internal.Defaults)
local Motion = require(script.Parent.Parent.Internal.Motion)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Focus = require(script.Parent.Parent.Internal.Focus)
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local CanvasFade = require(script.Parent.Parent.Internal.CanvasFade)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Follow = require(script.Parent.Parent.Internal.Follow)
local Icon = require(script.Parent.Icon)
local Chip = require(script.Parent.Chip)
local Validators = require(script.Parent.Parent.Internal.Validators)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local function copyList(list: { string }): { string }
	local out = {}
	for _, v in list do
		table.insert(out, v)
	end
	return out
end

local function contains(list: { string }, value: string): boolean
	for _, v in list do
		if v == value then
			return true
		end
	end
	return false
end

local function toggleValue(list: { string }, value: string): { string }
	local out = {}
	local found = false
	for _, v in list do
		if v == value then
			found = true
		else
			table.insert(out, v)
		end
	end
	if not found then
		table.insert(out, value)
	end
	return out
end

local function labelFor(options: { Types.SelectOption }, value: string): string
	for _, opt in options do
		if opt.Value == value then
			return opt.Label
		end
	end
	return value
end

return function(scope: Types.Scope, props: Types.MultiSelectProps): Instance
	local theme = resolveTheme(props)
	local outlined = Defaults.outlined(theme, "MultiSelect", props.Outlined)
	local open = scope:Value(false)
	local openS = Motion.spring(
		scope,
		scope:Computed(function(use)
			return if use(open) then 1 else 0
		end),
		theme,
		"Smooth"
	)
	local selected = Persist.value(
		scope,
		Persist.key("MultiSelect", typeof(props.Value) == "table"),
		"value",
		copyList(peek(props.Value) or {})
	)
	Bind.link(scope, props.Value, selected, {
		toInternal = copyList,
		toProp = copyList,
		equals = Bind.listEquals,
	})
	local errorText = scope:Value(nil :: string?)
	local disabled = peek(props.Disabled) == true
	local hasLabel = props.Label ~= nil
	local displayMode = props.Display or "Chips"
	local closedHeight = (if hasLabel then theme.Metrics.FieldLabelHeight else 0)
		+ theme.Metrics.ControlHeight

	local function commit(nextList: { string })
		selected:set(nextList)
		local ok, err = Validators.run(props.Validators, nextList)
		errorText:set(if ok then nil else err)
		if props.OnChanged then
			props.OnChanged(nextList)
		end
	end

	local menuItems = {}
	for i, opt in props.Options do
		local optValue = opt.Value
		local ix = Interaction.bind(scope, theme, {
			Disabled = disabled,
			StateColor = theme.Colors.OnSurface,
		})
		local isOn = scope:Computed(function(use)
			return contains(use(selected), optValue)
		end)
		local item = scope:TextButton(P({
			Name = "Opt_" .. optValue,
			Text = "",
			AutoButtonColor = false,
			Active = not disabled,
			BackgroundColor3 = scope:Computed(function(use)
				local base = if use(isOn)
					then use(theme.Colors.PrimaryContainer)
					else use(theme.Colors.Surface)
				return Interaction.lerpColor(base, use(theme.Colors.OnSurface), ix.alpha(use), use)
			end),
			Size = UDim2.new(1, 0, 0, 40),
			LayoutOrder = i,
			ClipsDescendants = true,
			CornerRadius = theme.Metrics.RadiusSm - theme.Metrics.Space2xs,
			Padding = { theme.Metrics.SpaceXs, theme.Metrics.SpaceSm },
			Layout = {
				Kind = "List",
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = theme.Metrics.SpaceSm,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			[OnEvent("Activated")] = function()
				commit(toggleValue(peek(selected), optValue))
			end,
			[Children] = {
				scope:TextLabel({
					BackgroundTransparency = 1,
					FontFace = theme.Typography.Body.Font,
					TextSize = theme.Typography.Body.Size,
					TextColor3 = theme.Colors.OnSurface,
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = opt.Label,
					Size = UDim2.new(1, 0, 1, 0),
					LayoutOrder = 1,
				}),
				scope:Apply(Icon(scope, {
					Theme = theme,
					Name = "check",
					IconSize = theme.Metrics.IconMd,
					Color = theme.Colors.Primary,
				}))({
					LayoutOrder = 2,
					Visible = isOn,
				}),
			},
		})) :: TextButton
		local label = item:FindFirstChildWhichIsA("TextLabel")
		if label then
			local flex = Instance.new("UIFlexItem")
			flex.FlexMode = Enum.UIFlexMode.Fill
			flex.Parent = label
		end
		ix.wire(item)
		table.insert(menuItems, item)
	end

	local triggerIx = Interaction.bind(scope, theme, {
		Disabled = disabled,
		StateColor = theme.Colors.OnSurface,
	})

	local selectedMap = scope:Computed(function(use)
		local map: { [string]: string } = {}
		for _, v in use(selected) do
			map[v] = v
		end
		return map
	end)

	local chips = scope:ForPairs(selectedMap, function(_use, chipScope, value: string)
		return value,
			chipScope:Apply(Chip(chipScope, {
				Theme = theme,
				Text = labelFor(props.Options, value),
				Selected = true,
				TrailingIcon = "x",
				Disabled = disabled,
				OnClick = function()
					if disabled then
						return
					end
					commit(toggleValue(peek(selected), value))
				end,
				Size = UDim2.fromOffset(0, 28),
			}))({
				LayoutOrder = 1,
			})
	end)

	local triggerInner: any
	if displayMode == "Count" then
		triggerInner = {
			scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Body.Font,
				TextSize = theme.Typography.Body.Size,
				TextColor3 = theme.Colors.OnSurface,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = scope:Computed(function(use)
					local n = #use(selected)
					if n == 0 then
						return peek(props.Placeholder) or "Select…"
					end
					return `{n} selected`
				end),
				Size = UDim2.new(1, -24, 1, 0),
				LayoutOrder = 1,
			}),
			scope:Apply(Icon(scope, {
				Theme = theme,
				Name = "chevron-down",
				IconSize = theme.Metrics.IconMd,
				Color = theme.Colors.OnSurfaceVariant,
			}))({
				LayoutOrder = 2,
			}),
		}
	else
		triggerInner = {
			scope:Frame({
				Name = "Chips",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -24, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 1,
				ClipsDescendants = true,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = 4,
					Wraps = true,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = {
					scope:TextLabel({
						BackgroundTransparency = 1,
						FontFace = theme.Typography.Body.Font,
						TextSize = theme.Typography.Body.Size,
						TextColor3 = theme.Colors.OnSurfaceVariant,
						Text = props.Placeholder or "Select…",
						AutomaticSize = Enum.AutomaticSize.XY,
						Visible = scope:Computed(function(use)
							return #use(selected) == 0
						end),
						LayoutOrder = 0,
					}),
					chips,
				},
			}),
			scope:Apply(Icon(scope, {
				Theme = theme,
				Name = "chevron-down",
				IconSize = theme.Metrics.IconMd,
				Color = theme.Colors.OnSurfaceVariant,
			}))({
				LayoutOrder = 2,
			}),
		}
	end

	local triggerShell = scope:Frame({
		Name = "Trigger",
		BackgroundColor3 = triggerIx.fill(
			if outlined then theme.Colors.SurfaceContainer else theme.Colors.SurfaceContainerHigh
		),
		Size = UDim2.new(1, 0, 0, if displayMode == "Chips" then 0 else 40),
		AutomaticSize = if displayMode == "Chips"
			then Enum.AutomaticSize.Y
			else Enum.AutomaticSize.None,
		LayoutOrder = 2,
		ClipsDescendants = false,
		CornerRadius = theme.Metrics.RadiusSm,
		Outline = if outlined
			then {
				Color = theme.Colors.Outline,
				Thickness = 1,
				Mode = Enum.ApplyStrokeMode.Border,
			}
			else nil,
		[Children] = {
			scope:TextButton({
				Name = "Hit",
				Text = "",
				AutoButtonColor = false,
				Active = not disabled,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 1,
				[OnEvent("Activated")] = function()
					if not disabled then
						open:set(not peek(open))
					end
				end,
			}),
			scope:Frame({
				Name = "Content",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, if displayMode == "Chips" then 0 else 40),
				AutomaticSize = if displayMode == "Chips"
					then Enum.AutomaticSize.Y
					else Enum.AutomaticSize.None,
				ZIndex = 2,
				Padding = { theme.Metrics.SpaceXs, theme.Metrics.SpaceSm },
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = theme.Metrics.SpaceXs,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = triggerInner,
			}),
		},
	}) :: Frame
	-- Wire hover/press to the shell via the hit target
	do
		local hit = triggerShell:FindFirstChild("Hit")
		if hit and hit:IsA("GuiButton") then
			triggerIx.wire(hit)
		end
	end

	local trigger = triggerShell

	local fieldKids: { any } = {}
	if hasLabel then
		table.insert(
			fieldKids,
			scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Label.Font,
				TextSize = theme.Typography.Label.Size,
				TextColor3 = theme.Colors.OnSurfaceVariant,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = props.Label,
				Size = UDim2.new(1, 0, 0, 16),
				LayoutOrder = 1,
			})
		)
	end
	table.insert(fieldKids, trigger)
	table.insert(
		fieldKids,
		scope:TextLabel({
			BackgroundTransparency = 1,
			FontFace = theme.Typography.Label.Font,
			TextSize = theme.Typography.Label.Size,
			TextColor3 = theme.Colors.Error,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = scope:Computed(function(use)
				return use(errorText) or ""
			end),
			Size = UDim2.new(1, 0, 0, 16),
			Visible = scope:Computed(function(use)
				return use(errorText) ~= nil
			end),
			LayoutOrder = 3,
		})
	)

	local popKids: { any } = {}
	for _, item in menuItems do
		table.insert(popKids, item)
	end

	local popover = scope:Frame({
		Name = "MultiSelectPopover",
		BackgroundColor3 = theme.Colors.Surface,
		Size = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		Visible = CanvasFade.shown(scope, openS, nil, { Theme = theme }),
		BackgroundTransparency = CanvasFade.surfaceTransparency(scope, openS, { Theme = theme }),
		CornerRadius = theme.Metrics.RadiusSm,
		Outline = if outlined
			then {
				Color = theme.Colors.Outline,
				Thickness = 1,
				Mode = Enum.ApplyStrokeMode.Border,
			}
			else nil,
		Padding = { theme.Metrics.Space2xs },
		Layout = {
			Kind = "List",
			Padding = 2,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		SizeConstraint = {
			MinSize = Vector2.new(160, 0),
		},
		Shadow = {
			BlurRadius = 8,
			Transparency = scope:Computed(function(use)
				return 1 - (use(openS) :: number) * 0.1
			end),
		},
		ZIndex = 200,
		[Children] = popKids,
	})

	local field = scope:Frame({
		Name = "MultiSelect",
		BackgroundTransparency = 1,
		ClipsDescendants = false,
		Size = props.Size or UDim2.new(1, 0, 0, closedHeight),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		ZIndex = scope:Computed(function(use)
			local base = props.ZIndex
			local n = if typeof(base) == "number" then base else 1
			return if use(open) then math.max(n, 200) else n
		end),
		[Children] = {
			scope:Frame({
				Name = "Field",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Layout = {
					Kind = "List",
					Padding = 4,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = fieldKids,
			}),
		},
	}) :: Frame

	local chrome = CanvasFade.host(scope, popover, openS, { Theme = theme })
	if chrome ~= popover then
		popover.Size = UDim2.new(1, 0, 0, 0)
		popover.AutomaticSize = Enum.AutomaticSize.Y
	end
	local mounted = Layer.mount(scope, props, chrome)
	if not mounted then
		chrome.Parent = field
		chrome.Size = UDim2.new(1, 0, 0, 0)
		chrome.AutomaticSize = Enum.AutomaticSize.Y
		chrome.Position = UDim2.fromOffset(0, closedHeight + 4)
	else
		Follow(scope, open, function(v)
			return v == true
		end, function()
			local layer = Layer.resolve(props)
			if layer == nil then
				return
			end
			local tp = trigger.AbsolutePosition
			local ts = trigger.AbsoluteSize
			local lp = layer.AbsolutePosition
			chrome.Position = UDim2.fromOffset(tp.X - lp.X, tp.Y - lp.Y + ts.Y + 4)
			chrome.Size = UDim2.fromOffset(math.max(ts.X, 160), 0)
		end)
	end

	Focus.escape(scope, open, function()
		open:set(false)
	end)
	return field
end
