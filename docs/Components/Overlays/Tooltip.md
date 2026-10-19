---
tags:
  - Overlays
  - Components
---

# Tooltip

!!! note

    A tooltip needs a layer to mount on. Without `Layer`, or a layer set with `Layer.Provide` or `Layer.bind`, it is created but never shown.

Tooltip shows a short label when the pointer is over an element. The tip is kept inside its layer, so it stays within a [Window](../Navigation/Window.md).

## Usage

Call `Components.Tooltip` with a scope and a table of properties:

```luau
local save = scope:IconButton({ Name = "save" })

scope:Tooltip({
	Layer = overlayLayer,
	Target = save,
	Text = "Save",
	Placement = "Auto",
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `ZIndex` | `UsedAs<number>` | :x: | `120` | Z index of the component. |
| `Text` | `UsedAs<string>` | :white_check_mark: | - | The label. |
| `Target` | `Instance` | :x: | - | The element that shows the tooltip when hovered. |
| `Placement` | `TooltipPlacement` | :x: | `"Auto"` | Preferred side of the target. `"Auto"` picks the side with most room. |
| `Gap` | `number` | :x: | `8` | Space between the target and the tooltip in pixels. |

## See also

- [Coachmark](./Coachmark.md)
