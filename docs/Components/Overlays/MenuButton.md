---
tags:
  - Overlays
  - Components
---

# MenuButton

MenuButton is one row of a [Menu](./Menu.md), with an icon or element at each end. It can run an action, or move to another page of the menu.

## Usage

Call `Components.MenuButton` with a scope and a table of properties:

```luau
scope:MenuButton({
	Text = "Settings",
	LeadingIcon = "settings",
	Page = "settings", -- (1)!
})
```

1.  `Page` is the `Id` of a [MenuPage](./MenuPage.md). Pressing the row moves to that page and does not close the menu.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Text` | `UsedAs<string>` | :white_check_mark: | - | Label of the row. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the row reacting to input. Read once, when it is created. |
| `Leading` | `MenuSlot` | :x: | - | A Lucide icon name or an instance shown before the label. |
| `Trailing` | `MenuSlot` | :x: | - | A Lucide icon name or an instance shown after the label. |
| `LeadingIcon` | `string` | :x: | - | Same as `Leading` when it is an icon name. |
| `TrailingIcon` | `string` | :x: | - | Same as `Trailing` when it is an icon name. |
| `Color` | `UsedAs<ColorInput>` | :x: | `Colors.OnSurface` | Tint of the label and the icons, such as `"error"`. |
| `Page` | `string` | :x: | - | Id of a [MenuPage](./MenuPage.md) to move to when pressed. |
| `Selected` | `UsedAs<boolean>` | :x: | `false` | Marks the row as the current choice. It is filled with the primary container colour. It follows a state, so the row changes when the state does. |
| `Compact` | `boolean` | :x: | `true` | Use the 40 px row. Set `false` for the taller 44 px row of a header menu. |
| `Children` | `any` | :x: | - | Content placed in the row. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClick: () -> ()` | Runs when the row is pressed. |
| `OnClose: () -> ()` | Called after `OnClick`. A [Menu](./Menu.md) sets it for rows built from `Items` and `Sections`. |

## See also

- [Menu](./Menu.md)
- [MenuSection](./MenuSection.md)
