---
tags:
  - Foundations
  - Components
---

# Badge

Badge adds a small red marker to the corner of another element. The marker shows a count or a dot. The count stops at 99.

## Usage

Call `Components.Badge` with a scope and a table of properties:

```luau
scope:Badge({
	Count = unread, -- (1)!
	Content = scope:IconButton({ Name = "bell" }),
})
```

1.  The component reads `Count` once. A count of `0` shows no marker. Set `Dot` to `true` to show a dot instead of a number.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Content` | `Instance` | :white_check_mark: | - | The element to attach the badge to. |
| `Count` | `UsedAs<number>` | :x: | - | Number to show in the marker. Anything above 99 shows as `99`. |
| `Dot` | `boolean` | :x: | `false` | Show a dot instead of a number. |
