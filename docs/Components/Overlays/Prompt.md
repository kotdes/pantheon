---
tags:
  - Overlays
  - Components
---

# Prompt

Prompt is a [Dialog](./Dialog.md) with a Cancel and a confirm button already set up. Use it for questions with a yes or no answer.

## Usage

Call `Components.Prompt` with a scope and a table of properties:

```luau
scope:Prompt({
	Layer = overlayLayer,
	Open = open,
	Title = "Discard changes?",
	ConfirmText = "Discard",
	Destructive = true,
	OnConfirm = discard,
	OnClose = function()
		open:set(false)
	end,
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
| `Layer` | `Instance` | :x: | The layer from `Layer.Provide` or `Layer.bind` | Overlay layer that floating content is mounted in. See [Overlay layers](../../Guides/OverlayLayers.md). |
| `Title` | `UsedAs<string>` | :white_check_mark: | - | Heading of the prompt. |
| `Body` | `UsedAs<string>` | :x: | - | Text under the heading. |
| `Actions` | `{ DialogAction }` | :x: | - | Buttons to use instead of the Cancel and confirm pair. |
| `Open` | `UsedAs<boolean>` | :x: | - | Whether the prompt is shown. Follows the state you pass. |
| `Children` | `any` | :x: | - | Custom content under the body. |
| `Icon` | `string` | :x: | - | Lucide icon above the title. |
| `IconColor` | `UsedAs<Color3>` | :x: | - | Colour of the icon. With `Destructive`, the icon is red unless this is set. |
| `IconSize` | `number` | :x: | - | Size of the icon in pixels. |
| `CornerRadius` | `number` | :x: | `Radius3xl` | Corner radius in pixels. A dialog is not concentric with its container, because it sits far from the edges and the corners would be nearly square. |
| `ConfirmText` | `string` | :x: | `"OK"` | Label of the confirm button. |
| `CancelText` | `string` | :x: | `"Cancel"` | Label of the cancel button. |
| `Destructive` | `boolean` | :x: | `false` | Make the confirm button red. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClose: () -> ()` | Runs when the user cancels or presses the scrim. |
| `OnConfirm: () -> ()` | Runs when the user presses the confirm button. When left out, `OnClose` is called. |

## See also

- [ConfirmDialog](./ConfirmDialog.md)
- [Dialog](./Dialog.md)
