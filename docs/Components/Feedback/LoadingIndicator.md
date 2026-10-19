---
tags:
  - Feedback
  - Components
---

# LoadingIndicator

!!! note

    For a ring that fills up as a task progresses, use `Progress` with `Variant = "Circular"`.

LoadingIndicator shows that something is loading with no end in sight. Choose the look with `Kind`. All kinds are square, so they fit the same layouts.

## Usage

Call `Components.LoadingIndicator` with a scope and a table of properties, or call it on the scope:

```luau
scope:LoadingIndicator({ SizePx = 56, Contained = true })
scope:LoadingIndicator({ Kind = "Orbit", SizePx = 36 })
scope:LoadingIndicator({ Kind = "Icon", Icon = "refresh-cw", Motion = "Spin" })
scope:LoadingIndicator({ Kind = "M2Spinner", Background = theme.Colors.Surface })
```

## Kinds

| Kind | Description |
| ---- | ----------- |
| `"M3Morph"` | The default. The loading shape from Material 3 Expressive: a solid shape that spins and changes through a cycle of other shapes. |
| `"M2Spinner"` | A spinning ring arc, as in Material 2. Set `Background` to the colour of the surface behind it. |
| `"Beachball"` | A spinning rainbow pinwheel, as on macOS. |
| `"Dots"` | Three bouncing dots. |
| `"Bars"` | Bars that move up and down like an equaliser. |
| `"Ripple"` | Rings that spread out from a dot in the middle. |
| `"Orbit"` | Dots that chase each other around a circle. |
| `"Gnome"` | A thin ring with a small dot circling it, with a fading trail. |
| `"Icon"` | A Lucide icon with a motion: `"Spin"`, `"Pulse"`, `"Bounce"`, `"Flip"` or `"Wiggle"`. |

## How M3Morph is drawn

Roblox has no polygon element. Each shape is cut into horizontal strips, with up to two spans in each strip so that notches and lobes stay. Changing shape moves the edges of each strip. The strips have one colour and spin together, so they look like one shape.

### Shapes

`Oval`, `Pill`, `Triangle`, `Arrow`, `Fan`, `Diamond`, `Clamshell`, `Pentagon`, `Gem`, `Sunny`, `VerySunny`, `SoftBurst`, `Cookie4`, `Cookie6`, `Cookie7`, `Cookie9`, `Cookie12` and `Burst`. The default cycle is the one in the Material 3 specification.

## Conical gradients

`"Beachball"` and `"M2Spinner"` use a conical `UIGradient` if the engine supports it. If not, they use other drawing methods. See [Flags](../../Modules/Flags.md).

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Kind` | `LoadingIndicatorKind` | :x: | `"M3Morph"` | Which indicator to draw. |
| `SizePx` | `number` | :x: | `48` for `"M3Morph"`, `32` for the others | Width and height, in pixels. |
| `Contained` | `boolean` | :x: | `false` | `"M3Morph"` only. Draw the shape inside a round `PrimaryContainer` disc. The shape is then 66% of `SizePx`. |
| `Shapes` | `{ string }` | :x: | The Material 3 sequence | `"M3Morph"` only. Names of the shapes to cycle through, in order. |
| `Background` | `Color3` | :x: | - | `"M2Spinner"` only. The colour of the surface behind the spinner. The arc is cut out of the ring by painting this colour over it. |
| `Color` | `Color3` | :x: | `Colors.Primary` | Colour of `"Dots"`, `"Bars"`, `"Ripple"`, `"Orbit"`, `"Gnome"` and `"Icon"`. The beachball ignores this, because it is a rainbow. |
| `Icon` | `string` | :x: | `"loader"` | `"Icon"` only. Name of a Lucide icon. |
| `Motion` | `LoadingIndicatorMotion` | :x: | `"Spin"` | `"Icon"` only. The motion of the icon. |

## See also

- [Progress](./Progress.md)
