---
tags:
  - Navigation
  - Components
---

# StatusBar

StatusBar is a thin bar for the status of a tool: messages, counts and activity. It has items at the start, the middle and the end.

## Usage

Call `Components.StatusBar` with a scope and a table of properties:

```luau
scope:StatusBar({
	Layer = overlayLayer,
	Start = { { Icon = "check", Text = "Ready", Tone = "Success" } },
	Middle = { { Busy = true, Text = "Saving", Progress = saveProgress } },
	End = {
		{ Icon = "triangle-alert", Text = "2 warnings", Tone = "Warning", OnClick = openOutput },
		{ Text = "Ln 42, Col 7" },
	},
})
```

## Items

| Field | Type | Description |
| ----- | ---- | ----------- |
| `Id` | `string?` | Name of the item. |
| `Text` | `UsedAs<string>?` | The text. |
| `Icon` | `string?` | Lucide icon. |
| `Tone` | `"Error"`, `"Warning"` or `"Success"` | Colour of the text and icon. Without it they are muted. |
| `Busy` | `boolean?` | A small spinner instead of the icon. |
| `Progress` | `UsedAs<number>?` | A thin progress bar, from `0` to `1`. A state is followed. |
| `Tooltip` | `string?` | Tooltip text. It needs a layer. |
| `OnClick` | `() -> ()` | Makes the item a button. |

## See also

- [Toolbar](./Toolbar.md)
