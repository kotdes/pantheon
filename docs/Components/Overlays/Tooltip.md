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
| `ZIndex` | `UsedAs<number>` | :x: | `160` | Z index of the component. |
| `Text` | `UsedAs<string>` | :white_check_mark: | - | The label. |
| `Target` | `Instance` | :x: | - | The element that shows the tooltip when hovered. |
| `Placement` | `TooltipPlacement` | :x: | `"Auto"` | Preferred side of the target. `"Auto"` picks the side with most room. |
| `Gap` | `number` | :x: | `8` | Space between the target and the tooltip in pixels. |
| `Tail` | `boolean` | :x: | from the blueprint | Draw a tail on the edge that faces the target. The tail slides along the edge as the tooltip moves. It also turns on the gliding between tooltips, described below. |
| `Color` | `UsedAs<ColorInput>` | :x: | The inverse of the surface | Colour of a tooltip with a tail: a palette name, a `Color3` or a role. |
| `Enabled` | `UsedAs<boolean>` | :x: | `true` | Whether hovering the target shows the tooltip. Pass a state to turn it on and off. |

## Tail and gliding

With `Tail`, the tooltip is a pill in the inverse colour of the surface, with a tail that points at the target. The tail is on the edge that faces the target and slides along it as the tooltip moves.

When the pointer goes from one target to another within about a third of a second, the next tooltip does not appear. It starts as the shape of the last one and moves, resizes and changes colour on the way to its own, and its text slides out and in. Both tooltips have to be on the same layer.

The Pantheon blueprint turns `Tail` on. Materia keeps the plain tooltip.

## See also

- [Coachmark](./Coachmark.md)
