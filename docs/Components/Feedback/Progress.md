---
tags:
  - Feedback
  - Components
---

# Progress

Progress shows how far a task has got, as a bar or a ring. If you do not set a `Value`, it is indeterminate: it shows that something is happening but not how much is done.

## Usage

Call `Components.Progress` with a scope and a table of properties:

```luau
local done = scope:Value(0.4)

scope:Progress({ Value = done }) -- bar
scope:Progress({ Variant = "Circular", Value = done, SizePx = 48 })
scope:Progress({ Variant = "Circular" }) -- (1)!
```

1.  With no `Value`, a circular progress is the [LoadingIndicator](./LoadingIndicator.md), which changes shape. Set `Indicator` to `"Arc"` for a spinning arc.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Value` | `UsedAs<number>` | :x: | - | Progress from `0` to `1`. If you leave it out, the progress is indeterminate. The bar eases to each new value. |
| `Buffer` | `UsedAs<number>` | :x: | - | Linear buffering only. How far the buffered part reaches, from `0` to `1`. |
| `Variant` | `ProgressVariant` | :x: | `"Linear"` | `"Linear"` for a bar, `"Circular"` for a ring. |
| `Mode` | `ProgressMode` | :x: | `"Determinate"` when there is a `Value`, otherwise `"Indeterminate"` | `"Determinate"`, `"Indeterminate"` or `"Buffering"`. |
| `SizePx` | `number` | :x: | `40` | Circular only. Outer diameter, in pixels. |
| `Style` | `ProgressStyle` | :x: | `"Standard"` | Circular only. `"Standard"` has round caps and a gap before the track. `"Classic"` has flat caps and a full track. |
| `Thickness` | `number` | :x: | `3` for `"Classic"`, otherwise `4` | Circular only. Width of the ring, in pixels. |
| `Indicator` | `"Morph" \| "Arc"` | :x: | `"Morph"` | Circular indeterminate only. `"Morph"` or `"Arc"`. |
| `Background` | `Color3` | :x: | `Colors.Surface` | Circular `"Arc"` indeterminate only. The colour of the surface behind the progress. The component paints this colour over the ring to cut out the arc. |

## See also

- [Spinner](./Spinner.md)
- [LoadingIndicator](./LoadingIndicator.md)
