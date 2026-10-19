# Common properties

Most components accept the properties below. A component page lists them only when the component uses them.

| Name | Type | Description |
| ---- | ---- | ----------- |
| `Theme` | `ThemeRef` | Theme for this component, instead of the one from `Theme.Provide`. It can be a theme or a state of one. |
| `LayoutOrder` | `UsedAs<number>` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | Size. Each component has its own default. |
| `Visible` | `UsedAs<boolean>` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | Z index. |
| `Layer` | `Instance` | Where floating content is mounted. See [Overlay layers](OverlayLayers.md). |
| `Id` | `string` | Names the component so it can find its state again after a rebuild. See [Persisting state](PersistingState.md). |

## `UsedAs<T>`

`UsedAs<T>` is the Fusion type for a value that can be a `T` or a state that holds a `T`. A property of this type follows a state when you give one.

## Values you can follow

A control that lets the user change a value, such as `Checkbox`, `Switch`, `Slider`, `Select`, `Tabs`, `TextField` and `ColorPicker`, keeps that value in its own state. What the property does depends on what you give it:

- A plain value, such as `Checked = true`, is the starting value. The control keeps its own state from then on.
- A `Value` is linked to the control in both directions. Setting the `Value` moves the control, and the user changing the control sets the `Value`.
- A `Computed` cannot be set, so it only moves the control. The control still changes when the user uses it, and the next change of the `Computed` overrides that.

```luau
local volume = scope:Value(40)

scope:Slider({ Min = 0, Max = 100, Value = volume })

volume:set(75) -- the slider moves
```

Use the callback of the component, which is `OnChanged` for most of them, when you want to run code on a change.

A control whose value you link this way is not [kept across rebuilds](PersistingState.md), since you own that state.

## Properties that are read once

Where a property is described as read once, changing the state later has no effect. `Disabled` is read once on most components.
