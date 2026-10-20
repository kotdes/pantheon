---
tags:
  - Foundations
  - Components
---

# Text

Text shows text in one of the type scales of the theme. It sizes itself to fit the text.

## Usage

Call `Components.Text` with a scope and a table of properties:

```luau
scope:Text({
	Text = "Recent activity",
	Variant = "Title", -- (1)!
})
```

1.  `Variant` is a key of `theme.Typography`: `"Display"`, `"Headline"`, `"Title"`, `"Button"`, `"Body"`, `"Label"` or `"Mono"`, or one you added with `Theme.create`. If the name does not exist, the component uses `"Body"`.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Text` | `UsedAs<string>` | :white_check_mark: | - | The text to show. |
| `Variant` | `TextVariant` | :x: | `"Body"` | Type scale to use. |
| `Color` | `UsedAs<Color3>` | :x: | `Colors.OnSurface` | Colour of the text. |
| `TextXAlignment` | `Enum.TextXAlignment` | :x: | `Enum.TextXAlignment.Left` | Horizontal alignment of the text. |
| `TextWrapped` | `boolean` | :x: | `false` | Wrap the text onto several lines. The text needs a fixed width to wrap, from `Size` or from its parent. |

## See also

- [Theme](../../Modules/Theme.md)
