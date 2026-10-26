--!strict
local Types = require(script.Parent.Parent.Types)
local Prompt = require(script.Parent.Prompt)

return function(scope: Types.Scope, props: Types.ConfirmDialogProps): Instance
	return Prompt(scope, {
		Theme = props.Theme,
		Title = props.Title,
		Body = props.Body,
		Children = props.Children,
		Actions = props.Actions,
		OnClose = props.OnClose,
		OnConfirm = props.OnConfirm,
		ConfirmText = props.ConfirmText,
		Open = props.Open,
		LayoutOrder = props.LayoutOrder,
		Size = props.Size,
		CornerRadius = props.CornerRadius,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Layer = props.Layer,
		Icon = props.Icon,
		IconColor = props.IconColor,
		IconSize = props.IconSize,
		Destructive = true,
	})
end
