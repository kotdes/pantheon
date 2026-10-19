---
tags:
  - Foundations
  - Components
---

# Divider

Divider is a line, one pixel thick, that separates content.

## Usage

Call `Components.Divider` with a scope and a table of properties:

```luau
scope:Divider({})
scope:Divider({ Vertical = true, Size = UDim2.new(0, 1, 0, 24) })
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | `UDim2.new(1, 0, 0, 1)`, or `UDim2.new(0, 1, 1, 0)` when vertical | Size of the component. |
| `Vertical` | `boolean` | :x: | `false` | Draw a vertical line instead of a horizontal one. |
