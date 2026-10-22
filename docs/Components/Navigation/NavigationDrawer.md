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

## Docking

Set `DockAt` to a width in pixels. When the drawer's parent is at least that wide, the drawer stays open beside the content, like the sidebar of a desktop app. There is no scrim, and the drawer does not close. Below that width it slides in over the content as before.

```luau
scope:NavigationDrawer({
	Layer = overlayLayer,
	Open = open,
	DockAt = 640,
	OnDockChanged = function(docked)
		menuButtonVisible:set(not docked) -- (1)!
	end,
})
```

1.  A docked drawer needs no menu button, so use `OnDockChanged` to hide it.

Inside a [Window](./Window.md), the app bar and the content move over to make room, so put the drawer in the window's `Overlays` or on its layer. Pressing a row does not run `OnClose` while the drawer is docked.

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
| `RootPage` | `string` | :x: | - | Id of the first page when `Children` has several [MenuPage](../Overlays/MenuPage.md)s. |
| `Page` | `UsedAs<string>` | :x: | - | Id of the page to show. Follows the state you pass. |
| `MaxHeight` | `number` | :x: | - | Largest height in pixels of the menu. When left out, the menu fills the height of the drawer. |
| `Header` | `Instance` | :x: | - | Content above the menu, such as window buttons or a profile. Give it a fixed height. When there is a header, the rows are the taller 44 px rows. |
| `Footer` | `Instance` | :x: | - | Content below the menu, pinned to the bottom, such as a profile. Give it a fixed height. |
| `DockAt` | `number` | :x: | - | Width in pixels of the parent from which the drawer stays open beside the content. When left out, the drawer never docks. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClose: () -> ()` | Runs when the user dismisses the drawer, by pressing the scrim or the close row. |
| `OnChanged: (string) -> ()` | Runs with the id of the page when the user moves between pages. |
| `OnDockChanged: (boolean) -> ()` | Runs with `true` when the drawer docks and `false` when it floats again. |

## See also

- [Menu](../Overlays/Menu.md)
- [Window](./Window.md)
