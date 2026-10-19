---
tags:
  - Feedback
  - Components
---

# Alert

Alert is a banner that gives the user a message. Its colour shows how serious the message is.

## Usage

Call `Components.Alert` with a scope and a table of properties:

```luau
scope:Alert({
	Title = "Heads up",
	Text = "Your session expires in five minutes.",
	Tone = "Warning", -- (1)!
})
```

1.  `Tone` is `"Info"`, `"Success"`, `"Warning"` or `"Error"`.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `Title` | `UsedAs<string>` | :x: | - | Bold heading above the text. |
| `Text` | `UsedAs<string>` | :white_check_mark: | - | The message. |
| `Tone` | `AlertTone` | :x: | `"Info"` | Colour of the alert: `"Info"`, `"Success"`, `"Warning"` or `"Error"`. |

## See also

- [Snackbar](./Snackbar.md)
