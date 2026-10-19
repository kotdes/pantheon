---
tags:
  - Navigation
  - Components
---

# NavigationDrawer

NavigationDrawer is a panel that slides in from the side. It has a profile header on top and a menu below. It is built on [Menu](../Overlays/Menu.md), so it takes the same items and sections.

## Usage

Call `Components.NavigationDrawer` with a scope and a table of properties:

```luau
local open = scope:Value(false)

scope:NavigationDrawer({
	Open = open,
	Title = "Ada Lovelace",
	Subtitle = "ada@example.com",
	AvatarInitials = "AL",
	Items = {
		{ Text = "Inbox", Icon = "inbox" },
		{ Text = "Settings", Icon = "settings" },
	},
	OnClose = function()
		open:set(false)
	end,
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Open` | `UsedAs<boolean>` | :x: | - | Whether the drawer is shown. Follows the state you pass. The drawer is open when this is left out. |
| `Title` | `UsedAs<string>` | :x: | - | Main text of the header. |
| `Subtitle` | `UsedAs<string>` | :x: | - | Smaller text under the title. |
| `AvatarImage` | `string` | :x: | - | Asset ID of the picture in the header. |
| `AvatarInitials` | `string` | :x: | - | Initials shown when there is no picture. |
| `Items` | `{ any }` | :x: | - | Menu rows. See [MenuButton](../Overlays/MenuButton.md). Use `Sections` when the rows have categories. |
| `Sections` | `{ MenuSectionProps }` | :x: | - | Groups of rows with optional category titles. See [MenuSection](../Overlays/MenuSection.md). |
| `Children` | `any` | :x: | - | Menu content built from [MenuPage](../Overlays/MenuPage.md), [MenuSection](../Overlays/MenuSection.md) and [MenuButton](../Overlays/MenuButton.md), as an alternative to `Items`. |
| `Inset` | `number` | :x: | `0` | Gap in pixels between the drawer and the edge of its parent. Use `4` inside a Window. |
| `CornerRadius` | `number` | :x: | `Metrics.RadiusPanel`, or `Metrics.RadiusPanel + 4` when inset | Corner radius of the panel in pixels. |
| `InitialPage` | `string` | :x: | - | Id of the first page when `Children` has several [MenuPage](../Overlays/MenuPage.md)s. |
| `Page` | `UsedAs<string>` | :x: | - | Id of the page to show. Follows the state you pass. |
| `MaxHeight` | `number` | :x: | - | Largest height in pixels of the menu. When left out, the menu fills the height of the drawer. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClose: () -> ()` | Runs when the user dismisses the drawer, by pressing the scrim or the close row. |
| `OnPageChanged: (string) -> ()` | Runs with the id of the page when the user moves between pages. |

## See also

- [Menu](../Overlays/Menu.md)
- [Window](./Window.md)
