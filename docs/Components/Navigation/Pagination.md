---
tags:
  - Navigation
  - Components
---

# Pagination

Pagination lets the user move between pages of content with previous and next buttons. A label between them shows the page and the page count.

## Usage

Call `Components.Pagination` with a scope and a table of properties:

```luau
scope:Pagination({
	PageCount = 12,
	Page = 1,
	OnChanged = function(page)
		print("Page", page)
	end,
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Page` | `UsedAs<number>` | :x: | `1` | The page, counted from `1`. A plain value is only the starting page. A `Value` is followed, and is set when the user changes page. |
| `PageCount` | `number` | :white_check_mark: | - | Number of pages. |
| `Id` | `string` | :x: | - | Key that identifies this component when state is kept across rebuilds. See [Persist](../../Guides/PersistingState.md). |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (number) -> ()` | Runs with the page the user picked. |
