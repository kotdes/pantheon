---
tags:
  - Forms
  - Components
---

# SegmentedControl

SegmentedControl is a row of options. The user chooses one. A pill slides and stretches to the chosen segment, like the control on iOS.

## Usage

Call `Components.SegmentedControl` with a scope and a table of properties:

```luau
scope:SegmentedControl({
	Items = {
		{ Id = "day", Label = "Day" },
		{ Id = "week", Label = "Week" },
	},
	Selected = "day",
	OnChanged = function(id)
		print("Showing", id)
	end,
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
| `Items` | `{ { Id: string, Label: string, Icon: string? } }` | :white_check_mark: | - | The segments. Each has an `Id`, a `Label` and an optional Lucide `Icon`. |
| `Selected` | `UsedAs<string>` | :x: | The first item | `Id` of the chosen segment. A plain value is only the starting segment. A `Value` stays in step with the control: the user's changes set it, and setting it changes the control. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the control reacting to input. The component reads this once, when it creates the control. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (string) -> ()` | Runs with the `Id` of the segment the user chose. |

## See also

- [Tabs](../Navigation/Tabs.md)
- [ChoiceGroup](./ChoiceGroup.md)
