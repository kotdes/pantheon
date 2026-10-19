---
tags:
  - Feedback
  - Components
---

# LoadingIndicator

LoadingIndicator is the loading shape from Material 3 Expressive. It is a solid shape that spins and changes through a cycle of other shapes.

## Usage

Call `Components.LoadingIndicator` with a scope and a table of properties:

```luau
scope:LoadingIndicator({ SizePx = 56, Contained = true })
```

## How it is drawn

Roblox has no polygon element. Each shape is cut into horizontal strips, with up to two spans in each strip so that notches and lobes stay. Changing shape moves the edges of each strip. The strips have one colour and spin together, so they look like one shape.

## Shapes

`Oval`, `Pill`, `Triangle`, `Arrow`, `Fan`, `Diamond`, `Clamshell`, `Pentagon`, `Gem`, `Sunny`, `VerySunny`, `SoftBurst`, `Cookie4`, `Cookie6`, `Cookie7`, `Cookie9`, `Cookie12` and `Burst`. The default cycle is the one in the Material 3 specification.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `SizePx` | `number` | :x: | `48` | Diameter of the container, in pixels. |
| `Contained` | `boolean` | :x: | `false` | Draw the shape inside a round `PrimaryContainer` disc. The shape is then 66% of `SizePx`. |
| `Shapes` | `{ string }` | :x: | The Material 3 sequence | Names of the shapes to cycle through, in order. |

## See also

- [Spinner](./Spinner.md)
- [Loader](./Loader.md)
