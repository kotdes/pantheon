--!strict
--[[
	ChoiceGroup: SegmentedControl or RadioGroup rows, with Validators + error label.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local Defaults = require(script.Parent.Parent.Internal.Defaults)
local Motion = require(script.Parent.Parent.Internal.Motion)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Validators = require(script.Parent.Parent.Internal.Validators)
local SegmentedControl = require(script.Parent.SegmentedControl)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.ChoiceGroupProps): Instance
	local theme = resolveTheme(props)
	local outlined = Defaults.outlined(theme, "ChoiceGroup", props.Outlined)
	local variant = props.Variant or "Radio"
	local disabled = peek(props.Disabled) == true
	local selected = Persist.value(
		scope,
		Persist.key("ChoiceGroup", typeof(props.Value) == "table"),
		"value",
		peek(props.Value) or (props.Options[1] and props.Options[1].Value) or ""
	)
	Bind.link(scope, props.Value, selected)
	local errorText = scope:Value(nil :: string?)

	local function commit(value: string)
		selected:set(value)
		local ok, err = Validators.run(props.Validators, value)
		errorText:set(if ok then nil else err)
		if props.OnChanged then
			props.OnChanged(value)
		end
	end

	local controlKids: { any } = {}

	if variant == "Segmented" then
		local items = {}
		for _, opt in props.Options do
			table.insert(items, {
				Id = opt.Value,
				Label = opt.Label,
			})
		end
		table.insert(
			controlKids,
			SegmentedControl(scope, {
				Theme = theme,
				Items = items,
				Selected = selected,
				Disabled = disabled,
				LayoutOrder = 2,
				OnChanged = commit,
			})
		)
	else
		local rows = {}
		for i, opt in props.Options do
			local optDisabled = disabled or opt.Disabled == true
			local selectedS = Motion.spring(
				scope,
				scope:Computed(function(use)
					return if use(selected) == opt.Value then 1 else 0
				end),
				theme,
				"Snappy"
			)
			local ix = Interaction.bind(scope, theme, {
				Disabled = optDisabled,
				StateColor = theme.Colors.OnSurface,
			})

			local outer = scope:Frame({
				Size = UDim2.fromOffset(20, 20),
				BackgroundColor3 = scope:Computed(function(use)
					local base = if outlined
						then use(theme.Colors.Surface)
						else Interaction.lerpColor(
							use(theme.Colors.SurfaceContainerHigh),
							use(theme.Colors.Primary),
							use(selectedS),
							use
						)
					return Interaction.lerpColor(
						base,
						use(theme.Colors.OnSurface),
						ix.alpha(use),
						use
					)
				end),
				LayoutOrder = 1,
				CornerRadius = theme.Metrics.RadiusPill,
				Outline = if outlined
					then {
						Color = scope:Computed(function(use)
							return Interaction.lerpColor(
								use(theme.Colors.Outline),
								use(theme.Colors.Primary),
								use(selectedS),
								use
							)
						end),
						Thickness = 2,
						Mode = Enum.ApplyStrokeMode.Border,
					}
					else nil,
				[Children] = {
					scope:Frame({
						Name = "Dot",
						Size = scope:Computed(function(use)
							local s = 10 * use(selectedS)
							return UDim2.fromOffset(s, s)
						end),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						BackgroundColor3 = if outlined
							then theme.Colors.Primary
							else theme.Colors.OnPrimary,
						BackgroundTransparency = scope:Computed(function(use)
							return 1 - use(selectedS)
						end),
						CornerRadius = theme.Metrics.RadiusPill,
					}),
				},
			})

			local row = scope:TextButton(P({
				Name = "Choice_" .. opt.Value,
				Text = "",
				BackgroundColor3 = theme.Colors.OnSurface,
				BackgroundTransparency = ix.fillTransparency(1),
				Size = UDim2.new(1, 0, 0, 40),
				LayoutOrder = i,
				AutoButtonColor = false,
				Active = not optDisabled,
				CornerRadius = theme.Metrics.RadiusSm,
				Padding = { theme.Metrics.Space2xs, theme.Metrics.SpaceXs },
				[OnEvent("Activated")] = function()
					if optDisabled then
						return
					end
					commit(opt.Value)
				end,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = theme.Metrics.SpaceSm,
				},
				[Children] = {
					outer,
					scope:TextLabel({
						BackgroundTransparency = 1,
						FontFace = theme.Typography.Body.Font,
						TextSize = theme.Typography.Body.Size,
						TextColor3 = theme.Colors.OnSurface,
						Text = opt.Label,
						AutomaticSize = Enum.AutomaticSize.XY,
						LayoutOrder = 2,
					}),
				},
			}))
			ix.wire(row)
			table.insert(rows, row)
		end
		table.insert(
			controlKids,
			scope:Frame({
				Name = "RadioRows",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 2,
				Layout = {
					Kind = "List",
					Padding = theme.Metrics.Space2xs,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = rows,
			})
		)
	end

	local kids: { any } = {}
	if props.Label ~= nil then
		table.insert(
			kids,
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
	for _, c in controlKids do
		table.insert(kids, c)
	end
	table.insert(
		kids,
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
			LayoutOrder = 10,
		})
	)

	return scope:Frame({
		Name = "ChoiceGroup",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.SpaceXs,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = kids,
	}) :: Frame
end
