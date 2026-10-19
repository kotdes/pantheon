---
tags:
  - Layout
  - Components
---

# SplitPane

SplitPane puts several panes next to each other, or one above the other, with a draggable divider between each pair. Panes can contain more split panes.

## Usage

Call `Components.SplitPane` with a scope and a table of properties:

```luau
scope:SplitPane({
	Panes = { explorer, viewport, properties }, -- (1)!
	Ratios = { 1, 3, 1 },
	MinSize = 120,
	OnResized = function(ratios)
		print(ratios)
	end,
})
```

1.  Each pane is sized to fill its part of the split. They can be any `GuiObject`, including another `SplitPane`.

## Dividers

Drag a divider to move it. The panes next to it grow and shrink, and no pane gets smaller than `MinSize`. Press a divider twice quickly to put the panes back to their starting sizes. A divider can also be focused with Tab and moved with the arrow keys.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Id` | `string` | :x: | - | Key that identifies this component when state is kept across rebuilds. See [Persist](../../Guides/PersistingState.md). |

## See also

- [DockPanel](./DockPanel.md)
- [Window](../Navigation/Window.md)
