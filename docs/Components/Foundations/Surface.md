---
tags:
  - Foundations
  - Components
---

# Surface

Surface is a rounded frame with a fill. Use it as the background of a panel. [Sheet](./Sheet.md) is a Surface that is always elevated.

## Usage

Call `Components.Surface` with a scope and a table of properties:

```luau
scope:Surface({
	Size = UDim2.fromOffset(240, 120),
	Elevated = true,
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
| `Name` | `string` | :x: | `"Surface"` | Name of the frame. |
| `Elevated` | `boolean` | :x: | `false` | Use the `SurfaceContainerHigh` colour instead of `Surface`, so the panel stands out from a plain background. |

## See also

- [Sheet](./Sheet.md)
- [Card](./Card.md)
