# Persisting state

The values a user enters, such as the selected tab, a switch, a slider or the text of a field, live in Fusion values inside each component. When you rebuild the interface, for example to change theme or layout, those values are gone with the old components.

`Persist` keeps them. You give the app a store, and the values live in the scope of the store, so a rebuild finds them again.

## Using a store

```luau
local store = Pantheon.Persist.createStore(rootScope) -- (1)!

local function rebuild()
	Pantheon.Persist.Provide(store, function()
		-- build the interface: every Switch, Tabs, Slider... reuses its value
	end)
end
```

1.  The store keeps its values in `rootScope`, so they outlive the scopes of the individual builds.

Without a store, every component creates its own plain values, as usual.

## How a component finds its value

A component looks up its state:

- by its id, when it has one: `[Pantheon.Persist.Id] = "settings.sound"`;
- otherwise by its kind and the order it was created in during the build: the third `Switch` is `Switch#3`.

A rebuild runs the same code in the same order, so the order is stable. Interface that changes the order, such as a switch that is only built when a condition holds, should have explicit ids:

```luau
scope:Switch({ [Pantheon.Persist.Id] = "settings.sound" })
```

`Persist.Id` is a [directive](Directives.md), so it works on every component that keeps state.

## What is not kept

A property you give as a state is left alone. If you pass `Value = someValue`, you own that state, and the component does not store it.

## Components that keep state

`Switch`, `Checkbox`, `RadioGroup`, `ChoiceGroup`, `Select`, `MultiSelect`, `Slider`, `RangeSlider`, `DatePicker`, `TimePicker`, `Tabs`, `SegmentedControl`, `Collapsible`, `TreeView`, `StarRating`, `Pagination`, `NavigationRail`, `TextField` (the text typed into it), `ColorPicker` and `GradientPicker`.

See [Persist](../Modules/Persist.md) for the functions.
