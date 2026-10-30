---
tags:
  - Layout
  - Components
---

# Window

Window is a rounded app shell. It holds an app bar, a navigation rail, the content and a layer for overlays. It can be dragged by its app bar and resized from its edges.

## Usage

Call `Components.Window` with a scope and a table of properties:

```luau
scope:Window({
	Size = scope:Value(UDim2.fromOffset(640, 420)), -- (1)!
	Position = scope:Value(UDim2.fromScale(0.5, 0.5)),
	AnchorPoint = Vector2.new(0.5, 0.5),
	Draggable = true,
	Resizable = true,
	AppBar = scope:AppBar({ Title = "Catalog" }),
	NavigationRail = scope:NavigationRail({ Items = items }),
	Overlays = { overlayLayer }, -- (2)!
	Children = { content },
})
```

1.  Pass a `Value` as `Size` or `Position` and the window writes to it while it is dragged or resized, so the result survives a rebuild.
2.  Anything that floats, such as popovers, tooltips, dialogs and toasts, should be mounted on a layer inside the window. It then moves with the window and follows its rounded corners. See [Overlay layers](../../Guides/OverlayLayers.md).

## Layout

With a vertical rail, the rail runs the full height of the window. The app bar sits beside it and the content below the app bar. The rail is drawn above the app bar so its shadow falls on it. With a horizontal rail, the app bar is at the top and the rail along the bottom.

A window cannot clip to rounded corners, so the app bar and the rail round their own corners to match the window: with a vertical rail the rail takes the two left corners and the app bar the top right.

## Gradient bars

An app bar or footer with `Variant = "Gradient"` has a flat fill that fades out beyond the controls. The window then lets the content run behind the bar. Add padding at the top or bottom of the content so the first and last rows are clear of the bar when it is not scrolled.

## Docked drawer

A [NavigationDrawer](./NavigationDrawer.md) with `DockAt` stays open beside the content once the window is wide enough. The window moves its app bar and content over to make room, and moves them back when the drawer floats again. A side rail stays under the drawer.

## Dragging

The window is dragged by its app bar, or by `DragHandle` when there is no app bar. `DragBounds` decides how far it may go off screen.

## Resizing

Set `Resizable` to add handles on the edges and corners. Use `MinSize`, `MaxSize`, `ResizeRatio` and `ResizeSnap` to limit the size. `OnResized` is called on every step.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | `UDim2.fromScale(1, 1)` | Size of the component. |
| `Position` | `UsedAs<UDim2>` | :x: | `UDim2.fromScale(0, 0)` | Position of the window. Pass a `Value` to keep it after dragging or a rebuild. |
| `AnchorPoint` | `UsedAs<Vector2>` | :x: | `Vector2.new(0, 0)` | Anchor point of the window. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `AppBar` | `Instance` | :x: | - | An [AppBar](./AppBar.md) to put at the top. Dragging the window uses it as the handle. |
| `Footer` | `Instance` | :x: | - | A [Footer](./Footer.md) to put at the bottom. It sits above a bottom rail. |
| `DragHandle` | `Instance` | :x: | - | What to drag the window by when there is no `AppBar`, such as a strip along the top of your content. |
| `NavigationRail` | `Instance` | :x: | - | A [NavigationRail](./NavigationRail.md) for the side or the bottom. |
| `Children` | `any` | :x: | - | Main content. It fills the space beside and below the chrome. |
| `Overlays` | `{ Instance }` | :x: | - | Layers or panels that float over the content, such as a [NavigationDrawer](./NavigationDrawer.md). They are moved to the overlay layer of the window. |
| `RailOrientation` | `"Vertical" \| "Horizontal"` | :x: | - | Whether the rail is `"Vertical"` or `"Horizontal"`. Set this to match `NavigationRail.Orientation`. When left out it is guessed from the size of the rail. |
| `CornerRadius` | `number` | :x: | `Metrics.RadiusPanel` | Corner radius of the window in pixels. |
| `Elevated` | `boolean` | :x: | `true` | Use the raised fill and a larger shadow. |
| `BackgroundTransparency` | `UsedAs<number>` | :x: | `0` | Transparency of the window fill, from 0 (opaque) to 1. The edges and the content stay opaque. |
| `Draggable` | `boolean` | :x: | `false` | Let the user drag the window by its app bar. |
| `DragBounds` | `"Titlebar" \| "Screen" \| "Free"` | :x: | `"Titlebar"` | `"Titlebar"` lets the window leave the screen but keeps the handle reachable. `"Screen"` keeps the whole window on screen. `"Free"` has no limit. |
| `DragKeepVisible` | `number` | :x: | `120` | `"Titlebar"` only. How much of the window must stay on screen horizontally, in pixels. |
| `Resizable` | `boolean` | :x: | `false` | Show resize handles on the edges and corners. |
| `MinSize` | `Vector2` | :x: | `Vector2.new(240, 160)` | Smallest size in pixels while resizing. |
| `MaxSize` | `Vector2` | :x: | The size of the screen | Largest size in pixels while resizing. |
| `ResizeRatio` | `number` | :x: | - | Lock the width to height ratio while resizing. Defaults to the ratio of the window's `UIAspectRatioConstraint`, if it has one. |
| `ResizeHandles` | `{ string }` | :x: | All of them | Which handles to show: `"Left"`, `"Right"`, `"Top"`, `"Bottom"`, `"TopLeft"`, `"TopRight"`, `"BottomLeft"` and `"BottomRight"`. |
| `ResizeHandleSize` | `number` | :x: | `6` | Width of the edge handles in pixels. Corners are twice as large. |
| `ResizeSnap` | `number` | :x: | - | Snap the size to multiples of this many px. |
| `AspectRatio` | `number` | :x: | - | Aspect ratio constraint for the window. |
| `SizeConstraint` | `Enum.SizeConstraint` | :x: | - | `SizeConstraint` of the window frame. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnResized: (Vector2) -> ()` | Runs with the new size on every resize step. |

## See also

- [AppBar](./AppBar.md)
- [NavigationRail](./NavigationRail.md)
- [Overlay layers](../../Guides/OverlayLayers.md)
