--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local CanvasFade = require(script.Parent.Parent.Internal.CanvasFade)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Follow = require(script.Parent.Parent.Internal.Follow)
local place = require(script.Parent.Parent.Internal.Placement)

local Children = Fusion.Children
local GuiService = game:GetService("GuiService")

return function(scope: Types.Scope, props: Types.TooltipProps): Instance
	local theme = resolveTheme(props)
	local visible = scope:Value(0)
	local visibleS = scope:Spring(visible, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
	local placement: Types.TooltipPlacement = props.Placement or "Auto"
	local gap = props.Gap or 8

	local tip = scope:New("Frame")({
		Name = "Tooltip",
		BackgroundColor3 = theme.Colors.SurfaceContainerHigh,
		AutomaticSize = Enum.AutomaticSize.XY,
		Visible = CanvasFade.shown(scope, visibleS, nil, { Theme = theme }),
		BackgroundTransparency = CanvasFade.surfaceTransparency(scope, visibleS, { Theme = theme }),
		ZIndex = props.ZIndex or 160,
		[Children] = {
			scope:New("UICorner")({ CornerRadius = UDim.new(0, theme.Metrics.RadiusSm) }),
			scope:New("UIPadding")({
				PaddingTop = UDim.new(0, theme.Metrics.SpaceXs),
				PaddingBottom = UDim.new(0, theme.Metrics.SpaceXs),
				PaddingLeft = UDim.new(0, theme.Metrics.SpaceSm),
				PaddingRight = UDim.new(0, theme.Metrics.SpaceSm),
			}),
			scope:New("UIStroke")({
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = theme.Colors.Outline,
				Thickness = 1,
			}),
			scope:New("TextLabel")({
				BackgroundTransparency = 1,
				FontFace = theme.Typography.Label.Font,
				TextSize = theme.Typography.Label.Size,
				TextColor3 = theme.Colors.OnSurface,
				Text = props.Text,
				AutomaticSize = Enum.AutomaticSize.XY,
			}),
		},
	}) :: Frame

	local host = CanvasFade.host(scope, tip, visibleS, { Theme = theme })
	Layer.mount(scope, props, host)

	local function updatePosition()
		local target = Layer.asGui(props.Target)
		if target == nil then
			return
		end
		local layer = Layer.resolve(props)
		local abs = target.AbsolutePosition
		local size = target.AbsoluteSize
		if layer then
			-- Place and clamp in the layer's own space, so inside a Window the tip stays
			-- within the window rather than only within the screen.
			local origin = layer.AbsolutePosition
			local pos, _ = place(
				placement,
				Vector2.new(abs.X - origin.X, abs.Y - origin.Y),
				size,
				host.AbsoluteSize,
				gap,
				layer.AbsoluteSize
			)
			host.Position = pos
		else
			local inset = GuiService:GetGuiInset()
			local camera = workspace.CurrentCamera
			local viewport = if camera then camera.ViewportSize else Vector2.new(1920, 1080)
			local pos, _ = place(
				placement,
				Vector2.new(abs.X, abs.Y),
				size,
				host.AbsoluteSize,
				gap,
				viewport - inset
			)
			host.Position = pos
		end
	end

	local hoverTarget = Layer.asGui(props.Target)
	if hoverTarget then
		table.insert(
			scope,
			hoverTarget.MouseEnter:Connect(function()
				if props.Enabled ~= nil and not Fusion.peek(props.Enabled) then
					return
				end
				visible:set(1)
				task.defer(updatePosition)
			end)
		)
		table.insert(
			scope,
			hoverTarget.MouseLeave:Connect(function()
				visible:set(0)
			end)
		)
		Follow(scope, visible, function(v)
			return v > 0.5
		end, updatePosition)
	end

	return host
end
