---
tags:
  - Layout
  - Components
---

# VirtualList

!!! note

    All rows have the same height. A row is built when it comes into range and is not rebuilt when the data changes, so read state inside the row instead of building it from a plain value.

VirtualList shows a long list by building only the rows that are on screen, plus a few either side. It is a [ScrollArea](./ScrollArea.md), so it scrolls the same way.

## Usage

Call `Components.VirtualList` with a scope and a table of properties:

```luau
scope:VirtualList({
	Size = UDim2.new(1, 0, 0, 240),
	ItemCount = #names,
	ItemHeight = 40,
	RenderItem = function(rowScope, index) -- (1)!
		return rowScope:ListItem({ Title = names[index] })
	end,
})
```

1.  `RenderItem` gets a scope for the row and the index of the row. The scope is destroyed when the row scrolls out of range, so create everything for the row in it. Do not use the main scope.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | `UDim2.new(1, 0, 1, 0)` | Size of the component. |
| `ItemCount` | `UsedAs<number>` | :white_check_mark: | - | Number of rows. Pass a state to change it. |
| `ItemHeight` | `number` | :white_check_mark: | - | Height of a row in pixels. |
| `RenderItem` | `(scope: Scope, index: number) -> Instance` | :white_check_mark: | - | Builds the row for an index. |
| `Padding` | `number` | :x: | `0` | Gap between rows in pixels. |

## See also

- [ScrollArea](./ScrollArea.md)
- [DataTable](./DataTable.md)
