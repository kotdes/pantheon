---
tags:
  - Foundations
  - Components
---

# Card

Card puts related content on a raised surface. It can have a title and a subtitle.

## Usage

Call `Components.Card` with a scope and a table of properties:

```luau
scope:Card({
	Title = "Weekly report",
	Subtitle = "Updated today",
	Children = {
		scope:Text({ Text = "12 new sign-ups" }),
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
| `Title` | `UsedAs<string>` | :x: | - | Title at the top of the card. |
| `Subtitle` | `UsedAs<string>` | :x: | - | Smaller text under the title. |
| `Children` | `any` | :x: | - | Content to show under the title. |

## See also

- [Surface](./Surface.md)
- [Container](./Container.md)
