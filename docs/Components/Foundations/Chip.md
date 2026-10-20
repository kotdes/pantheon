---
tags:
  - Foundations
  - Components
---

# Chip

Chip is a small pill for a filter, a tag or a choice. A selected chip is filled in.

## Usage

Call `Components.Chip` with a scope and a table of properties:

```luau
local selected = scope:Value(false)

scope:Chip({
	Text = "Pinned",
	Selected = selected,
	LeadingIcon = "pin",
	OnClick = function()
		selected:set(not peek(selected))
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
| `Text` | `UsedAs<string>` | :white_check_mark: | - | Label of the chip. |
| `Selected` | `UsedAs<boolean>` | :x: | `false` | Whether the chip is filled in. The component reads this once, when it creates the chip. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the chip reacting to input. |
| `LeadingIcon` | `string` | :x: | - | Lucide icon shown before the label. |
| `TrailingIcon` | `string` | :x: | - | Lucide icon shown after the label. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClick: () -> ()` | Runs when the user activates the chip. |

## See also

- [SegmentedControl](../Forms/SegmentedControl.md)
- [ChoiceGroup](../Forms/ChoiceGroup.md)
