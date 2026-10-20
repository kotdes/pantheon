---
tags:
  - Overlays
  - Components
---

# AppSheet

AppSheet is a bottom sheet in the style of iOS. A panel slides up from the bottom edge over a scrim, with a grabber at the top.

## Usage

Call `Components.AppSheet` with a scope and a table of properties:

```luau
scope:AppSheet({
	Layer = overlayLayer,
	Open = open,
	Title = "Share",
	Children = { scope:Text({ Text = "Choose how to share." }) },
	OnClose = function()
		open:set(false)
	end,
})
```

## Scrolling and dragging

The content stacks in a list and scrolls when it is taller than the sheet.

Drag the grabber or the title bar to change the sheet:

- Drag up to expand it to the full height of its layer.
- Drag down to collapse an expanded sheet.
- Drag down far enough from the normal height and the sheet calls `OnClose`.

If `OnClose` does not close the sheet, it springs back. A sheet always opens at its normal height.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Open` | `UsedAs<boolean>` | :x: | - | Whether the sheet is shown. Follows the state you pass. |
| `Title` | `UsedAs<string>` | :x: | - | Title at the top of the sheet. |
| `Children` | `any` | :x: | - | Content of the sheet. |
| `Detent` | `number` | :x: | `0.92` | Normal height of the sheet as a fraction, from `0` to `1`, of the layer it is mounted on. Dragging up expands it to `1`. |
| `ShowGrabber` | `boolean` | :x: | `true` | Show the small handle at the top. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClose: () -> ()` | Runs when the user presses the scrim. |

## See also

- [Dialog](./Dialog.md)
- [Overlay](./Overlay.md)
