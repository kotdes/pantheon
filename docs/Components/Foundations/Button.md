---
tags:
  - Foundations
  - Components
---

# Button

Use Button to let the user start an action. It has four styles. You can add an icon before or after the label.

<div class="es-preview" data-component="Button"></div>

## Usage

Call `Components.Button` with a scope and a table of properties:

```luau
scope:Button({
	Text = "Save",
	Variant = "Filled", -- (1)!
	LeadingIcon = "save", -- (2)!
	OnClick = function()
		print("Saved")
	end,
})
```

1.  `Variant` is `"Filled"`, `"Tonal"`, `"Outlined"` or `"Text"`. The older names `"Primary"` and `"Destructive"` still work. They give a filled button in the `primary` or `error` colour.
2.  `LeadingIcon` and `TrailingIcon` take the name of a [Lucide](https://lucide.dev/icons) icon.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Text` | `UsedAs<string>` | :x: | `"Button"` | Label of the button. |
| `Variant` | `ButtonVariant \| string` | :x: | `"Text"` | Style of the button: `"Filled"`, `"Tonal"`, `"Outlined"` or `"Text"`. `"Primary"` and `"Destructive"` are older names for a filled button in the `primary` or `error` colour. |
| `Color` | `UsedAs<ColorInput>` | :x: | `"primary"` | Colour of the button. Use a palette name such as `"primary"` or `"error"`, a `Color3`, a hex string, an RGB table or a `ThemeColorRole`. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the button reacting to input and dims it. The component reads this once, when it creates the button. |
| `Icon` | `string` | :x: | - | Same as `LeadingIcon`. |
| `LeadingIcon` | `string` | :x: | - | Lucide icon shown before the label. |
| `TrailingIcon` | `string` | :x: | - | Lucide icon shown after the label. |
| `HorizontalAlignment` | `Enum.HorizontalAlignment` | :x: | - | Where the icon and label sit in the button. They are centred by default. |
| `CornerRadius` | `number` | :x: | `Metrics.RadiusPill` | Corner radius, in pixels. |
| `Padding` | `{ number }` | :x: | `Metrics.ButtonPadY`, `Metrics.ButtonPadX` | Padding around the content, in pixels, as `{ vertical, horizontal }`. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClick: () -> ()` | Runs when the user activates the button. It does not run while `Disabled` is `true`. |

## See also

- [IconButton](./IconButton.md)
- [Chip](./Chip.md)
