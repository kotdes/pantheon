# Theming

A theme is a table with the colours, fonts, type scales, spacing and motion of the interface. Components read from it, so changing the theme changes the whole interface.

## Making a theme

```luau
local theme = Pantheon.Theme.create("Light") -- or "Dark"
```

`Theme.create` takes the mode and a table of options:

| Option | Type | Description |
| ------ | ---- | ----------- |
| `RespectAccessibility` | `boolean?` | Read the accessibility settings of the player and apply them. `true` by default. See [Accessibility](Accessibility.md). |
| `Accessibility` | `AccessibilityPrefs?` | Use these settings instead of reading them. Useful for storybooks and tests. |
| `Controls` | `ThemeControls?` | Settings for controls, such as `SwitchIcons`. |
| `Overrides` | `{ [string]: any }?` | Values to merge over the finished theme. |
| `Palette` | `{ [string]: ... }?` | Extra named colours for `Color` properties. A value is a `Color3`, a hex string or a full `ThemeColorRole`. |
| `Typography` | `{ [string]: TypeScale }?` | Extra or replaced type scales. The defaults that are not replaced are kept. |

## What is in a theme

| Field | Contents |
| ----- | -------- |
| `Mode` | `"Light"` or `"Dark"`. |
| `Colors` | Roles such as `Primary`, `OnPrimary`, `Surface`, `OnSurface`, `Outline`, `Error`. Each `On` role is the colour of content drawn on its base. |
| `Palette` | Named colours for `Color` properties. Each has a `Base`, an `OnBase`, a `Container` and an `OnContainer`. |
| `Fonts` | `Heading`, `Body` and `Mono`. |
| `Typography` | Scales with a `Font`, a `Size` and a `LineHeight`: `Display`, `Headline`, `Title`, `Button`, `Body`, `Label` and `Mono`. |
| `Metrics` | Spacing (`SpaceXs` to `SpaceXl`), corner radii (`RadiusXs` to `Radius3xl`, `RadiusPanel`, `RadiusPill`) and sizes such as `AppBarHeight`, `DrawerWidth` and `RailWidth`. |
| `Motion` | `SpringSpeed`, `SpringDamping` and `PressScale`, used by the springs of the components. |
| `Icons`, `Audio` | Names of icons and sounds. |
| `Controls` | Settings for controls. |
| `Accessibility` | The accessibility settings that were applied, if any. |

## Providing the theme

`Theme.Provide` makes a theme the current one while a function runs:

```luau
Pantheon.Theme.Provide(theme, function()
	scope:Button({ Text = "Hello" })
end)
```

Components find the theme when they are created. To use another theme for one component, pass `Theme`:

```luau
scope:Button({ Text = "Hello", Theme = darkTheme })
```

## Switching theme

!!! warning "Experimental"
    With `Flags.ReactiveTheme = true`, components follow a theme state in place and no rebuild is needed. Pass the state from `Theme.createAnimated` to `Theme.Provide`. Colours that are read at build time (a few leftover sites, such as disabled button backgrounds) still show the old theme until rebuilt. With the flag off, use the rebuild approach below.

Components read the theme once, when they are built. A theme change therefore needs a rebuild of the interface. To make a rebuild painless:

1. Keep the state that matters outside the view, or give the app a [Persist](PersistingState.md) store, so controls keep their values.
2. Build the new interface under the new theme, fade it in over the old one, and then clean up the old one. The demo storyboard does this.

`Theme.createAnimated` makes a theme state that moves between light and dark with a spring. It is used by the storyboard so that the colours of a new interface start from the old theme and blend over to the new one:

```luau
local mode = scope:Value("Light")
local theme = Pantheon.Theme.createAnimated(scope, mode, { Animate = true })
```

!!! note

    Recolouring a live interface without a rebuild is not supported yet. There are notes on how it could work in [Notes](../notes.md).

## Colours in properties

A property that takes a `ColorInput`, such as the `Color` of a [Button](../Components/Foundations/Button.md), accepts:

- a palette name such as `"primary"`, `"secondary"` or `"error"`, or a name you added in the `Palette` option;
- a `Color3`;
- a hex string such as `"#00695c"`;
- an RGB table such as `{ 0, 105, 92 }`;
- a Material swatch such as `"Blue 500"` or `{ Blue = 500 }`;
- a full `ThemeColorRole`.

Anything but a role is turned into a role: a base colour, the colour for content on it, and a container pair.
