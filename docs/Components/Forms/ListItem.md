---
tags:
  - Forms
  - Components
---

# ListItem

ListItem is a row with a title. It can also have a subtitle and an element at each end. It can hold any control in a slot, and show it in the row, under the row, in a sheet or on a page. The [input rows](./Items.md) are built on it.

## Usage

Call `Components.ListItem` with a scope and a table of properties:

```luau
scope:ListItem({
	Title = "Ada Lovelace",
	Subtitle = "Last seen today",
	Leading = scope:Avatar({ Initials = "AL" }),
	OnClick = function()
		print("Open profile")
	end,
})
```

## Slot

`Slot` is a control that the row shows in one of four ways.

| `Slot.Mode` | What happens |
| ----------- | ------------ |
| `Inline` | The control sits in the row. `Placement = "Trailing"` (default) puts it at the end. `Placement = "Below"` puts it under the text. `Fill = true` makes a trailing control take the room that is left. |
| `Accordion` | Pressing the row opens the control under the row, with a height animation. A chevron turns. |
| `Prompt` | Pressing the row opens the control in an `AppSheet`. The item needs `Layer`. |
| `Page` | Pressing the row calls `OnPage(title, build)`, so the host shows a page. With no `OnPage`, it opens a sheet as `Prompt` does. |

| Field | Description |
| ----- | ----------- |
| `Build(scope, close)` | Makes the control. `close()` closes the accordion or the sheet. An inline slot is built at once. Every other mode builds the first time it opens, inside the theme of the item. |
| `Display` | An element at the end of the row while the control is closed, such as the current value or a colour swatch. |
| `Title` | Title of the sheet or page. Default is the title of the item. |
| `Detent` | Height of the sheet, from 0 to 1. Default `0.7`. |
| `Open` | Starts an accordion open. |

```luau
scope:ListItem({
	Icon = "type",
	Title = "Font",
	Layer = layer,
	Slot = {
		Mode = "Prompt",
		Display = scope:Text({ Text = "Montserrat" }),
		Build = function(inner, close)
			return inner:Select({ Options = fonts, Value = font, OnChanged = close })
		end,
	},
})
```

## Heights

With no `Size`, a row is 48 pixels high, or 56 with a subtitle. A flat row is 64, or 72 with a subtitle. A row with a control under the text, or with `Wrap`, is as tall as its content.

## A row of your own

If a row needs more than `ListItem` offers, such as controls under the text, build it yourself and read the same style so it looks the same. `Pantheon.ListItemStyle(theme)` gives the fonts, sizes, padding, radius and heights of a `ListItem`. `Pantheon.Interaction.bind` gives the hover and press states.

```luau
local style = Pantheon.ListItemStyle(theme)
local ix = Pantheon.Interaction.bind(scope, theme, { StateColor = theme.Colors.OnSurface })

local row = scope:TextButton({
	BackgroundColor3 = ix.fill(theme.Colors.Surface),
	Padding = { style.PaddingY, style.PaddingX },
	CornerRadius = style.Radius,
})
ix.wire(row)
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Title` | `UsedAs<string>` | :white_check_mark: | - | Main text of the row. |
| `Subtitle` | `UsedAs<string>` | :x: | - | Smaller text under the title. |
| `PaddingX` | `number` | :x: | `SpaceMd`, or `SpaceSm` when flat | Space at the left and right of the row, in pixels. |
| `Flat` | `boolean` | :x: | from the blueprint | A borderless row with no fill at rest, a bold title, and an icon in a 44 pixel round container. It shows a fill only when hovered or pressed. |
| `Value` | `UsedAs<string>` | :x: | - | Bold text at the end of the row, right-aligned, such as an amount. |
| `ValueSubtitle` | `UsedAs<string>` | :x: | - | Muted line under `Value`, such as a change. |
| `Icon` | `string` | :x: | - | Name of a Lucide icon at the start of the row. Use `Leading` for your own element. |
| `Wrap` | `boolean` | :x: | `false` | The text wraps and the row grows to fit. |
| `Below` | `Instance` | :x: | - | Element under the text, such as a slider. |
| `Slot` | `ListItemSlot` | :x: | - | A control that the row holds. See [Slot](#slot). |
| `TitleWidth` | `number` | :x: | - | Fixed width of the text, in pixels. Use it to line up the controls of rows that sit together. |
| `Chevron` | `boolean` | :x: | `false` | Shows a chevron at the end of the row. |
| `Layer` | `Instance` | :x: | - | Layer for the sheet of a `Prompt` or `Page` slot. |
| `Leading` | `Instance` | :x: | - | Element at the start of the row, such as an Avatar or an Icon. |
| `Trailing` | `Instance` | :x: | - | Element at the end of the row. |
| `Selected` | `UsedAs<boolean>` | :x: | - | Fills the row with the primary container colour, to show that it is chosen. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the row reacting to input. The component reads this once, when it creates the row. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClick: () -> ()` | Runs when the user activates the row. |
| `OnPage: (title, build) -> ()` | Runs when a `Page` slot is pressed. `build` is the `Build` of the slot. |

## See also

- [ListItemGroup](./ListItemGroup.md)
- [Items](./Items.md)
- [Avatar](../Foundations/Avatar.md)
