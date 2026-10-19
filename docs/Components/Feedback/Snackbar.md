---
tags:
  - Feedback
  - Components
---

# Snackbar

Snackbar is a short message on a surface that contrasts with the app. It can have an icon or element before the message, an action, an element after it, and a close button. To show messages that appear and disappear, use [SnackbarHost](./SnackbarHost.md).

## Usage

Call `Components.Snackbar` with a scope and a table of properties:

```luau
scope:Snackbar({
	Message = "Message deleted",
	Icon = "trash-2",
	ActionText = "Undo",
	OnAction = function()
		print("Restored")
	end,
	Dismissible = true, -- (1)!
	OnDismiss = function()
		print("Closed")
	end,
})
```

1.  `Dismissible` adds a close button at the end. The snackbar does not remove itself, so remove it in `OnDismiss`. [SnackbarHost](./SnackbarHost.md) removes its messages for you.

## Layout

From the start, the parts are: `Leading` or `Icon`, the message, the action button, `Trailing`, and the close button. Use `Leading` and `Trailing` to add your own elements, such as an avatar or a spinner.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Message` | `UsedAs<string>` | :white_check_mark: | - | The message. |
| `ActionText` | `string` | :x: | - | Label of the action button. If you leave it out, there is no button. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnAction: () -> ()` | Runs when the user presses the action button. |

## See also

- [SnackbarHost](./SnackbarHost.md)
