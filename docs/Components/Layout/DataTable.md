---
tags:
  - Layout
  - Components
---

# DataTable

DataTable shows rows of data in columns. The user can sort by a column, and you can filter the rows. It builds only the rows in view, so long tables stay fast.

## Usage

Call `Components.DataTable` with a scope and a table of properties:

```luau
scope:DataTable({
	Columns = {
		{ Id = "name", Title = "Name", Sortable = true },
		{ Id = "role", Title = "Role", Width = 120 },
	},
	Rows = rows, -- (1)!
	Filter = search,
	OnSelect = function(index)
		print("Row", index)
	end,
})
```

1.  A row is a table from column `Id` to the value shown in that column. `Rows` can be a state, and the table updates when it changes.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Columns` | `{ DataTableColumn }` | :white_check_mark: | - | The columns. Each has an `Id` and a `Title`, and can have a `Width` and be `Sortable`. |
| `Rows` | `UsedAs<{ { [string]: any } }>` | :white_check_mark: | - | The rows to show, as a table or a state of one. |
| `RowHeight` | `number` | :x: | `48` | Height of a row in pixels. |
| `SortColumn` | `UsedAs<string>` | :x: | - | `Id` of the column the rows start sorted by. |
| `SortAscending` | `UsedAs<boolean>` | :x: | `true` | Whether the starting sort is ascending. |
| `Selected` | `UsedAs<{ [number]: boolean }>` | :x: | - | Reserved. Rows are not drawn as selected yet. |
| `Filter` | `UsedAs<string>` | :x: | - | Text to filter by. Rows with no value containing the text, in any case, are hidden. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnSort: (columnId: string, ascending: boolean) -> ()` | Runs with the column `Id` and the direction when the user changes the sort. |
| `OnSelect: (index: number, selected: boolean) -> ()` | Runs with the index of a row when the user presses it. |

## See also

- [VirtualList](./VirtualList.md)
