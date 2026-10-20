---
tags:
  - Feedback
  - Components
---

# EmptyState

EmptyState fills a screen or list that has nothing to show yet. It shows a message and, if you want, a button.

## Usage

Call `Components.EmptyState` with a scope and a table of properties:

```luau
scope:EmptyState({
	Title = "No messages",
	Subtitle = "New messages will show up here.",
	Action = { Text = "Compose", Variant = "Filled", OnClick = compose }, -- (1)!
})
```

1.  `Action` is a table of [Button](../Foundations/Button.md) properties.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Title` | `UsedAs<string>` | :white_check_mark: | - | Main message. |
| `Subtitle` | `UsedAs<string>` | :x: | - | Smaller text under the title. |
| `Action` | `ButtonProps` | :x: | - | Properties of a [Button](../Foundations/Button.md) to show under the text. |
