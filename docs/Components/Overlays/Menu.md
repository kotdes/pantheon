---
tags:
  - Overlays
  - Components
---

# Menu

Menu is a panel of rows. It can be a flat list, have groups with titles, and have pages that slide in and out for submenus. Give it data with `Items` or `Sections`, or build it from [MenuSection](./MenuSection.md), [MenuButton](./MenuButton.md) and [MenuPage](./MenuPage.md).

## Usage

Call `Components.Menu` with a scope and a table of properties:

```luau
scope:Menu({
	Layer = overlayLayer,
	Open = open,
	Sections = {
		{
			Title = "Edit",
			Items = {
				{ Text = "Copy", Icon = "copy" },
				{ Text = "Paste", Icon = "clipboard" },
			},
		},
	},
	OnClose = function()
		open:set(false)
	end,
})
```

## Pages

To build a submenu, give the menu several [MenuPage](./MenuPage.md)s as `Children`. A [MenuButton](./MenuButton.md) with a `Page` moves to that page, and the pages slide when you push or pop. `RootPage` picks the first one. Pass a state as `Page` to control which page shows.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Items` | `{ any }` | :x: | - | A flat list of rows. See [MenuButton](./MenuButton.md). Used when there are no `Sections`. |
| `Sections` | `{ MenuSectionProps }` | :x: | - | Groups of rows with optional titles. See [MenuSection](./MenuSection.md). |
| `Open` | `UsedAs<boolean>` | :x: | `true` | Whether the menu is shown. It is shown when this is left out. |
| `Header` | `any` | :x: | - | Content above the list, such as a profile header. |
| `Children` | `any` | :x: | - | Menu content built from sections, buttons and pages. It is added after `Items` and `Sections`. |
| `MaxHeight` | `number` | :x: | - | Largest height of the list in pixels. It scrolls past that. |
| `Fill` | `boolean` | :x: | `false` | Let the list fill the rest of the height and scroll. Needs a fixed `Size`. |
| `CornerRadius` | `number` | :x: | `Metrics.RadiusPanel` | Corner radius of the panel in pixels. |
| `Padding` | `number` | :x: | `4` | Padding around the list in pixels. |
| `Embedded` | `boolean` | :x: | `false` | Do not mount on a layer. The parent places the menu, as [Popover](./Popover.md) and [AvatarMenu](./AvatarMenu.md) do. |
| `RootPage` | `string` | :x: | The first page | Id of the page to show first. |
| `Page` | `UsedAs<string>` | :x: | - | Id of the page to show. The menu moves to it when it changes. |
| `Corners` | `{ number }` | :x: | - | Radius of each corner as `{ topLeft, topRight, bottomLeft, bottomRight }`. Lets a docked panel round only some corners. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClose: () -> ()` | Runs when the user presses outside the menu or presses a row that closes it. |
| `OnChanged: (string) -> ()` | Runs with the id of the page when the user moves between pages. |

## See also

- [MenuSection](./MenuSection.md)
- [MenuButton](./MenuButton.md)
- [MenuPage](./MenuPage.md)
- [Popover](./Popover.md)
