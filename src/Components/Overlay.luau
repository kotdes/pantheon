--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Corners = require(script.Parent.Parent.Internal.Corners)

local OnEvent = Fusion.OnEvent

return function(scope: Types.Scope, props: Types.OverlayProps?): Instance
	local p: Types.OverlayProps = props or {}
	local theme = resolveTheme(p)
	-- Full-screen TextButton scrim. Panels above must also be GuiButtons
	-- (or otherwise sink input); Frame.Active alone does not block Activated.
	local scrim = scope:TextButton({
		Name = "Overlay",
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(0, 0),
		BackgroundColor3 = theme.Colors.Scrim,
		BackgroundTransparency = p.Transparency or 0.35,
		BorderSizePixel = 0,
		Size = p.Size or UDim2.fromScale(1, 1),
		ZIndex = p.ZIndex or 50,
		Visible = p.Visible,
		Active = true,
		CornerRadius = p.CornerRadius or 0,
		[OnEvent("Activated")] = p.OnClick,
	}) :: TextButton

	if p.CornerRadius == nil then
		table.insert(
			scope,
			Corners.followWindow(scrim, function(radius: number)
				Corners.apply(scrim, radius, radius, radius, radius)
			end)
		)
	end

	return scrim
end
