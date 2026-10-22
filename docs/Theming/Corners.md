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
