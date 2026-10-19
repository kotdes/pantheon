---
tags:
  - Layout
  - Components
---

# TreeView

TreeView shows nested items, such as files or an object hierarchy. Branches open and close with a spring, and the arrow turns.

## Usage

Call `Components.TreeView` with a scope and a table of properties:

```luau
scope:TreeView({
	Nodes = {
		{
			Id = "src",
			Label = "src",
			Children = {
				{ Id = "init", Label = "init.luau", Icon = "file" },
			},
		},
	},
	OnSelect = function(id)
		print("Selected", id)
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
| `Nodes` | `{ TreeNode }` | :white_check_mark: | - | The top level items. Each has an `Id` and a `Label`, and can have an `Icon` and `Children`, a list of nodes. |
| `Expanded` | `UsedAs<{ [string]: boolean }>` | :x: | `{}` | The open branches, as a table from `Id` to `true`. A plain table is only the starting set. A `Value` is followed, and is set when a branch opens or closes. |
| `Selected` | `UsedAs<string>` | :x: | `""` | `Id` of the selected node. A plain value is only the starting selection. A `Value` is followed, and is set when the user picks a node. |
| `Id` | `string` | :x: | - | Key that identifies this component when state is kept across rebuilds. See [Persist](../../Guides/PersistingState.md). |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnSelect: (id: string) -> ()` | Runs with the `Id` of the node the user picked. |
| `OnToggle: (id: string, expanded: boolean) -> ()` | Runs with the `Id` of a branch and whether it is now open. |

## See also

- [Collapsible](./Collapsible.md)
