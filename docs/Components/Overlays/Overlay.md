---
tags:
  - Overlays
  - Components
---

# Overlay

!!! warning

    The scrim is a `TextButton`. A panel on top of it must be a `GuiButton` too, or it will not stop clicks from reaching the scrim: setting `Active` on a frame is not enough.

Overlay is a full-size scrim that dims what is behind it and takes input. Dialogs, drawers and sheets are built on it.

## Usage

Call `Components.Overlay` with a scope and a table of properties:

```luau
scope:Overlay({
	OnClick = function()
		open:set(false)
	end,
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `Size` | `UsedAs<UDim2>` | :x: | `UDim2.fromScale(1, 1)` | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | `50` | Z index of the component. |
| `Transparency` | `number` | :x: | `0.35` | Background transparency of the scrim, from `0` to `1`. A higher number is lighter. |
| `CornerRadius` | `number` | :x: | `0`, or the window's | Corner radius of the scrim in pixels. Inside a [Window](../Navigation/Window.md) it takes the corner radius of the window when this is left out. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClick: () -> ()` | Runs when the scrim is pressed. |

## See also

- [Dialog](./Dialog.md)
- [AppSheet](./AppSheet.md)
