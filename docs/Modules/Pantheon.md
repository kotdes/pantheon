---
tags:
  - Modules
---

# Pantheon

The table that `require(Packages.Pantheon)` returns.

## Properties

| Name | Description |
| ---- | ----------- |
| `Components` | The components. Each is a function `(scope, props) -> Instance`. |
| `Game` | The in-game components: `Hotbar` and `Backpack`. See [Hotbar](../Game/Hotbar.md). |
| `Theme` | Making and providing themes. See [Theme](Theme.md). |
| `Style` | Reusable defaults for components. See [Style](Style.md). |
| `Persist` | Keeping component state across rebuilds. See [Persist](Persist.md). |
| `Layer` | The overlay layer of an interface. See [Layer](Layer.md). |
| `Flags` | Switches for library behaviour. See [Flags](Flags.md). |
| `Validators` | Validators for form fields. See [Validators](Validators.md). |
| `Accessibility` | Reading and applying accessibility settings. See the [Accessibility guide](../Guides/Accessibility.md). |
| `GroupFade` | Fades an instance and everything under it. See [GroupFade](GroupFade.md). |
| `CanvasFade` | Helpers that fade panels with a `CanvasGroup`, or with `GroupFade` when the flag is off. |
| `Shadow` | The elevation shadow component that other components use. |
| `Color` | Colour helpers: `luminance`, `lerp`, `onColor`, `toColor3` and others. |
| `Material` | The Material colour swatches, such as `Material.Blue[500]`. |
| `Apply` | `Apply(scope, instance)(props)` applies properties to an instance that already exists. |
| `Fusion`, `Iona` | The libraries, re-exported. |
| `Version` | `{ major, minor, isRelease }`. |

## Functions

| Name | Description |
| ---- | ----------- |
| `scoped: () -> Scope` | Makes a Fusion scope that has the Fusion methods and the instance methods of Iona. `scope:Apply(instance)` is available on it too, and `scope:Hydrate` is an alias for it. |

## Types

The module also exports the types `Theme`, `ThemeMode`, `Scope`, `ButtonProps`, `TextFieldProps`, `ListItemProps`, `ButtonVariant`, `ColorInput`, `ThemeColorRole` and `ThemePalette`.
