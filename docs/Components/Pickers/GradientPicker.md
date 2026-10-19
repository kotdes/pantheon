---
tags:
  - Pickers
  - Components
---

# GradientPicker

GradientPicker edits a gradient with any number of colour stops. A [ColorPicker](./ColorPicker.md) below the editor changes the colour of the selected stop.

## Usage

Call `Components.GradientPicker` with a scope and a table of properties:

```luau
local preview = scope:New("UIGradient")({})

scope:GradientPicker({
	Layer = overlayLayer, -- (1)!
	OnChanged = function(colors, transparency, rotation, offset)
		preview.Color = colors
		preview.Transparency = transparency
		preview.Rotation = rotation
		preview.Offset = offset
	end,
})
```

1.  `Layer` is where the tooltips of the buttons are mounted. Without it, or a layer set with `Layer.Provide` or `Layer.bind`, there are no tooltips.

## The editor

The top container holds the gradient bar and the controls for the selected stop:

- **Bar.** Press a handle to select it and drag it along the bar. Press an empty part of the bar to add a stop there, coloured from the gradient at that point. Handles scale in when they are added, and the selected one is slightly larger and grows while it is dragged.
- **Rot, Pos and Alpha.** Three boxes in a row. Press one and it grows to fill the row, while the others fade out and its editor fades in. The editor has a back arrow, a slider and a text field. **Rot** is the rotation of the gradient. **Pos** is its offset, with an X row and a Y row. **Alpha** is the opacity of the selected stop.
- **Hex.** The hex colour of the selected stop, with buttons to duplicate and to delete it. A gradient keeps at least two stops, so delete is disabled at two.

## The node editor

Under the editor, on a darker fill with no gap between them, is a plain [ColorPicker](./ColorPicker.md) with no footer and no alpha slider. It edits the colour of the selected stop. Its tabs, models and swatches are the same as the static picker, and `Modes`, `Models`, `Mode`, `Model`, `Area` and `Palette` are passed on to it.

## Output

`OnChanged` is called with values that can be assigned straight to a `UIGradient`: a `ColorSequence` for `Color`, a `NumberSequence` for `Transparency`, a number for `Rotation` and a `Vector2` for `Offset`. It is called once when the picker is created, so a preview is right before the first edit.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Id` | `string` | :x: | - | Key that identifies this component when state is kept across rebuilds. See [Persist](../../Guides/PersistingState.md). |
| `Layer` | `Instance` | :x: | The layer from `Layer.Provide` or `Layer.bind` | Overlay layer that floating content is mounted in. See [Overlay layers](../../Guides/OverlayLayers.md). |
| `Gradient` | `UsedAs<ColorSequence>` | :x: | Two stops, the default colour and white | Starting colours, one stop for each keypoint. |
| `GradientTransparency` | `UsedAs<NumberSequence>` | :x: | - | Starting transparency. The alpha of a stop is `1 - transparency`. |
| `GradientRotation` | `number` | :x: | `0` | Starting rotation in degrees. |
| `ShowAlpha` | `boolean` | :x: | `true` | Show the Alpha box. |
| `Modes` | `{ string }` | :x: | - | Passed to the node [ColorPicker](./ColorPicker.md). |
| `Models` | `{ string }` | :x: | - | Passed to the node ColorPicker. |
| `Mode` | `string` | :x: | - | Passed to the node ColorPicker. |
| `Model` | `string` | :x: | - | Passed to the node ColorPicker. |
| `Area` | `"Square" \| "Wheel"` | :x: | - | Passed to the node ColorPicker. |
| `Palette` | `{ Color3 }` | :x: | - | Passed to the node ColorPicker. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (ColorSequence, NumberSequence, number, Vector2) -> ()` | Runs with the colours, transparency, rotation and offset when a stop is added, moved, recoloured or removed, or when the rotation, offset or alpha changes. |

## See also

- [ColorPicker](./ColorPicker.md)
