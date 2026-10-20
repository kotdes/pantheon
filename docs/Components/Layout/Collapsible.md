---
tags:
  - Layout
  - Components
---

# Collapsible

Collapsible has a title row that shows and hides its content when pressed. The arrow turns and the content fades in.

## Usage

Call `Components.Collapsible` with a scope and a table of properties:

```luau
scope:Collapsible({
	Title = "Advanced",
	Open = false,
	Children = {
		scope:Switch({ Label = "Debug mode" }),
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
| `Title` | `UsedAs<string>` | :white_check_mark: | - | Text of the title row. |
| `Open` | `UsedAs<boolean>` | :x: | `false` | Whether the content is shown. A plain value is only the starting state. A `Value` is followed, and is set when the user opens or closes it. |
| `Children` | `any` | :x: | - | The content that is shown and hidden. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (boolean) -> ()` | Runs with the new state when the user opens or closes it. |

## See also

- [TreeView](./TreeView.md)
