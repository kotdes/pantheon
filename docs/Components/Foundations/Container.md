---
tags:
  - Foundations
  - Components
---

# Container

Container centres its content and stops it getting wider than `MaxWidth`. Use it for page content on wide screens.

## Usage

Call `Components.Container` with a scope and a table of properties:

```luau
scope:Container({
	MaxWidth = 720,
	Children = { scope:Text({ Text = "Page content" }) },
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | `UDim2.fromScale(1, 1)` | Size of the component. |
| `MaxWidth` | `number` | :x: | `960` | Widest the content can be, in pixels. |
| `Children` | `any` | :x: | - | Content of the container. |
