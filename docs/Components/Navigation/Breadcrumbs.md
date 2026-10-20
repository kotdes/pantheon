---
tags:
  - Navigation
  - Components
---

# Breadcrumbs

Breadcrumbs shows the path to the current page, with each step separated by a slash. The last step is the current page.

## Usage

Call `Components.Breadcrumbs` with a scope and a table of properties:

```luau
scope:Breadcrumbs({
	Items = {
		{ Label = "Home", OnClick = goHome },
		{ Label = "Settings", OnClick = goSettings },
		{ Label = "Profile" },
	},
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Items` | `{ BreadcrumbItem }` | :white_check_mark: | - | The steps. Each has a `Label` and an optional `OnClick`. |
