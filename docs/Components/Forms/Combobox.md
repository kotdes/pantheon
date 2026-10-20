---
tags:
  - Forms
  - Components
---

# Combobox

Combobox is a [Select](./Select.md) with `Filterable` turned on. The user can type to narrow down the options.

## Usage

Call `Components.Combobox` with a scope and a table of properties:

```luau
scope:Combobox({
	Label = "Font",
	Options = {
		{ Value = "montserrat", Label = "Montserrat" },
		{ Value = "roboto", Label = "Roboto Mono" },
	},
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `Options` | `{ SelectOption }` | :white_check_mark: | - | The options, each with a `Value` and a `Label`. |
| `Value` | `UsedAs<string>` | :x: | `""` | The value. A plain value is only the starting value. A `Value` stays in step with the control: the user's changes set it, and setting it changes the control. |
| `Placeholder` | `UsedAs<string>` | :x: | `"Select…"` | Text to show while nothing is chosen. |
| `Label` | `UsedAs<string>` | :x: | - | Label above the field. |
| `Disabled` | `UsedAs<boolean>` | :x: | - | Stops the field opening. The component reads this once, when it creates the field. |
| `Filterable` | `boolean` | :x: | - | Always `true` in a Combobox. |
| `Validators` | `{ Validator }` | :x: | - | Validators to run on the chosen value. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (string) -> ()` | Runs with the `Value` of the option the user chose. |

## See also

- [Select](./Select.md)
