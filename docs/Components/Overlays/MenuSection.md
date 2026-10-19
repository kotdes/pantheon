---
tags:
  - Overlays
  - Components
---

# MenuSection

MenuSection groups rows in a [Menu](./Menu.md) under an optional title. It can collapse.

## Usage

Call `Components.MenuSection` with a scope and a table of properties:

```luau
scope:MenuSection({
	Title = "Account",
	Icon = "user",
	Collapsible = true,
	Items = {
		{ Text = "Profile" },
		{ Text = "Sign out", Color = "error" },
	},
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
| `Title` | `UsedAs<string>` | :x: | - | Title above the group. |
| `Icon` | `string` | :x: | - | Lucide icon before the title. |
| `Items` | `{ any }` | :x: | - | Rows of the group. See [MenuButton](./MenuButton.md). Use `Children` to compose rows yourself. |
| `Children` | `any` | :x: | - | Rows and other content. |
| `Collapsible` | `boolean` | :x: | `false` | Let the user collapse the group by pressing the title. |
| `DefaultExpanded` | `boolean` | :x: | `true` | Whether a collapsible group starts open. |
| `Expanded` | `UsedAs<boolean>` | :x: | - | Whether the group is open. Follows the state you pass. |
| `Compact` | `boolean` | :x: | `true` | Use the 40 px rows. Set `false` for the taller 44 px rows. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnExpandedChanged: (boolean) -> ()` | Runs with the new state when the group opens or closes. |
| `OnClose: () -> ()` | Passed to the rows so that pressing one closes the menu. |

## See also

- [Menu](./Menu.md)
- [MenuButton](./MenuButton.md)
