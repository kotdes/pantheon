---
tags:
  - Modules
---

# Theme

Theme makes the tables that components read their look from, and says which one is current. See [Theming](../Theming/index.md) for what a theme holds and how to switch it.

## Functions

| Name | Description |
| ---- | ----------- |
| `create: (mode: ThemeMode?, opts: ThemeCreateOpts?) -> Theme` | Makes a theme. `mode` is `"Light"` or `"Dark"`, and is `"Light"` when left out. |
| `createAnimated: (scope: Scope, mode: UsedAs<ThemeMode>, opts: { Animate: boolean?, ... }?) -> ThemeRef` | Makes a state of a theme that follows `mode`. When the mode changes, the theme blends from one to the other with a spring. Set `Animate = false`, or turn on reduced motion, and it swaps at once. |
| `Provide: (theme: ThemeRef, callback: (...) -> ..., ...) -> ...` | Makes `theme` the current theme while `callback` runs, and returns what it returns. |
| `use: () -> Theme` | The current theme. It fails if there is none. |
| `useRef: () -> ThemeRef` | Like `use`, but returns the state when the theme was provided as one. |
| `resolve: (props: { Theme: ThemeRef? }?) -> Theme` | The `Theme` of `props` if it has one, and the current theme otherwise. Components use it. |
| `blend: (a: Theme, b: Theme, t: number) -> Theme` | A theme between two others. `t` is from `0` to `1`. |
| `deepMerge: (base: any, over: any) -> any` | Merges `over` into `base`. Tables merge field by field. Other values are replaced. |

## Properties

| Name | Description |
| ---- | ----------- |
| `Contextual` | The Fusion `Contextual` that holds the current theme. |
| `Accessibility` | The [Accessibility](../Guides/Accessibility.md) module. |
| `Color` | The colour helpers. |
| `Material` | The Material colour swatches. |

!!! note

    `Provide` also remembers the theme as a fallback. A function that Fusion runs later, such as the callback of a `Computed`, has lost the context, and finds the last provided theme instead.
