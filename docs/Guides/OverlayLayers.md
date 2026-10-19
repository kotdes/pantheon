# Overlay layers

Dialogs, menus, popovers, tooltips, sheets, coach marks and toasts float over the rest of the interface. If they were built inside a layout, they would push their neighbours around. Pantheon mounts them on a layer instead: a transparent frame that covers the area they may appear in.

## Giving a component a layer

Pass the layer in the `Layer` property:

```luau
local overlayLayer = scope:Frame({
	Name = "OverlayLayer",
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	ZIndex = 50,
})

scope:Dialog({
	Layer = overlayLayer,
	Open = open,
	Title = "Delete file?",
})
```

The layer must be a `GuiObject`. Put it above your content, usually as the last child of your root frame.

## A layer for a whole build

`Layer.Provide` sets the layer for every component created while its function runs, so you do not have to pass it each time:

```luau
Pantheon.Layer.Provide(overlayLayer, function()
	scope:Dialog({ Open = open, Title = "Delete file?" })
	scope:Tooltip({ Target = button, Text = "Delete" })
end)
```

## Layers and windows

A [Window](../Components/Navigation/Window.md) makes a layer inside itself and mounts its `Overlays` there, so floating content moves with the window and follows its rounded corners. When a Window is created, it also sets its layer as the fallback for components that are created after it and that were not given a layer. Components that are created before the Window do not get it, so pass `Layer` to those.

## When there is no layer

A component that needs a layer and cannot find one does one of these:

- [Tooltip](../Components/Overlays/Tooltip.md) and the tooltips of [GradientPicker](../Components/Pickers/GradientPicker.md) are not shown.
- [Coachmark](../Components/Overlays/Coachmark.md) warns that no overlay layer was found.

See [Layer](../Modules/Layer.md).
