---
tags:
  - Navigation
  - Components
---

# NavigationRail

NavigationRail is a set of destinations along the side of a screen. Set `Orientation = "Horizontal"` and it becomes a bar along the bottom. A pill slides and stretches to the chosen destination.

## Usage

Call `Components.NavigationRail` with a scope and a table of properties:

```luau
scope:NavigationRail({
	Items = {
		{ Id = "home", Icon = "home", Label = "Home" },
		{ Id = "library", Icon = "library", Label = "Library" },
	},
	Leading = scope:IconButton({ Name = "menu", OnClick = openDrawer }), -- (1)!
	OnChanged = function(id)
		print("Go to", id)
	end,
})
```

1.  `Leading` is only used by a vertical rail. In a [Window](./Window.md) the rail is full height, so the leading control is at the top.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Leading` | `Instance` | :x: | - | Vertical rails only. A control above the items, such as a menu button. |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Layer` | `Instance` | :x: | The layer from `Layer.Provide` or `Layer.bind` | Overlay layer that floating content is mounted in. See [Overlay layers](../../Guides/OverlayLayers.md). |
| `Items` | `{ { Id: string, Icon: string?, Label: string?, OnClick: (() -> ())? } }` | :white_check_mark: | - | The destinations. Each has an `Id`, and can have an `Icon`, a `Label` and an `OnClick`. A vertical rail shows icons only, with a tooltip. |
| `Selected` | `UsedAs<string>` | :x: | The first item | `Id` of the selected destination. A plain value is only the starting destination. A `Value` is followed, and is set when the user picks one. |
| `Orientation` | `"Vertical" \| "Horizontal"` | :x: | `"Vertical"` | `"Vertical"` for a rail at the side, `"Horizontal"` for a bar along the bottom. |
| `Shadow` | `boolean` | :x: | `true` | Set `false` to remove the shadow. |
| `Id` | `string` | :x: | - | Key that identifies this component when state is kept across rebuilds. See [Persist](../../Guides/PersistingState.md). |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (string) -> ()` | Runs with the `Id` of the destination the user picked. |

## See also

- [Window](./Window.md)
- [NavigationDrawer](./NavigationDrawer.md)
- [AppBar](./AppBar.md)
