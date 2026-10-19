---
tags:
  - Modules
---

# Features

Features finds out which newer Roblox UI features the engine has, so a component can use them and fall back to something else when they are missing. A feature is tested once, by creating an instance and setting the property, and the answer is kept.

`Flags.BetaUI = false` makes the features that are in a beta report `false`.

## Functions

| Name | Feature |
| ---- | ------- |
| `individualCorners: () -> boolean` | `UICorner` radii for each corner (`TopLeftRadius` and the others). |
| `gradientTypes: () -> boolean` | `UIGradient.Type` set to `"Radial"` or `"Conical"`. Studio beta. |
| `gradientTiling: () -> boolean` | `UIGradient` tile mode and scale. Studio beta. |
| `shadowText: () -> boolean` | `UIShadow` in its text mode. Studio beta. |

## Used by

- [Window](../Components/Navigation/Window.md) and [Overlay](../Components/Overlays/Overlay.md) round single corners with `individualCorners`. Without it they keep square corners where they meet.
- [ColorPicker](../Components/Pickers/ColorPicker.md) draws the hue ring with `gradientTypes`, and falls back to a square.
- [LoadingIndicator](../Components/Feedback/LoadingIndicator.md), [Progress](../Components/Feedback/Progress.md) and the arcs they draw use conical gradients when they can.
- [NumberSpinner](../Components/Forms/NumberSpinner.md) blurs digits with a text shadow when `shadowText` is `true`.
