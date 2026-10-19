---
tags:
  - Forms
  - Components
---

# NumberField

NumberField is a text box for a number. The label at the start is a scrub handle. Drag it sideways to change the value without typing.

## Usage

Call `Components.NumberField` with a scope and a table of properties:

```luau
local x = scope:Value(0)

scope:NumberField({
	Label = "X", -- (1)!
	Value = x,
	Step = 1,
	Suffix = "px",
})
```

1.  The label is the scrub handle. If you do not set a `Label`, the user can only type in the field.

## Scrubbing

Drag the label to change the value. Hold Shift to change it 10 times faster, or Alt to change it 10 times slower. If the user presses the label without moving, the text box takes focus.

If you set both `Min` and `Max`, the speed is the range divided by 300 pixels. Otherwise the value changes by one step for every 4 pixels. Set `ScrubSpeed` to choose the speed yourself.

## Typing

Type a number and press Enter, or click away, to confirm it. If the text is not a number, the field goes back to the old value. While the box has focus, the Up and Down arrow keys change the value by `Step`. Shift and Alt change the speed in the same way.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Value` | `UsedAs<number>` | :x: | `Min`, or `0` | The number. A plain value is only the starting value. A `Value` is followed, and is set when the user changes the number. |
| `Min` | `number` | :x: | - | Lowest value. |
| `Max` | `number` | :x: | - | Highest value. |
| `Step` | `number` | :x: | `1` | Size of one step. The arrow keys and scrubbing change the value by this amount. |
| `Decimals` | `number` | :x: | As many as `Step` needs | Digits to show after the decimal point. |
| `Label` | `string` | :x: | - | Short text at the start of the field. Drag it sideways to change the value. |
| `Suffix` | `string` | :x: | - | Fixed text at the end of the field, such as a unit. |
| `ScrubSpeed` | `number` | :x: | See [Scrubbing](#scrubbing) | Change in value for each pixel of scrubbing. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the field reacting to input. The component reads this once, when it creates the field. |
| `Id` | `string` | :x: | - | Key that identifies this component when state is kept across rebuilds. See [Persist](../../Guides/PersistingState.md). |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (number) -> ()` | Runs with the new value when the user changes it. |

## See also

- [TextField](./TextField.md)
- [Slider](./Slider.md)
- [NumberSpinner](./NumberSpinner.md)
