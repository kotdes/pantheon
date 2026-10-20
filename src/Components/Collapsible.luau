--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Icon = require(script.Parent.Icon)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.CollapsibleProps): Instance
	local theme = resolveTheme(props)
	local open = Persist.value(
		scope,
		Persist.key("Collapsible", typeof(props.Open) == "table"),
		"open",
		peek(props.Open) == true
	)
	Bind.link(scope, props.Open, open)
	local openS = scope:Spring(
		scope:Computed(function(use)
			return if use(open) then 1 else 0
		end),
		theme.Motion.SpringSpeed * 0.95,
		theme.Motion.SpringDamping
	)
	local contentHeight = scope:Value(0)
	local ix = Interaction.bind(scope, theme, {
		StateColor = theme.Colors.OnSurface,
	})

	local header = scope:TextButton(P({
		Name = "Header",
		Text = "",
		AutoButtonColor = false,
		BackgroundColor3 = ix.fill(theme.Colors.SurfaceContainer),
		Size = UDim2.new(1, 0, 0, 44),
		LayoutOrder = 1,
		ClipsDescendants = false,
		CornerRadius = theme.Metrics.RadiusSm,
		Padding = { theme.Metrics.SpaceXs, theme.Metrics.SpaceMd },
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = theme.Metrics.SpaceSm,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[OnEvent("Activated")] = function()
			local nextOpen = not peek(open)
			open:set(nextOpen)
			if props.OnChanged then
				props.OnChanged(nextOpen)
			end
		end,
		[Children] = {
			-- Host is the UIListLayout child; rotate an inner frame (layout ignores Rotation on its children).
			scope:New("Frame")({
				Name = "ChevronHost",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(20, 20),
				LayoutOrder = 1,
				[Children] = {
					scope:New("Frame")({
						Name = "ChevronRot",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.fromScale(1, 1),
						Rotation = scope:Computed(function(use)
							return (use(openS) :: number) * 90
						end),
						[Children] = {
							scope:Apply(Icon(scope, {
								Theme = theme,
								Name = "chevron-right",
								IconSize = 18,
								Color = theme.Colors.OnSurfaceVariant,
							}))({
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
							}),
						},
					}),
				},
			}),
			scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Title.Font,
				TextSize = 15,
				TextColor3 = theme.Colors.OnSurface,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = props.Title,
				Size = UDim2.new(1, 0, 1, 0),
				LayoutOrder = 2,
			}),
		},
	})) :: TextButton
	ix.wire(header)

	local titleLabel = header:FindFirstChildWhichIsA("TextLabel")
	if titleLabel then
		local flex = Instance.new("UIFlexItem")
		flex.FlexMode = Enum.UIFlexMode.Fill
		flex.Parent = titleLabel
	end

	local inner = scope:Frame({
		Name = "Inner",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		[Children] = {
			scope:New("UIPadding")({
				PaddingTop = UDim.new(0, theme.Metrics.SpaceXs),
				PaddingBottom = UDim.new(0, theme.Metrics.SpaceSm),
				PaddingLeft = UDim.new(0, theme.Metrics.SpaceMd),
				PaddingRight = UDim.new(0, theme.Metrics.SpaceMd),
			}),
			scope:New("UIScale")({
				Scale = scope:Computed(function(use)
					return 0.96 + 0.04 * use(openS)
				end),
			}),
			props.Children,
		},
	})

	local function syncHeight()
		local h = inner.AbsoluteSize.Y
		if h > 0 and math.abs(h - peek(contentHeight)) > 0.5 then
			contentHeight:set(h)
		end
	end
	table.insert(scope, inner:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncHeight))
	task.defer(syncHeight)

	local body = scope:Frame({
		Name = "Body",
		BackgroundTransparency = 1,
		Size = scope:Computed(function(use)
			return UDim2.new(1, 0, 0, (use(openS) :: number) * (use(contentHeight) :: number))
		end),
		Visible = scope:Computed(function(use)
			return use(openS) > 0.01
		end),
		ClipsDescendants = true,
		LayoutOrder = 2,
		[Children] = { inner },
	})

	return scope:Frame({
		Name = "Collapsible",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.Space2xs,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = { header, body },
	}) :: Frame
end
