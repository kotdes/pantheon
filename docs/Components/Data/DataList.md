---
tags:
  - Data
  - Components
---

# DataList

DataList is a group of rows on a card, with an optional heading. It puts a divider between the rows. The card is a [container](../../Theming/Corners.md#concentric-corners), so the rows round themselves to fit it.

Use it with the data rows: [DataRow](./DataRow.md), `DataToggle`, `DataLink`, `DataSlider` and `DataSegmented`. A [ListItem](../Forms/ListItem.md) fits in it too. All of them have the same type, padding and states, so a settings page and a list of commands look alike.

## Usage

```luau
scope:DataList({
	Heading = "Sounds",
	Children = {
		scope:DataToggle({
			Icon = "bell",
			Title = "Notification sounds",
			Summary = "Play a sound when a message appears.",
			Value = notices,
		}),
		scope:DataSlider({ Title = "Volume", Value = volume }),
	},
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | The width of the parent | Size of the component. The height follows the rows. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Heading` | `UsedAs<string>` | :x: | - | Name of the group, over the card. It is hidden while it is empty. |
| `Children` | `{ Instance }` | :x: | - | The rows. DataList sets their `LayoutOrder`. |
| `CornerRadius` | `number` | :x: | `RadiusMd` | Radius of the card in pixels. |

## See also

- [DataRow](./DataRow.md)
- [ListItem](../Forms/ListItem.md)
