---
tags:
  - Feedback
  - Components
---

# Loader

Loader is a set of loading animations. Choose one with `Kind`. All of them are square, so they fit the same layouts.

## Usage

Call `Components.Loader` with a scope and a table of properties:

```luau
scope:Loader({ Kind = "Orbit", SizePx = 36 })
scope:Loader({ Kind = "Icon", Icon = "refresh-cw", Motion = "Spin" })
```

## Kinds

| Kind | Description |
| ---- | ----------- |
| `"Beachball"` | A spinning rainbow pinwheel, as on macOS. |
| `"Dots"` | Three bouncing dots. |
| `"Bars"` | Bars that move up and down like an equaliser. |
| `"Ripple"` | Rings that spread out from a dot in the middle. |
| `"Orbit"` | Dots that chase each other around a circle. |
| `"Gnome"` | A thin ring with a small dot circling it, with a fading trail. |
| `"Icon"` | A Lucide icon with a motion: `"Spin"`, `"Pulse"`, `"Bounce"`, `"Flip"` or `"Wiggle"`. |

## Conical gradients

The beachball uses a conical `UIGradient` if the engine supports it. If not, it uses stacked discs. See [Flags](../../Modules/Flags.md).

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Kind` | `LoaderKind` | :x: | `"Dots"` | Which loader to draw. |
| `SizePx` | `number` | :x: | `32` | Width and height, in pixels. |
| `Color` | `Color3` | :x: | `Colors.Primary` | Colour of the loader. The beachball ignores this, because it is a rainbow. |
| `Icon` | `string` | :x: | `"loader"` | `"Icon"` only. Name of a Lucide icon. |
| `Motion` | `LoaderMotion` | :x: | `"Spin"` | `"Icon"` only. The motion of the icon. |

## See also

- [LoadingIndicator](./LoadingIndicator.md)
- [Spinner](./Spinner.md)
