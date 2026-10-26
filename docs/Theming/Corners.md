---
tags:
  - Design tokens
---

# Corners

Corner radii are in `theme.Metrics`, in pixels. Pass one to a `UICorner`:

```luau
scope:New "UICorner" {
	CornerRadius = UDim.new(0, theme.Metrics.RadiusSm),
}
```

## Radius scale

<div class="es-radii" markdown="0">
<div class="es-radius"><span class="es-radius__box" style="border-top-left-radius:0px"></span><code>RadiusNone</code><span>0</span></div>
<div class="es-radius"><span class="es-radius__box" style="border-top-left-radius:2px"></span><code>Radius2xs</code><span>2</span></div>
<div class="es-radius"><span class="es-radius__box" style="border-top-left-radius:4px"></span><code>RadiusXs</code><span>4</span></div>
<div class="es-radius"><span class="es-radius__box" style="border-top-left-radius:8px"></span><code>RadiusSm</code><span>8</span></div>
<div class="es-radius"><span class="es-radius__box" style="border-top-left-radius:12px"></span><code>RadiusMd</code><span>12</span></div>
<div class="es-radius"><span class="es-radius__box" style="border-top-left-radius:16px"></span><code>RadiusLg</code><span>16</span></div>
<div class="es-radius"><span class="es-radius__box" style="border-top-left-radius:20px"></span><code>RadiusXl</code><span>20</span></div>
<div class="es-radius"><span class="es-radius__box" style="border-top-left-radius:24px"></span><code>Radius2xl</code><span>24</span></div>
<div class="es-radius"><span class="es-radius__box" style="border-top-left-radius:32px"></span><code>Radius3xl</code><span>32</span></div>
<div class="es-radius"><span class="es-radius__box" style="border-top-left-radius:12px"></span><code>RadiusPanel</code><span>12</span></div>
<div class="es-radius"><span class="es-radius__box" style="border-top-left-radius:40px"></span><code>RadiusPill</code><span>999</span></div>
</div>

The preview shows the top left corner of a box. A 999 pixel radius is drawn at 40 pixels, which already makes the corner fully round.

| Name | Pixels | Use |
| ---- | ------ | --- |
| `RadiusNone` | 0 | Square corners. |
| `Radius2xs` | 2 | Thin bars and focus rings. |
| `RadiusXs` | 4 | Small marks such as checkboxes. |
| `RadiusSm` | 8 | Fields, buttons in compact UI, menu items. |
| `RadiusMd` | 12 | Medium containers. |
| `RadiusLg` | 16 | Large containers. |
| `RadiusXl` | 20 | Large sheets. |
| `Radius2xl` | 24 | Very large sheets. |
| `Radius3xl` | 32 | The largest rounded shapes. |
| `RadiusPanel` | 12 | Cards, panels and sheets. |
| `RadiusPill` | 999 | Fully round: pills, avatars and switches. |

`RadiusPill` is 999 so that any height gives a fully round end. `RadiusPanel` is 12, the same as `RadiusMd`. Use `RadiusPanel` for cards and sheets so that you can change them as a group.

## Change the values

```luau
local theme = Pantheon.Theme.create("Light", {
	Overrides = {
		Metrics = { RadiusPanel = 20, RadiusSm = 6 },
	},
})
```

## Concentric corners

A shape inside a rounded container has corners that share a centre with the container. The inner radius is the container radius minus the gap to the container edge. This is the same rule as concentric corners in SwiftUI.

`Window`, `Card`, `Surface`, `Dialog` and `Snackbar` are containers. These components round themselves to fit the nearest container:

- `Alert`
- `Collapsible`
- `ListItem`
- `MenuButton`
- `NumberField`
- `TextField`

Pantheon measures the gap on each side, so a shape that touches one edge of the container gets a larger radius on that side. The radius is never more than the radius the component has on its own, and never less than 4.

Outside a container, a component keeps its normal radius.

`Dialog`, `Prompt` and `ConfirmDialog` are containers, but they are not concentric with the container around them. A dialog sits far from the edges, so a concentric radius would be nearly square. They use `Radius3xl` instead.

To turn this off for one component, set `CornerRadius`. The component keeps that radius and ignores the container.

```luau
scope:ListItem({ Title = "Square row", CornerRadius = 0 })
```

### In your own components

`Pantheon.Corners.auto` gives any frame the same behaviour. Pass the frame, the `CornerRadius` the caller supplied (or `nil`), and the radius the frame has on its own. Add `Container = true` to make the frame a container for what is inside it.

```luau
local row = scope:Frame({ Size = UDim2.new(1, 0, 0, 36), CornerRadius = 8 })
Pantheon.Corners.auto(row, props.CornerRadius, 8)
```

A [NavigationDrawer](../Components/Navigation/NavigationDrawer.md) with `Sidebar` is a container. Its own corners are concentric with the window, and the rows you put in it can use `Corners.auto` to be concentric with the drawer.
