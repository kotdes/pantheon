---
tags:
  - Forms
  - Components
---

# Slider

Slider lets the user choose a number from a range by dragging a handle. The handle grows while the user presses it.

<div class="es-preview" data-component="Slider"></div>

## Usage

Call `Components.Slider` with a scope and a table of properties:

```luau
scope:Slider({
	Label = "Volume",
	Min = 0,
	Max = 100,
	Step = 1,
	Value = 40,
	OnChanged = function(value)
		print("Volume", value)
	end,
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Value` | `UsedAs<number>` | :x: | `Min` | The value. A plain value is only the starting value. A `Value` stays in step with the control: the user's changes set it, and setting it changes the control. |
| `Min` | `number` | :x: | `0` | Lowest value. |
| `Max` | `number` | :x: | `1` | Highest value. |
| `Step` | `number` | :x: | `0.01` | Size of one step. The value snaps to a multiple of it. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the slider reacting to input. The component reads this once, when it creates the slider. |
| `Label` | `UsedAs<string>` | :x: | - | Text above the slider. The current value appears after it, in brackets. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (number) -> ()` | Runs with the new value as the user drags. |

## See also

- [RangeSlider](./RangeSlider.md)
