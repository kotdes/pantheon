---
tags:
  - Forms
  - Components
---

# NumberSpinner

NumberSpinner shows a number and animates it when the number changes. It follows the style of `contentTransition(.numericText())` in SwiftUI. By default, a digit that changes slides, shrinks and blurs out while the new digit comes in.

## Usage

Call `Components.NumberSpinner` with a scope and a table of properties:

```luau
local count = scope:Value(1280)

scope:NumberSpinner({
	Value = count, -- (1)!
	Prefix = "$",
	Decimals = 2,
	TextSize = 36,
})

count:set(1534.5)
```

1.  `Value` is a state. The digits animate each time it changes.

## Styles

With `Style` set to `"Numeric"`, the default, each digit animates on its own. The columns start one after another, from left to right. The timing is based on measurements of the iOS animation, with more overshoot. Use `Speed` and `Bounce` to change it.

With `Style` set to `"Roll"`, each digit turns like an odometer wheel, through every digit between the old value and the new one. Use `SpringSpeed` and `SpringDamping` to change the spring.

## Size

The box has a fixed width, so the layout does not move when the number changes. `Digits` sets how many whole-number digits fit. The default is the number of digits in the starting value plus one, and at least four. Set `Width` to choose the width yourself.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Value` | `UsedAs<number>` | :white_check_mark: | - | The number to show. Digits animate when it changes. |
| `Decimals` | `number` | :x: | `0` | Digits after the decimal point. |
| `Grouping` | `boolean` | :x: | `true` | Add thousands separators. |
| `Prefix` | `string` | :x: | - | Text before the number. |
| `Suffix` | `string` | :x: | - | Text after the number. |
| `TextSize` | `number` | :x: | `28` | Size of the text, in pixels. |
| `FontFace` | `Font` | :x: | `Fonts.Body` | Font of the digits. |
| `Color` | `Color3` | :x: | `Colors.OnSurface` | Colour of the digits. |
| `DigitWidth` | `number` | :x: | `0.62 × TextSize` | Width of one digit column, in pixels. |
| `Digits` | `number` | :x: | The digits of the starting value + 1, at least `4` | Number of whole-number digits to leave room for. |
| `Width` | `number` | :x: | - | Fixed width of the box, in pixels. It overrides `Digits`. |
| `Style` | `"Numeric" \| "Roll"` | :x: | `"Numeric"` | `"Numeric"` or `"Roll"`. See Styles. |
| `Speed` | `number` | :x: | `1` | `"Numeric"` only. Playback speed. Below `1` is slower and above `1` is faster. |
| `Bounce` | `number` | :x: | `0.8` | `"Numeric"` only. How far the digits overshoot when they land. `0` is none and `1` is very bouncy. |
| `Padding` | `number` | :x: | `derived from the text size` | Padding around the digits, in pixels, to leave room for their movement and blur. The box clips at the padding. |
| `SpringSpeed` | `number` | :x: | `11` | `"Roll"` only. Speed of the spring. |
| `SpringDamping` | `number` | :x: | `0.6` | `"Roll"` only. Damping ratio of the spring. Below `1`, the digits overshoot. |
| `Align` | `Enum.HorizontalAlignment` | :x: | `Enum.HorizontalAlignment.Left` | Where the digits sit in the box. |
