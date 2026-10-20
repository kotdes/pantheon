---
tags:
  - Foundations
  - Components
---

# Icon

Icon draws a [Lucide](https://lucide.dev/icons) icon or any other image. It is an `ImageLabel`.

## Usage

Call `Components.Icon` with a scope and a table of properties:

```luau
scope:Icon({
	Name = "search",
	IconSize = 24,
	Color = theme.Colors.OnSurfaceVariant,
})
```

## Unknown icons

If `Name` is not a Lucide icon, the component warns `unknown Lucide icon` and draws nothing.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | `UDim2.fromOffset(IconSize, IconSize)` | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Name` | `string?, -- Lucide icon id` | :white_check_mark: | - | Name of a Lucide icon. |
| `Image` | `string` | :x: | - | Asset ID of an image. It takes priority over `Name`. |
| `Color` | `UsedAs<Color3>` | :x: | `Colors.OnSurface` | Colour of the icon. |
| `IconSize` | `number` | :x: | `24` | Width and height, in pixels. The component ignores it if you set `Size`. |
| `AssetSize` | `number` | :x: | `48` | Resolution of the Lucide atlas to read the icon from, in pixels. Raise it for icons larger than 48 pixels. |

## See also

- [IconButton](./IconButton.md)
