--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local Theme = require(script.Parent.Parent.Theme)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Corners = require(script.Parent.Parent.Internal.Corners)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local ListItemStyle = require(script.Parent.Parent.Internal.ListItemStyle)
local P = require(script.Parent.Parent.Internal.props)
local Icon = require(script.Parent.Icon)
local AppSheet = require(script.Parent.AppSheet)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local function fill(instance: Instance)
	local flex = Instance.new("UIFlexItem")
	flex.FlexMode = Enum.UIFlexMode.Fill
	flex.Parent = instance
end

return function(scope: Types.Scope, props: Types.ListItemProps): Instance
	local theme = resolveTheme(props)
	local themeRef = props.Theme or Theme.useRef()
	local style = ListItemStyle(theme)
	local slot = props.Slot
	local mode = if slot then slot.Mode else nil
	local inline = mode == "Inline"
	local below = props.Below ~= nil or (inline and slot ~= nil and slot.Placement == "Below")
	local fills = inline and slot ~= nil and slot.Fill == true
	local disabled = peek(props.Disabled) == true
	local title = if slot and slot.Title ~= nil then slot.Title else props.Title
	local iconColumn = style.IconSize + style.Gap

	local speed, damping = theme.Motion.SpringSpeed, theme.Motion.SpringDamping
	local open = scope:Value(slot ~= nil and peek(slot.Open :: any) == true)
	local opened = scope:Value(peek(open)) -- true once the control has been built
	local function close()
		open:set(false)
	end

	local ownTheme = function(build: (any) -> Instance, inner: any): Instance
		local made: Instance
		Theme.Provide(themeRef, function()
			made = build(inner)
		end)
		return made
	end

	local clickable = not disabled and (props.OnClick ~= nil or (mode ~= nil and mode ~= "Inline"))
	local ix = Interaction.bind(scope, theme, {
		Disabled = not clickable,
		StateColor = theme.Colors.OnSurface,
	})

	-- Text
	local wrap = props.Wrap == true
	local function line(text: any, font: Font, size: number, colour: any, order: number): Instance
		return scope:TextLabel({
			BackgroundTransparency = 1,
			FontFace = font,
			TextSize = size,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = colour,
			Text = text,
			TextWrapped = wrap,
			-- A title that is too long ends in an ellipsis, so it does not run under the end of the row.
			TextTruncate = if wrap then Enum.TextTruncate.None else Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, 0, 0, size),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = order,
		})
	end
	local texts: { any } = {
		line(props.Title, style.TitleFont, style.TitleSize, theme.Colors.OnSurface, 1),
	}
	if props.Subtitle ~= nil then
		table.insert(
			texts,
			line(
				props.Subtitle,
				style.SubtitleFont,
				style.SubtitleSize,
				theme.Colors.OnSurfaceVariant,
				2
			)
		)
	end
	local textColumn = scope:Frame({
		Name = "Text",
		BackgroundTransparency = 1,
		Size = if props.TitleWidth
			then UDim2.fromOffset(props.TitleWidth, 0)
			else UDim2.new(1, 0, 1, 0),
		AutomaticSize = if props.TitleWidth
				or below
				or wrap
			then Enum.AutomaticSize.Y
			else Enum.AutomaticSize.None,
		LayoutOrder = 2,
		Layout = {
			Kind = "List",
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = texts,
	})
	if not props.TitleWidth then
		fill(textColumn)
	end

	-- The row: the start, the text, the end
	local top: { any } = {}
	if props.Leading then
		table.insert(top, scope:Apply(props.Leading)({ LayoutOrder = 1 }))
	elseif props.Icon then
		table.insert(
			top,
			scope:Frame({
				Name = "IconSlot",
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(style.IconSize, style.IconSize),
				LayoutOrder = 1,
				Layout = { Kind = "List", VerticalAlignment = Enum.VerticalAlignment.Center },
				[Children] = {
					Icon(scope, {
						Theme = theme,
						Name = props.Icon,
						IconSize = style.IconSize,
						Color = theme.Colors.OnSurfaceVariant,
					}),
				},
			})
		)
	end
	table.insert(top, textColumn)

	local progress = scope:Spring(
		scope:Computed(function(use)
			return if use(open) then 1 else 0
		end),
		speed,
		damping
	)

	local function chevron(name: string): any
		local icon = Icon(scope, {
			Theme = theme,
			Name = name,
			IconSize = 18,
			Color = theme.Colors.OnSurfaceVariant,
		})
		if mode == "Accordion" then
			return scope:Apply(icon)({
				Rotation = scope:Computed(function(use)
					return 180 * math.clamp(use(progress) :: number, 0, 1)
				end),
			})
		end
		return icon
	end

	local ends: { any } = {}
	if props.Trailing then
		table.insert(ends, scope:Apply(props.Trailing)({ LayoutOrder = 1 }))
	end
	local slotInstance: Instance? = nil
	if inline and slot then
		slotInstance = slot.Build(scope, close)
		if slotInstance and not below then
			if fills then
				(slotInstance :: any).LayoutOrder = 3
				fill(slotInstance)
				table.insert(top, slotInstance)
			else
				table.insert(ends, scope:Apply(slotInstance)({ LayoutOrder = 2 }))
			end
		end
	elseif slot then
		if slot.Display then
			table.insert(ends, scope:Apply(slot.Display)({ LayoutOrder = 2 }))
		end
		table.insert(ends, chevron(if mode == "Accordion" then "chevron-down" else "chevron-right"))
	end
	if props.Chevron then
		table.insert(ends, chevron("chevron-right"))
	end
	for index, item in ends do
		(item :: any).LayoutOrder = index
	end
	if #ends > 0 then
		table.insert(
			top,
			scope:Frame({
				Name = "End",
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 4,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = style.Gap,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = ends,
			})
		)
	end

	local parts: { any } = {
		scope:Frame({
			Name = "Top",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = 1,
			Layout = {
				Kind = "List",
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = style.Gap,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			[Children] = top,
		}),
	}
	local underText = props.Below or (if below then slotInstance else nil)
	if underText then
		table.insert(
			parts,
			scope:Frame({
				Name = "Below",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 2,
				Padding = {
					0,
					0,
					0,
					if props.Icon or props.Leading then iconColumn else 0,
				},
				[Children] = { underText },
			})
		)
	end

	local function activate()
		if props.OnClick then
			props.OnClick()
		end
		if mode == "Accordion" then
			opened:set(true)
			open:set(not peek(open))
		elseif mode == "Prompt" then
			open:set(true)
		elseif mode == "Page" and slot then
			if props.OnPage then
				props.OnPage(title, slot.Build)
			else
				open:set(true)
			end
		end
	end

	local height = if props.Subtitle ~= nil then style.HeightWithSubtitle else style.Height
	local row = scope:TextButton(P({
		Name = "ListItem",
		AutoButtonColor = false,
		Active = not disabled,
		BackgroundColor3 = ix.fill(theme.Colors.Surface),
		BorderSizePixel = 0,
		Size = props.Size or UDim2.new(1, 0, 0, height),
		AutomaticSize = if wrap or below then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,
		Text = "",
		LayoutOrder = if mode == "Accordion" then 1 else props.LayoutOrder or 0,
		Visible = if mode == "Accordion" then nil else props.Visible,
		ZIndex = props.ZIndex,
		CornerRadius = props.CornerRadius or style.Radius,
		Padding = { style.PaddingY, style.PaddingX },
		Layout = {
			Kind = "List",
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = style.Gap,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[OnEvent("Activated")] = if clickable then activate else nil,
		[Children] = parts,
	})) :: TextButton

	ix.wire(row)
	Corners.auto(row, props.CornerRadius, style.Radius)

	if slot and (mode == "Prompt" or (mode == "Page" and props.OnPage == nil)) then
		AppSheet(scope, {
			Theme = theme,
			Layer = props.Layer,
			Open = open,
			Title = title,
			Detent = slot.Detent or 0.7,
			OnClose = close,
			Children = {
				scope:Computed(function(use, inner)
					if not use(open) then
						return nil
					end
					return ownTheme(function(here)
						return slot.Build(here, close)
					end, inner)
				end),
			},
		})
	end

	if mode ~= "Accordion" or not slot then
		return row
	end

	local natural = scope:Value(0)
	local content = scope:Frame({
		Name = "AccordionContent",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Padding = { style.PaddingY, style.PaddingX },
		[Children] = {
			scope:Computed(function(use, inner)
				if not use(opened) then
					return nil
				end
				return ownTheme(function(here)
					return slot.Build(here, close)
				end, inner)
			end),
		},
	}) :: Frame
	table.insert(
		scope,
		content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			natural:set(content.AbsoluteSize.Y)
		end)
	)
	task.defer(function()
		natural:set(content.AbsoluteSize.Y)
	end)

	local body = scope:Frame({
		Name = "AccordionBody",
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		LayoutOrder = 2,
		Size = scope:Computed(function(use)
			local grow = math.clamp(use(progress) :: number, 0, 1)
			return UDim2.new(1, 0, 0, math.floor(use(natural) * grow + 0.5))
		end),
		Visible = scope:Computed(function(use)
			return use(open) or (use(progress) :: number) > 0.01
		end),
		[Children] = { content },
	})

	return scope:Frame({
		Name = "ListItemAccordion",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Layout = { Kind = "List", SortOrder = Enum.SortOrder.LayoutOrder },
		[Children] = { row, body },
	})
end
