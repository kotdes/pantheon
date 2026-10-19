---
tags:
  - Overlays
  - Components
---

# Dialog

Dialog is a modal panel on a scrim. It asks the user for a decision or shows something that needs attention. Two actions sit side by side. Three or more are stacked.

## Usage

Call `Components.Dialog` with a scope and a table of properties:

```luau
local open = scope:Value(false)

scope:Dialog({
	Layer = overlayLayer, -- (1)!
	Open = open,
	Title = "Delete file?",
	Body = "This cannot be undone.",
	Actions = {
		{ Text = "Cancel", OnClick = function() open:set(false) end },
		{ Text = "Delete", Variant = "Filled", Color = "error" },
	},
	OnClose = function()
		open:set(false)
	end,
})
```

1.  Pass a `Layer` so the dialog does not push your content around. See [Overlay layers](../../Guides/OverlayLayers.md).

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Title` | `UsedAs<string>` | :white_check_mark: | - | Heading of the dialog. |
| `Body` | `UsedAs<string>` | :x: | - | Text under the heading. |
| `Actions` | `{ DialogAction }` | :x: | - | Buttons at the bottom. Each has a `Text`, and can have a `Variant`, a `Color` and an `OnClick`. They take the same values as [Button](../Foundations/Button.md). |
| `Open` | `UsedAs<boolean>` | :x: | - | Whether the dialog is shown. Follows the state you pass. |
| `Children` | `any` | :x: | - | Custom content under the body, such as a form. |
| `Icon` | `string` | :x: | - | Lucide icon above the title. |
| `IconColor` | `UsedAs<Color3>` | :x: | `Colors.OnSurfaceVariant` | Colour of the icon. |
| `IconSize` | `number` | :x: | `28` | Size of the icon in pixels. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClose: () -> ()` | Runs when the user presses the scrim. With no `Actions`, a single close button is added that calls it too. |

## See also

- [Prompt](./Prompt.md)
- [ConfirmDialog](./ConfirmDialog.md)
