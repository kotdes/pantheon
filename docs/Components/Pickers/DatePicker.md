---
tags:
  - Pickers
  - Components
---

# DatePicker

DatePicker is a calendar for choosing a day. The header opens a month picker and a year picker, and the grid of days animates when the month changes. A pill slides to the day you pick, today has a ring, and days shrink a little while pressed.

## Usage

Call `Components.DatePicker` with a scope and a table of properties:

```luau
scope:DatePicker({
	Value = "2026-08-14", -- (1)!
	OnChanged = function(date)
		print("Picked", date)
	end,
})
```

1.  Dates are strings in the form `YYYY-MM-DD`. Without a `Value`, the picker starts on today.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Value` | `UsedAs<string>?, -- YYYY-MM-DD` | :white_check_mark: | Today | The date as `YYYY-MM-DD`. A plain value is only the starting date. A `Value` is followed, and is set when the user picks a day. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (string) -> ()` | Runs with the date as `YYYY-MM-DD` when the user picks a day. |

## See also

- [TimePicker](./TimePicker.md)
