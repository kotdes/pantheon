---
tags:
  - Layout
  - Components
---

# Explorer

Explorer shows a tree of Instances, like the Explorer window of Studio. You can expand and collapse branches, filter, select several rows, rename and drag one instance onto another.

## Usage

Call `Components.Explorer` with a scope and a table of properties:

```luau
local filter = scope:Value("")
local picked = scope:Value({})

scope:Explorer({
	Roots = { workspace, game:GetService("ReplicatedStorage") },
	Filter = filter,
	Selected = picked,
	AllowReparent = true,
	OnActivate = function(instance)
		print("Open", instance:GetFullName())
	end,
})
```

## Rows

Each row has an arrow, an icon for the class and the name. The list is built from the instances that are showing, so a tree of any size scrolls through a [VirtualList](./VirtualList.md). The list follows the tree: instances that are added, removed or renamed appear in it.

## Selecting

A press selects a row. Hold Ctrl to add or remove one, or Shift to select the rows from the last one pressed. Two quick presses call `OnActivate`.

## Keyboard

Focus the Explorer with Tab. Then:

- Up and Down move the selection.
- Right opens a branch, or moves to its first child. Left closes it, or moves to its parent.
- Enter calls `OnActivate`.
- F2 renames the selected instance. Enter commits and Escape cancels.

## Filtering

With a `Filter`, the tree shows the instances whose name contains the text, and the branches that lead to them. Branches with a match are open. `Match` lets you match on more than the name, for example the class.

## Reparenting

With `AllowReparent`, drag a row onto another to make it the parent. An instance is never dropped onto itself or onto something inside it. Without `OnReparent`, the component sets `Parent` itself.

## See also

- [TreeView](./TreeView.md)
- [VirtualList](./VirtualList.md)
