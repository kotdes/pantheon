# Migrating to 0.2

Version 0.2 renames and removes some of the 0.1 API. Read this page once and update your code. Anything not listed here works as before.

For most changes, the old name does nothing and Pantheon does not warn you. Search your code for the old names in the tables below.

## Calling components

Components are now methods on the scope. The documentation uses this form:

```luau
-- 0.1
local C = Pantheon.Components
C.Button(scope, { Text = "Save" })

-- 0.2
scope:Button({ Text = "Save" })
```

`Pantheon.Components.Button(scope, { ... })` still works, so you do not have to change your code.

If a component has the same name as a Fusion or Iona scope method, Pantheon raises an error when it loads.

## Replace Loader and Spinner with LoadingIndicator

`Loader` and `Spinner` no longer exist. Use [LoadingIndicator](../Components/Feedback/LoadingIndicator.md) and set `Kind` to choose the look.

| 0.1 | 0.2 |
| --- | --- |
| `Spinner({})` | `LoadingIndicator({})` |
| `Spinner({ Style = "Arc" })` | `LoadingIndicator({ Kind = "M2Spinner" })` |
| `Loader({ Kind = "Orbit" })` | `LoadingIndicator({ Kind = "Orbit" })` |

Two defaults changed:

- The default `Kind` is `"M3Morph"`. A `Loader` with no `Kind` drew `"Dots"`. Set `Kind = "Dots"` to keep that look.
- The default `SizePx` is `48` for `"M3Morph"` and `32` for the other kinds. A `Spinner` defaulted to `32`. Set `SizePx = 32` to keep that size.

## Rename callbacks

Every callback that reports a new value is now called `OnChanged`. It receives the new value.

| 0.1 | 0.2 |
| --- | --- |
| `Menu` and `NavigationDrawer`: `OnPageChanged` | `OnChanged` |
| `DockPanel`: `OnTabChanged` | `OnChanged` |
| `MenuSection`: `OnExpandedChanged` | `OnChanged` |
| `GradientPicker`: `OnGradientChanged` | `OnChanged` |
| `ColorPicker`: `OnChange(color, alpha)` | `OnChanged(color)` and `OnAlphaChanged(alpha)` |
| `Coachmark`, `Snackbar` and `SnackbarHost`: `OnDismiss` | `OnClose` |
| `Radio`: `OnActivated` | `OnClick` |

## Rename starting values

A property now has one name. A plain value sets the starting value. A state that you pass stays in step with the control in both directions. There is no separate `Default...` property.

| 0.1 | 0.2 |
| --- | --- |
| `MenuSection`: `DefaultExpanded = true` | `Expanded = true` |
| `Menu` and `NavigationDrawer`: `InitialPage` | `RootPage` |
| `Explorer`: `DefaultExpanded` | `ExpandRoots` |

`RootPage` is the first page of the stack. It is not a starting value for `Page`.

Pantheon now warns once when you pass a `Computed` to a control that the user can change. The control and the state no longer match after the user changes it. Pass a `Value` to keep them in step. For more detail, see [Common properties](CommonProperties.md).

## Replace Id with Persist.Id

A directive replaces the `Id` property on components that keep state. For more detail, see [Persisting state](PersistingState.md).

```luau
-- 0.1
scope:Switch({ Id = "settings.sound" })

-- 0.2
scope:Switch({ [Pantheon.Persist.Id] = "settings.sound" })
```

Pantheon ignores an `Id` that you leave in. It then finds the state by the order the component was created in. If the order of your interface changes, the state can go to the wrong control. Search for `Id =` on `Switch`, `Slider`, `Tabs`, `Select` and the other components that keep state.

Do not change `Id` where it names something else, such as a `MenuPage`, a tab, a toolbar item or a column.

If you wrote your own component with `Persist.key`, remove the `id` argument. The id now comes from `Persist.Id`.

```luau
-- 0.1
local key = Persist.key("MyToggle", props.Id)

-- 0.2
local key = Persist.key("MyToggle")
```

## Removed components

`TopBar`, `Leaderboard` and `Roster` no longer exist in `Pantheon.Game`. If you use them, keep a copy of the code from version 0.1 or replace them with your own.

## New in 0.2

[Directives](Directives.md) add behaviour to any component with a key in its properties. For example, you can add utility classes.
