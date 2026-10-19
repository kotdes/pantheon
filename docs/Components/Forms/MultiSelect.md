---
tags:
  - Forms
  - Components
---

# MultiSelect

MultiSelect works like Select, but the user can choose more than one option. It shows the choices as chips or as a count.

## Usage

Call `Components.MultiSelect` with a scope and a table of properties:

```luau
scope:MultiSelect({
	Label = "Tags",
	Options = {
		{ Value = "ui", Label = "UI" },
		{ Value = "net", Label = "Networking" },
	},
	Display = "Count",
	OnChanged = function(values)
		print(#values, "selected")
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
| `Value` | `UsedAs<{ string }>` | :x: | `{}` | The list of chosen values. A plain list is only the starting choice. A `Value` stays in step with the control: the user's changes set it, and setting it changes the control. |
| `Placeholder` | `UsedAs<string>` | :x: | `"Select…"` | Text to show while nothing is chosen. |
| `Label` | `UsedAs<string>` | :x: | - | Label above the field. |
| `Disabled` | `UsedAs<boolean>` | :x: | - | Stops the field opening. The component reads this once, when it creates the field. |
| `Validators` | `{ Validator }` | :x: | - | Validators to run on the list of chosen values. |
| `Display` | `"Chips" \| "Count"` | :x: | `"Chips"` | `"Chips"` shows a chip for each choice. `"Count"` shows how many choices there are. |
| `Id` | `string` | :x: | - | Key that identifies this component when state is kept across rebuilds. See [Persist](../../Guides/PersistingState.md). |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: ({ string }) -> ()` | Runs with the new list of values each time the choice changes. |

## See also

- [Select](./Select.md)
