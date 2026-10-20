---
tags:
  - Pickers
  - Components
---

# TimePicker

TimePicker chooses a time of day with two rollers, one for the hours and one for the minutes, like the time wheels of a phone. Drag or flick a roller, scroll over it, or click a number. The rollers wrap round: scrolling past 23 goes to 00.

## Usage

Call `Components.TimePicker` with a scope and a table of properties:

```luau
scope:TimePicker({
	Value = 9 * 3600 + 30 * 60, -- (1)!
	OnChanged = function(seconds)
		print("Picked", seconds)
	end,
})
```

1.  Times are a number of seconds after midnight. `9 * 3600 + 30 * 60` is 09:30.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Value` | `UsedAs<number>?, -- seconds from midnight` | :white_check_mark: | `0` | The time in seconds after midnight. A plain value is only the starting time. A `Value` is followed, and is set when the hours or minutes change. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (number) -> ()` | Runs with the time in seconds after midnight when the hours or minutes change. |

## See also

- [DatePicker](./DatePicker.md)
