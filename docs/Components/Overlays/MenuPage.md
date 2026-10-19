---
tags:
  - Overlays
  - Components
---

# MenuPage

MenuPage is a named page inside a [Menu](./Menu.md). Pages slide when the user moves between them. A page with a `Title` gets a back control.

## Usage

Call `Components.MenuPage` with a scope and a table of properties:

```luau
scope:Menu({
	Layer = overlayLayer,
	Children = {
		scope:MenuPage({ Id = "root", Children = {
			scope:MenuButton({ Text = "Language", Page = "language" }),
		} }),
		scope:MenuPage({ Id = "language", Title = "Language", Children = {
			scope:MenuButton({ Text = "English" }),
		} }),
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
| `Id` | `string` | :white_check_mark: | - | Name of the page. A [MenuButton](./MenuButton.md) opens the page by this name. |
| `Title` | `UsedAs<string>` | :x: | - | Title of the bar at the top of the page. A page with a title also gets a back control. |
| `Children` | `any` | :x: | - | Content of the page. |

## See also

- [Menu](./Menu.md)
