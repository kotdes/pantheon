---
tags:
  - Forms
  - Components
---

# SettingsList

SettingsList is a list of rows on rounded cards, like the Settings app on iOS. Each row has an icon and a title. It can also have a chevron or a control at the end.

## Usage

Call `Components.SettingsList` with a scope and a table of properties:

```luau
scope:SettingsList({
	Header = "Account",
	Items = {
		{ Title = "Profile", Icon = "user", ShowChevron = true, OnClick = openProfile },
		{ Title = "Notifications", Icon = "bell", Trailing = scope:Switch({}) },
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
| `Items` | `{ any }` | :x: | - | The rows. Each row needs a `Title`. It can also have a `Subtitle`, an `Icon`, a `Trailing` instance, `ShowChevron`, `OnClick` and `Disabled`. |
| `Header` | `UsedAs<string>` | :x: | - | Heading above the card. |
| `Footer` | `UsedAs<string>` | :x: | - | Small print under the card. |
| `Children` | `any` | :x: | - | Extra content to add under the rows. |
| `InsetGrouped` | `boolean` | :x: | `true` | Draw the rows on a rounded card with space around it. Set it to `false` for rows that run from edge to edge. |

## See also

- [ListItem](./ListItem.md)
