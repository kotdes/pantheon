---
tags:
  - Forms
  - Components
---

# ListItem

ListItem is a row with a title. It can also have a subtitle and an element at each end.

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
| `Leading` | `Instance` | :x: | - | Element at the start of the row, such as an Avatar or an Icon. |
| `Trailing` | `Instance` | :x: | - | Element at the end of the row. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the row reacting to input. The component reads this once, when it creates the row. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClick: () -> ()` | Runs when the user activates the row. |

## See also

- [SettingsList](./SettingsList.md)
- [Avatar](../Foundations/Avatar.md)
