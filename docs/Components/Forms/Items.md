---
tags:
  - Forms
  - Components
---

# Items

The input rows are a [ListItem](./ListItem.md) with an input in its [slot](./ListItem.md#slot). Put them in an [ListItemGroup](./ListItemGroup.md).

When `Value` is a Fusion state, the row sets it when the input changes. `OnChanged` runs as well.

## Usage

```luau
scope:ItemSelect({
	Icon = "type",
	Title = "Font",
	Mode = "Prompt",
	Layer = layer,
	Value = font,
	Options = {
		{ Value = "montserrat", Label = "Montserrat" },
		{ Value = "inter", Label = "Inter" },
	},
})
```

## The rows

| Component | Default mode | Other modes | Notes |
| --------- | ------------ | ----------- | ----- |
| `ItemSwitch` | Inline, trailing | - | Pressing the row flips the switch. |
| `ItemCheckbox` | Inline, trailing | - | Pressing the row flips the box. |
| `ItemSlider` | Inline, trailing, fill | - | `TitleWidth` is 112 so sliders line up. A value text at the end. `Min`, `Max`, `Step`, `Format`. A range of 0 to 1 shows a percentage. |
| `ItemSelect` | Inline (a `Select`, 160 pixels wide) | `Prompt`, `Accordion`, `Page` | The other modes show one row for each option, with a check. Choosing one sets the value and closes. The current label is at the end of the row. |
| `ItemRadio` | Accordion | `Inline`, `Prompt`, `Page` | The same option rows as `ItemSelect`. |
| `ItemText` | Inline, below | `Prompt`, `Accordion`, `Page` | A `TextField`. `Multiline`, `Placeholder`. The text is at the end of the row. |
| `ItemNumber` | Inline, trailing | `Prompt` | A `NumberField`. `Min`, `Max`, `Step`, `Decimals`, `Suffix`. |
| `ItemColour` | Prompt | `Accordion`, `Page` | A `ColorPicker`. A swatch is at the end of the row. |
| `ItemSegmented` | Inline, below | - | A `ChoiceGroup` with `Variant = "Segmented"`. |

## Properties

Every row takes these.

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent layout. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the row. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the row is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the row. |
| `Title` | `UsedAs<string>` | :white_check_mark: | - | Main text of the row. |
| `Subtitle` | `UsedAs<string>` | :x: | - | Smaller text under the title. |
| `Icon` | `string` | :x: | - | Name of a Lucide icon at the start of the row. |
| `Value` | `UsedAs<T>` | :white_check_mark: | - | The value. `boolean` for a switch or a checkbox, `number` for a slider or a number, `string` for a choice or text, `Color3` for a colour. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the row reacting to input. |
| `Layer` | `Instance` | :x: | - | Layer for sheets and dropdowns. Needed by `Prompt` and `Page` modes and by an inline `ItemSelect`. |
| `Mode` | `"Inline" \| "Accordion" \| "Prompt" \| "Page"` | :x: | See the table | Where the input shows. Not on `ItemSwitch`, `ItemCheckbox`, `ItemSlider` or `ItemSegmented`. |
| `Detent` | `number` | :x: | `0.7` | Height of the sheet, from 0 to 1. |
| `Options` | `{ { Value: string, Label: string } }` | :white_check_mark: | - | The choices of `ItemSelect`, `ItemRadio` and `ItemSegmented`. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (value) -> ()` | Runs when the input changes. |
| `OnPage: (title, build) -> ()` | Runs when a `Page` mode row is pressed, so the host can show a page. |

## See also

- [ListItemGroup](./ListItemGroup.md)
- [ListItem](./ListItem.md)
