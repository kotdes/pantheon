---
tags:
  - Design tokens
---

# Spacing and sizes

Spacing and sizes are in `theme.Metrics`. Values are in pixels. Spacing names start with `Space`, not `Padding`, because you use them for padding, gaps and margins alike.

```luau
local theme = Pantheon.Theme.use()

scope:New "UIPadding" {
	PaddingTop = UDim.new(0, theme.Metrics.SpaceMd),
	PaddingBottom = UDim.new(0, theme.Metrics.SpaceMd),
}
```

## Spacing scale

<div class="es-scales" markdown="0">
<div class="es-scale"><code>Space2xs</code><span class="es-scale__value">4</span><span class="es-scale__bar" style="width:4px"></span></div>
<div class="es-scale"><code>SpaceXs</code><span class="es-scale__value">8</span><span class="es-scale__bar" style="width:8px"></span></div>
<div class="es-scale"><code>SpaceSm</code><span class="es-scale__value">12</span><span class="es-scale__bar" style="width:12px"></span></div>
<div class="es-scale"><code>SpaceMd</code><span class="es-scale__value">16</span><span class="es-scale__bar" style="width:16px"></span></div>
<div class="es-scale"><code>SpaceLg</code><span class="es-scale__value">24</span><span class="es-scale__bar" style="width:24px"></span></div>
<div class="es-scale"><code>SpaceXl</code><span class="es-scale__value">32</span><span class="es-scale__bar" style="width:32px"></span></div>
</div>

| Name | Pixels | Use |
| ---- | ------ | --- |
| `Space2xs` | 4 | Gap between an icon and its label. Tight stacks. |
| `SpaceXs` | 8 | Gap between related controls. |
| `SpaceSm` | 12 | Padding inside small components and list items. |
| `SpaceMd` | 16 | Default padding of cards and sheets. Gap between sections. |
| `SpaceLg` | 24 | Space between groups. |
| `SpaceXl` | 32 | Space around whole pages. |

There is no `SpaceNone` or `Space2xl`. Use `0`, or a multiple of a token such as `theme.Metrics.SpaceXl * 2`.

## Component sizes

| Name | Pixels | Use |
| ---- | ------ | --- |
| `AppBarHeight` | 64 | Height of an [AppBar](../Components/Navigation/AppBar.md). |
| `DrawerWidth` | 280 | Width of a [NavigationDrawer](../Components/Navigation/NavigationDrawer.md). |
| `SidebarInset` | 4 | Gap between a sidebar and the edges of its window. Use 0 for a sidebar that is flush with them. |
| `SidebarItemRadius` | 8 | Corner radius of a row in a sidebar, such as the selected page. Make it larger to match a sidebar with round corners. |
| `RailWidth` | 72 | Width of a [NavigationRail](../Components/Navigation/NavigationRail.md). |
| `ButtonPadX` | 20 | Horizontal padding inside a medium [Button](../Components/Foundations/Button.md). A `Small` or `Large` button scales it with its height, so the shape stays the same. |
| `ButtonPadY` | 4 | Vertical padding inside a Button, on top of the line height. |
| `ControlHeight` | 40 | Height of a field or select. |
| `ControlHeightCompact` | 28 | Height of the compact variant, used in number boxes and hex fields. |
| `ControlHeightLarge` | 48 | Height of a `Large` [Button](../Components/Foundations/Button.md), such as a full-width Continue button. |
| `FieldLabelHeight` | 20 | Height of the label above a field. |
| `IconSm`, `IconMd`, `IconLg`, `IconXl` | 16, 18, 20, 24 | Icon sizes. `IconMd` is the default in buttons and fields. |

## Change the values

Pass `Overrides` to `Theme.create`. It merges over the finished theme, so name only what you change.

```luau
local theme = Pantheon.Theme.create("Light", {
	Overrides = {
		Metrics = { SpaceMd = 20, AppBarHeight = 56 },
	},
})
```

!!! note

    Components read these values when they are built. Change them before you build the interface.
