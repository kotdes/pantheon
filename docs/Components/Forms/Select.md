---
tags:
  - Forms
  - Components
---

# Select

Select shows the chosen option in a field. When the user presses the field, it opens a list of the other options. The list can filter as the user types.

## Usage

Call `Components.Select` with a scope and a table of properties:

```luau
scope:Select({
	Label = "Country",
	Options = {
		{ Value = "ca", Label = "Canada" },
		{ Value = "jp", Label = "Japan" },
	},
	Filterable = true,
	OnChanged = function(value)
		print("Chose", value)
	end,
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Options` | `{ SelectOption }` | :white_check_mark: | - | The options, each with a `Value` and a `Label`. |
| `Value` | `UsedAs<string>` | :x: | `""` | The value. A plain value is only the starting value. A `Value` stays in step with the control: the user's changes set it, and setting it changes the control. |
| `Placeholder` | `UsedAs<string>` | :x: | `"Select…"` | Text to show while nothing is chosen. |
| `Label` | `UsedAs<string>` | :x: | - | Label above the field. |
| `Disabled` | `UsedAs<boolean>` | :x: | - | Stops the field opening. The component reads this once, when it creates the field. |
| `Filterable` | `boolean` | :x: | `false` | Show a search box that filters the list. [Combobox](./Combobox.md) is a Select with this turned on. |
| `Validators` | `{ Validator }` | :x: | - | Validators to run on the chosen value. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (string) -> ()` | Runs with the `Value` of the option the user chose. |

## See also

- [Combobox](./Combobox.md)
- [MultiSelect](./MultiSelect.md)
