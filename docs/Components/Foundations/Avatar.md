---
tags:
  - Foundations
  - Components
---

# Avatar

Avatar shows a round profile picture. If there is no picture, it shows initials.

## Usage

Call `Components.Avatar` with a scope and a table of properties:

```luau
scope:Avatar({
	Initials = "EU",
	AvatarSize = 48,
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Image` | `string` | :x: | - | Asset ID of the picture. If you set it, the initials are hidden. |
| `Initials` | `string` | :x: | `"?"` | Text to show when there is no `Image`. |
| `AvatarSize` | `number` | :x: | `40` | Diameter, in pixels. |

## See also

- [AvatarMenu](../Overlays/AvatarMenu.md)
