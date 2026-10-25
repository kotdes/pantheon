--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme

local Children = Fusion.Children

export type FormProps = {
	Theme: Types.ThemeRef?,
	LayoutOrder: Types.UsedAs<number>?,
	Size: Types.UsedAs<UDim2>?,
	Visible: Types.UsedAs<boolean>?,
	ZIndex: Types.UsedAs<number>?,
	Layer: Instance?,
	Children: any?,
	Title: Types.UsedAs<string>?,
	[string]: any,
}

return function(scope: Types.Scope, props: FormProps): Instance
	local theme = resolveTheme(props)
	return scope:Frame({
		Name = "Form",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.SpaceMd,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			if props.Title
				then scope:TextLabel({
					BackgroundTransparency = 1,
					FontFace = theme.Fonts.Heading,
					TextSize = A.size(theme, 16),
					TextColor3 = theme.Colors.OnSurface,
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = props.Title,
					Size = UDim2.new(1, 0, 0, 22),
					LayoutOrder = 0,
				})
				else nil,
			props.Children,
		},
	}) :: Frame
end
