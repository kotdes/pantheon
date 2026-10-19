---
tags:
  - Forms
  - Components
---

# ChoiceGroup

ChoiceGroup lets the user choose one option in a form. It is a RadioGroup or a SegmentedControl with a label and validation.

## Usage

Call `Components.ChoiceGroup` with a scope and a table of properties:

```luau
scope:ChoiceGroup({
	Label = "Role",
	Variant = "Segmented",
	Options = {
		{ Value = "user", Label = "User" },
		{ Value = "admin", Label = "Admin" },
	},
	Validators = { V.required() },
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Options` | `{ ChoiceGroupOption }` | :white_check_mark: | - | The options. Each has a `Value` and a `Label`. An option can also be `Disabled`. |
| `Value` | `UsedAs<string>` | :x: | The first option | The value. A plain value is only the starting value. A `Value` stays in step with the control: the user's changes set it, and setting it changes the control. |
| `Disabled` | `UsedAs<boolean>` | :x: | - | Stops the group reacting to input. The component reads this once, when it creates the group. |
| `Variant` | `"Radio" \| "Segmented"` | :x: | `"Radio"` | `"Radio"` shows a list of radio buttons. `"Segmented"` shows a segmented control. |
| `Validators` | `{ Validator }` | :x: | - | Validators to run on the chosen value. If one fails, its message appears under the group. |
| `Label` | `UsedAs<string>` | :x: | - | Label above the group. |
| `Id` | `string` | :x: | - | Key that identifies this component when state is kept across rebuilds. See [Persist](../../Guides/PersistingState.md). |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (string) -> ()` | Runs with the `Value` of the option the user chose. |

## See also

- [RadioGroup](./RadioGroup.md)
- [SegmentedControl](./SegmentedControl.md)
