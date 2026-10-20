---
tags:
  - Navigation
  - Components
---

# Tabs

Tabs is a row of chips that switches between views. The row scrolls sideways when it does not fit.

<div class="es-preview" data-component="Tabs"></div>

## Usage

Call `Components.Tabs` with a scope and a table of properties:

```luau
scope:Tabs({
	Items = {
		{ Id = "all", Label = "All" },
		{ Id = "unread", Label = "Unread" },
	},
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
| `Size` | `UsedAs<UDim2>` | :x: | `UDim2.new(1, 0, 0, 44)` | Size of the component. |
| `Items` | `{ TabItem }` | :white_check_mark: | - | The tabs. Each has an `Id` and a `Label`. |
| `Selected` | `UsedAs<string>` | :x: | The first item | `Id` of the selected tab. A plain value is only the starting tab. A `Value` is followed, and is set when the user picks one. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (string) -> ()` | Runs with the `Id` of the tab the user picked. |

## See also

- [SegmentedControl](../Forms/SegmentedControl.md)
