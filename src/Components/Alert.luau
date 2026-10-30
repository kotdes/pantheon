--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Corners = require(script.Parent.Parent.Internal.Corners)

local Children = Fusion.Children

local function toneColors(theme: Types.Theme, tone: Types.AlertTone): (Color3, Color3)
	if tone == "Success" then
		return theme.Colors.Success, theme.Colors.OnSuccess
	elseif tone == "Warning" then
		return theme.Colors.Warning, theme.Colors.OnWarning
	elseif tone == "Error" then
		return theme.Colors.Error, theme.Colors.OnError
	end
	return theme.Colors.Info, theme.Colors.OnInfo
end

return function(scope: Types.Scope, props: Types.AlertProps): Instance
	local theme = resolveTheme(props)
	local tone: Types.AlertTone = props.Tone or "Info"
	local bg, fg = toneColors(theme, tone)
	local alert = scope:Frame({
		Name = "Alert",
		BackgroundColor3 = bg,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		CornerRadius = props.CornerRadius or theme.Metrics.RadiusSm,
		Padding = { theme.Metrics.SpaceSm },
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.Space2xs,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			if props.Title
				then scope:TextLabel({
					BackgroundTransparency = 1,
					FontFace = theme.Fonts.Heading,
					TextSize = theme.Typography.Label.Size,
					TextColor3 = fg,
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = props.Title,
					Size = UDim2.new(1, 0, 0, 18),
					LayoutOrder = 1,
				})
				else nil,
			scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Fonts.Body,
				TextSize = theme.Typography.Caption.Size,
				TextColor3 = fg,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = props.Text,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 2,
			}),
		},
	}) :: Frame
	Corners.auto(alert, props.CornerRadius, theme.Metrics.RadiusSm)
	return alert
end
