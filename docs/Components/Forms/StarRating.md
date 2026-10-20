---
tags:
  - Forms
  - Components
---

# StarRating

StarRating shows a score as stars. The user can change the score, or you can make it read-only.

## Usage

Call `Components.StarRating` with a scope and a table of properties:

```luau
scope:StarRating({
	Value = 3,
	Max = 5,
	OnChanged = function(stars)
		print("Rated", stars)
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
| `Value` | `UsedAs<number>` | :x: | `0` | The value. A plain value is only the starting value. A `Value` stays in step with the control: the user's changes set it, and setting it changes the control. |
| `Max` | `number` | :x: | `5` | Number of stars. |
| `ReadOnly` | `boolean` | :x: | `false` | Show the score only. The stars do not react to input. |
| `IconSize` | `number` | :x: | `24` | Size of one star, in pixels. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (number) -> ()` | Runs with the number of stars the user chose. |
