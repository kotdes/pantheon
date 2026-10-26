--!strict
--[[
	Material alert / confirm prompt — full-screen modal Dialog.
]]
local Types = require(script.Parent.Parent.Types)
local Dialog = require(script.Parent.Dialog)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme

return function(scope: Types.Scope, props: Types.PromptProps): Instance
	local theme = resolveTheme(props)
	local actions = props.Actions
		or {
			{
				Text = props.CancelText or "Cancel",
				Variant = "Tonal" :: Types.ButtonVariant,
				Color = "secondary",
				OnClick = props.OnClose,
			},
			{
				Text = props.ConfirmText or "OK",
				Variant = "Filled" :: Types.ButtonVariant,
				Color = if props.Destructive then "error" else "primary",
				OnClick = props.OnConfirm or props.OnClose,
			},
		}
	local iconColor = props.IconColor
	if iconColor == nil and props.Icon and props.Destructive then
		iconColor = theme.Colors.Error
	end
	return Dialog(scope, {
		Theme = props.Theme,
		Title = props.Title,
		Body = props.Body,
		Children = props.Children,
		Actions = actions,
		OnClose = props.OnClose,
		Open = props.Open,
		LayoutOrder = props.LayoutOrder,
		Size = props.Size,
		CornerRadius = props.CornerRadius,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Layer = props.Layer,
		Icon = props.Icon,
		IconColor = iconColor,
		IconSize = props.IconSize,
	})
end
