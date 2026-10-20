---
tags:
  - Forms
  - Components
---

# RangeSlider

RangeSlider is one track with two handles. The user chooses a range of values, not a single value. The part of the track between the handles is filled. Press the track to move the nearer handle there, or drag a handle. The handles never cross. A focused slider moves the handle used last with the arrow keys.

## Usage

Call `Components.RangeSlider` with a scope and a table of properties:

```luau
scope:RangeSlider({
	Min = 0,
	Max = 100,
	Value = NumberRange.new(20, 60),
	OnChanged = function(range)
		print(range.Min, range.Max)
	end,
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Value` | `UsedAs<NumberRange>` | :x: | `NumberRange.new(Min, Max)` | The range. A plain value is only the starting range. A `Value` stays in step with the control: the user's changes set it, and setting it changes the control. |
| `Min` | `number` | :x: | `0` | Lowest value. |
| `Max` | `number` | :x: | `1` | Highest value. |
| `Step` | `number` | :x: | `0.01` | Values snap to multiples of this. |
| `Label` | `UsedAs<string>` | :x: | - | Text above the track, followed by the range. |
| `Disabled` | `UsedAs<boolean>` | :x: | - | Stops the handles reacting to input. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (NumberRange) -> ()` | Runs with the new range as the user drags. |

## See also

- [Slider](./Slider.md)
