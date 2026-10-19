---
tags:
  - Feedback
  - Components
---

# Spinner

!!! note

    For a ring that fills up as a task progresses, use `Progress` with `Variant = "Circular"`.

Spinner shows that something is loading with no end in sight. By default it is the shape-morphing [LoadingIndicator](./LoadingIndicator.md); `Style = "Arc"` gives a spinning ring instead.

## Usage

Call `Components.Spinner` with a scope and a table of properties:

```luau
scope:Spinner({ SizePx = 32 })
scope:Spinner({ Style = "Arc", Background = theme.Colors.Surface })
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `SizePx` | `number` | :x: | `32` | Diameter in pixels. |
| `Style` | `"Morph" \| "Arc"` | :x: | `"Morph"` | `"Morph"` for the shape-morphing indicator, `"Arc"` for a spinning ring. |
| `Background` | `Color3` | :x: | - | `"Arc"` only. The colour of the surface behind the spinner. The arc is cut out of the ring by painting this colour over it. |
| `Contained` | `boolean` | :x: | `false` | `"Morph"` only. Draw the shape inside a round `PrimaryContainer` disc. |
| `Shapes` | `{ string }` | :x: | - | `"Morph"` only. Names of the shapes to cycle through. See [LoadingIndicator](./LoadingIndicator.md). |

## See also

- [Progress](./Progress.md)
- [Loader](./Loader.md)
