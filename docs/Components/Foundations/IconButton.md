---
tags:
  - Foundations
  - Components
---

# IconButton

IconButton is a round button that shows only an icon. Use it for toolbar actions where a text label would take up too much room.

## Usage

Call `Components.IconButton` with a scope and a table of properties:

```luau
scope:IconButton({
	Name = "settings", -- (1)!
	Variant = "Tonal",
	OnClick = function()
		print("Open settings")
	end,
})
```

1.  `Name` is the name of a [Lucide](https://lucide.dev/icons) icon. To use your own image, set `Image` instead.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Name` | `string` | :x: | - | Name of a Lucide icon. |
| `Image` | `string` | :x: | - | Asset ID of an image to use instead of a Lucide icon. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the button reacting to input and dims it. The component reads this once, when it creates the button. |
| `Variant` | `string` | :x: | `"Text"` | Style of the button. It takes the same values as [Button](./Button.md). |
| `Color` | `UsedAs<ColorInput>` | :x: | - | Colour of the button. It takes the same values as [Button](./Button.md). |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClick: () -> ()` | Runs when the user activates the button. It does not run while `Disabled` is `true`. |

## See also

- [Button](./Button.md)
- [Icon](./Icon.md)
