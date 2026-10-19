---
tags:
  - Overlays
  - Components
---

# ConfirmDialog

ConfirmDialog is a [Prompt](./Prompt.md) with `Destructive` always on. Use it to confirm an action that cannot be undone.

## Usage

Call `Components.ConfirmDialog` with a scope and a table of properties:

```luau
scope:ConfirmDialog({
	Layer = overlayLayer,
	Open = open,
	Title = "Delete project?",
	Body = "All files will be removed.",
	ConfirmText = "Delete",
	OnConfirm = deleteProject,
	OnClose = function()
		open:set(false)
	end,
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Title` | `UsedAs<string>` | :white_check_mark: | - | Heading of the dialog. |
| `Body` | `UsedAs<string>` | :x: | - | Text under the heading. |
| `Children` | `any` | :x: | - | Custom content under the body. |
| `Actions` | `{ DialogAction }` | :x: | - | Buttons to use instead of the Cancel and confirm pair. |
| `ConfirmText` | `string` | :x: | `"OK"` | Label of the confirm button. |
| `Open` | `UsedAs<boolean>` | :x: | - | Whether the dialog is shown. Follows the state you pass. |
| `Icon` | `string` | :x: | - | Lucide icon above the title. |
| `IconColor` | `UsedAs<Color3>` | :x: | - | Colour of the icon. It is red by default when an icon is set. |
| `IconSize` | `number` | :x: | - | Size of the icon in pixels. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClose: () -> ()` | Runs when the user cancels or presses the scrim. |
| `OnConfirm: () -> ()` | Runs when the user presses the confirm button. When left out, `OnClose` is called. |

## See also

- [Prompt](./Prompt.md)
