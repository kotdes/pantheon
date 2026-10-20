---
tags:
  - Foundations
  - Components
---

# Sheet

Sheet is a [Surface](./Surface.md) that is always elevated. Windows and bottom sheets use it as their background.

## Usage

Call `Components.Sheet` with a scope and a table of properties:

```luau
scope:Sheet({
	Size = UDim2.fromOffset(320, 200),
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Name` | `string` | :x: | `"Sheet"` | Name of the frame. |

## See also

- [Surface](./Surface.md)
