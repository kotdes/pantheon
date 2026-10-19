---
tags:
  - Layout
  - Components
---

# DockPanel

DockPanel is a panel with a header, for the docked areas of a tool. The header has a title or a row of tabs, and actions. The panel can collapse to its header.

## Usage

Call `Components.DockPanel` with a scope and a table of properties:

```luau
scope:DockPanel({
	Tabs = {
		{ Id = "props", Title = "Properties", Content = propertiesView },
		{ Id = "attrs", Title = "Attributes", Content = attributesView },
	},
	Collapsible = true,
	Size = UDim2.new(1, 0, 0, 240),
})
```

## Tabs or a title

With `Tabs`, the header is a row of tabs and the content of the selected one is shown. An underline slides to the selected tab. Without them, the header shows `Title` and the content is `Children`.

## Collapsing

With `Collapsible`, an arrow at the start of the header collapses the panel to the height of the header, and its content fades out. The panel shrinks from the `Size` you gave it. Use it in a layout that lets the neighbours take the freed space, such as a list layout.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Id` | `string` | :x: | - | Key that identifies this component when state is kept across rebuilds. See [Persist](../../Guides/PersistingState.md). |

## See also

- [SplitPane](./SplitPane.md)
- [Tabs](../Navigation/Tabs.md)
