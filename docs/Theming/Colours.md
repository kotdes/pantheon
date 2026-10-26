---
tags:
  - Design tokens
---

# Colours

A theme has a `Colors` table of roles, and a `Palette` of named colours. Both come in a light and a dark version. You read them from the theme:

```luau
local theme = Pantheon.Theme.use()

scope:New "Frame" {
	BackgroundColor3 = theme.Colors.SurfaceContainer,
}
```

!!! note

    Names that end in `On` hold the colour of content drawn on top of the base colour. Pair `OnPrimary` with `Primary`, and `OnSurface` with `Surface`.

## Roles

These are the keys of `theme.Colors`. Hover over a swatch to see its value.


### Brand

| Name | Light | Dark | Use |
| ---- | ----- | ---- | --- |
| `Primary` | <span class="es-swatch" style="--c:#00695c" title="#00695c"></span> `#00695c` | <span class="es-swatch" style="--c:#4db6ac" title="#4db6ac"></span> `#4db6ac` | Main brand colour. Fills for key actions. |
| `OnPrimary` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` | <span class="es-swatch" style="--c:#003731" title="#003731"></span> `#003731` | Content on `Primary`. |
| `PrimaryContainer` | <span class="es-swatch" style="--c:#b2dfdb" title="#b2dfdb"></span> `#b2dfdb` | <span class="es-swatch" style="--c:#004d44" title="#004d44"></span> `#004d44` | Softer fill for selected or tonal elements. |
| `OnPrimaryContainer` | <span class="es-swatch" style="--c:#002823" title="#002823"></span> `#002823` | <span class="es-swatch" style="--c:#b2dfdb" title="#b2dfdb"></span> `#b2dfdb` | Content on `PrimaryContainer`. |

### Surfaces and text

| Name | Light | Dark | Use |
| ---- | ----- | ---- | --- |
| `Background` | <span class="es-swatch" style="--c:#f4f6fa" title="#f4f6fa"></span> `#f4f6fa` | <span class="es-swatch" style="--c:#101418" title="#101418"></span> `#101418` | Page behind everything else. |
| `Surface` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` | <span class="es-swatch" style="--c:#1a1f26" title="#1a1f26"></span> `#1a1f26` | Cards, sheets and panels. |
| `SurfaceDim` | <span class="es-swatch" style="--c:#e8ebf1" title="#e8ebf1"></span> `#e8ebf1` | <span class="es-swatch" style="--c:#101418" title="#101418"></span> `#101418` | A dimmer surface for recessed areas. |
| `SurfaceBright` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` | <span class="es-swatch" style="--c:#28303a" title="#28303a"></span> `#28303a` | A brighter surface for raised areas. |
| `SurfaceContainer` | <span class="es-swatch" style="--c:#eef1f6" title="#eef1f6"></span> `#eef1f6` | <span class="es-swatch" style="--c:#232a33" title="#232a33"></span> `#232a33` | Fields, chips and quiet fills. |
| `SurfaceContainerHigh` | <span class="es-swatch" style="--c:#e2e6ed" title="#e2e6ed"></span> `#e2e6ed` | <span class="es-swatch" style="--c:#2d3641" title="#2d3641"></span> `#2d3641` | Hovered or stronger fills. |
| `OnSurface` | <span class="es-swatch" style="--c:#1c1b1f" title="#1c1b1f"></span> `#1c1b1f` | <span class="es-swatch" style="--c:#e6e8ec" title="#e6e8ec"></span> `#e6e8ec` | Main text and icons on a surface. |
| `OnSurfaceVariant` | <span class="es-swatch" style="--c:#44474f" title="#44474f"></span> `#44474f` | <span class="es-swatch" style="--c:#b8bec8" title="#b8bec8"></span> `#b8bec8` | Secondary text and icons. |

### Outlines

| Name | Light | Dark | Use |
| ---- | ----- | ---- | --- |
| `Outline` | <span class="es-swatch" style="--c:#c4c7cf" title="#c4c7cf"></span> `#c4c7cf` | <span class="es-swatch" style="--c:#343d48" title="#343d48"></span> `#343d48` | Borders of controls. |
| `OutlineVariant` | <span class="es-swatch" style="--c:#dadde4" title="#dadde4"></span> `#dadde4` | <span class="es-swatch" style="--c:#2a323c" title="#2a323c"></span> `#2a323c` | Dividers and soft borders. |

### Status

| Name | Light | Dark | Use |
| ---- | ----- | ---- | --- |
| `Error` | <span class="es-swatch" style="--c:#d32f2f" title="#d32f2f"></span> `#d32f2f` | <span class="es-swatch" style="--c:#ef5350" title="#ef5350"></span> `#ef5350` | Errors and destructive actions. |
| `OnError` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` | <span class="es-swatch" style="--c:#1a1f26" title="#1a1f26"></span> `#1a1f26` | Content on `Error`. |
| `Success` | <span class="es-swatch" style="--c:#2e7d32" title="#2e7d32"></span> `#2e7d32` | <span class="es-swatch" style="--c:#66bb6a" title="#66bb6a"></span> `#66bb6a` | Success states. |
| `OnSuccess` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` | <span class="es-swatch" style="--c:#1a1f26" title="#1a1f26"></span> `#1a1f26` | Content on `Success`. |
| `Warning` | <span class="es-swatch" style="--c:#ed6c02" title="#ed6c02"></span> `#ed6c02` | <span class="es-swatch" style="--c:#ffb74d" title="#ffb74d"></span> `#ffb74d` | Warnings. |
| `OnWarning` | <span class="es-swatch" style="--c:#211900" title="#211900"></span> `#211900` | <span class="es-swatch" style="--c:#1a1f26" title="#1a1f26"></span> `#1a1f26` | Content on `Warning`. |
| `Info` | <span class="es-swatch" style="--c:#0173b4" title="#0173b4"></span> `#0173b4` | <span class="es-swatch" style="--c:#4fc3f7" title="#4fc3f7"></span> `#4fc3f7` | Information. |
| `OnInfo` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` | <span class="es-swatch" style="--c:#1a1f26" title="#1a1f26"></span> `#1a1f26` | Content on `Info`. |

### Sidebar

A sidebar is a navigation drawer with the `Sidebar` prop. A theme can give it a fill of its own, as in a chat app with a coloured sidebar. A theme that leaves these three out gets a sidebar that follows `Surface`, `OnSurface` and `SurfaceContainer`.

| Name | Light | Dark | Use |
| ---- | ----- | ---- | --- |
| `Sidebar` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` | <span class="es-swatch" style="--c:#1a1f26" title="#1a1f26"></span> `#1a1f26` | Fill of the sidebar. Follows `Surface`. |
| `OnSidebar` | <span class="es-swatch" style="--c:#1c1b1f" title="#1c1b1f"></span> `#1c1b1f` | <span class="es-swatch" style="--c:#e6e8ec" title="#e6e8ec"></span> `#e6e8ec` | Icons and text on `Sidebar`. Follows `OnSurface`. |
| `SidebarSelected` | <span class="es-swatch" style="--c:#eef1f6" title="#eef1f6"></span> `#eef1f6` | <span class="es-swatch" style="--c:#232a33" title="#232a33"></span> `#232a33` | Selected and hovered row of the sidebar. Follows `SurfaceContainer`. |

### Overlays and inverse

| Name | Light | Dark | Use |
| ---- | ----- | ---- | --- |
| `Scrim` | <span class="es-swatch" style="--c:#101418" title="#101418"></span> `#101418` | <span class="es-swatch" style="--c:#000000" title="#000000"></span> `#000000` | Dim layer behind dialogs and sheets. |
| `InverseSurface` | <span class="es-swatch" style="--c:#262d36" title="#262d36"></span> `#262d36` | <span class="es-swatch" style="--c:#e2e6ed" title="#e2e6ed"></span> `#e2e6ed` | Toasts and tips: dark in light mode, light in dark mode. |
| `InverseOnSurface` | <span class="es-swatch" style="--c:#f0f3f7" title="#f0f3f7"></span> `#f0f3f7` | <span class="es-swatch" style="--c:#1c1b1f" title="#1c1b1f"></span> `#1c1b1f` | Content on `InverseSurface`. |
| `InversePrimary` | <span class="es-swatch" style="--c:#4db6ac" title="#4db6ac"></span> `#4db6ac` | <span class="es-swatch" style="--c:#00695c" title="#00695c"></span> `#00695c` | Actions on `InverseSurface`. |

## Palette

`theme.Palette` holds named colours. Each is a `ThemeColorRole` with four colours:

| Field | Meaning |
| ----- | ------- |
| `Base` | The main colour. |
| `OnBase` | Content on `Base`. |
| `Container` | A soft fill of the same hue. |
| `OnContainer` | Content on `Container`. |

A `Color` property, such as the one on a [Button](../Components/Foundations/Button.md), takes these names.


### Light palette

| Name | Base | OnBase | Container | OnContainer |
| ---- | ---- | ------ | --------- | ----------- |
| `"primary"` | <span class="es-swatch" style="--c:#00695c" title="#00695c"></span> `#00695c` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` | <span class="es-swatch" style="--c:#b2dfdb" title="#b2dfdb"></span> `#b2dfdb` | <span class="es-swatch" style="--c:#002823" title="#002823"></span> `#002823` |
| `"secondary"` | <span class="es-swatch" style="--c:#616161" title="#616161"></span> `#616161` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` | <span class="es-swatch" style="--c:#dcdcdc" title="#dcdcdc"></span> `#dcdcdc` | <span class="es-swatch" style="--c:#000000" title="#000000"></span> `#000000` |
| `"surface"` | <span class="es-swatch" style="--c:#e2e6ed" title="#e2e6ed"></span> `#e2e6ed` | <span class="es-swatch" style="--c:#1c1b1f" title="#1c1b1f"></span> `#1c1b1f` | <span class="es-swatch" style="--c:#eef1f6" title="#eef1f6"></span> `#eef1f6` | <span class="es-swatch" style="--c:#44474f" title="#44474f"></span> `#44474f` |
| `"error"` | <span class="es-swatch" style="--c:#d32f2f" title="#d32f2f"></span> `#d32f2f` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` | <span class="es-swatch" style="--c:#f5d1d1" title="#f5d1d1"></span> `#f5d1d1` | <span class="es-swatch" style="--c:#d32f2f" title="#d32f2f"></span> `#d32f2f` |
| `"success"` | <span class="es-swatch" style="--c:#2e7d32" title="#2e7d32"></span> `#2e7d32` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` | <span class="es-swatch" style="--c:#d1e2d2" title="#d1e2d2"></span> `#d1e2d2` | <span class="es-swatch" style="--c:#2e7d32" title="#2e7d32"></span> `#2e7d32` |
| `"warning"` | <span class="es-swatch" style="--c:#ed6c02" title="#ed6c02"></span> `#ed6c02` | <span class="es-swatch" style="--c:#211900" title="#211900"></span> `#211900` | <span class="es-swatch" style="--c:#fbdfc7" title="#fbdfc7"></span> `#fbdfc7` | <span class="es-swatch" style="--c:#ed6c02" title="#ed6c02"></span> `#ed6c02` |
| `"info"` | <span class="es-swatch" style="--c:#0173b4" title="#0173b4"></span> `#0173b4` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` | <span class="es-swatch" style="--c:#c7e0ee" title="#c7e0ee"></span> `#c7e0ee` | <span class="es-swatch" style="--c:#0173b4" title="#0173b4"></span> `#0173b4` |

### Dark palette

| Name | Base | OnBase | Container | OnContainer |
| ---- | ---- | ------ | --------- | ----------- |
| `"primary"` | <span class="es-swatch" style="--c:#4db6ac" title="#4db6ac"></span> `#4db6ac` | <span class="es-swatch" style="--c:#003731" title="#003731"></span> `#003731` | <span class="es-swatch" style="--c:#004d44" title="#004d44"></span> `#004d44` | <span class="es-swatch" style="--c:#b2dfdb" title="#b2dfdb"></span> `#b2dfdb` |
| `"secondary"` | <span class="es-swatch" style="--c:#9ca3af" title="#9ca3af"></span> `#9ca3af` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` | <span class="es-swatch" style="--c:#46494f" title="#46494f"></span> `#46494f` | <span class="es-swatch" style="--c:#ffffff" title="#ffffff"></span> `#ffffff` |
| `"surface"` | <span class="es-swatch" style="--c:#2d3641" title="#2d3641"></span> `#2d3641` | <span class="es-swatch" style="--c:#e6e8ec" title="#e6e8ec"></span> `#e6e8ec` | <span class="es-swatch" style="--c:#232a33" title="#232a33"></span> `#232a33` | <span class="es-swatch" style="--c:#b8bec8" title="#b8bec8"></span> `#b8bec8` |
| `"error"` | <span class="es-swatch" style="--c:#ef5350" title="#ef5350"></span> `#ef5350` | <span class="es-swatch" style="--c:#1a1f26" title="#1a1f26"></span> `#1a1f26` | <span class="es-swatch" style="--c:#492a2f" title="#492a2f"></span> `#492a2f` | <span class="es-swatch" style="--c:#ef5350" title="#ef5350"></span> `#ef5350` |
| `"success"` | <span class="es-swatch" style="--c:#66bb6a" title="#66bb6a"></span> `#66bb6a` | <span class="es-swatch" style="--c:#1a1f26" title="#1a1f26"></span> `#1a1f26` | <span class="es-swatch" style="--c:#2b4135" title="#2b4135"></span> `#2b4135` | <span class="es-swatch" style="--c:#66bb6a" title="#66bb6a"></span> `#66bb6a` |
| `"warning"` | <span class="es-swatch" style="--c:#ffb74d" title="#ffb74d"></span> `#ffb74d` | <span class="es-swatch" style="--c:#1a1f26" title="#1a1f26"></span> `#1a1f26` | <span class="es-swatch" style="--c:#4c402f" title="#4c402f"></span> `#4c402f` | <span class="es-swatch" style="--c:#ffb74d" title="#ffb74d"></span> `#ffb74d` |
| `"info"` | <span class="es-swatch" style="--c:#4fc3f7" title="#4fc3f7"></span> `#4fc3f7` | <span class="es-swatch" style="--c:#1a1f26" title="#1a1f26"></span> `#1a1f26` | <span class="es-swatch" style="--c:#264354" title="#264354"></span> `#264354` | <span class="es-swatch" style="--c:#4fc3f7" title="#4fc3f7"></span> `#4fc3f7` |

### Add your own

Pass `Palette` to `Theme.create`. A seed colour is enough. Pantheon works out the other three.

```luau
local theme = Pantheon.Theme.create("Light", {
	Palette = {
		brand = "#7c4dff",
	},
})

scope:Button({ Text = "Go", Color = "brand" })
```

For a seed, `OnBase` is black or white, whichever reads better. `Container` mixes the seed 78% towards white in light mode, and 55% towards black in dark mode.

## Material swatches

A `Color` property also takes a Material swatch, such as `"Blue 500"` or `{ Blue = 500 }`. Pantheon turns it into a role in the same way as a seed colour. The swatches are in `Pantheon.Theme.Material`.

| Hue | 50 | 100 | 200 | 300 | 400 | 500 | 600 | 700 | 800 | 900 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `Red` | <span class="es-swatch" style="--c:#ffebee" title="#ffebee"></span> | <span class="es-swatch" style="--c:#ffcdd2" title="#ffcdd2"></span> | <span class="es-swatch" style="--c:#ef9a9a" title="#ef9a9a"></span> | <span class="es-swatch" style="--c:#e57373" title="#e57373"></span> | <span class="es-swatch" style="--c:#ef5350" title="#ef5350"></span> | <span class="es-swatch" style="--c:#f44336" title="#f44336"></span> | <span class="es-swatch" style="--c:#e53935" title="#e53935"></span> | <span class="es-swatch" style="--c:#d32f2f" title="#d32f2f"></span> | <span class="es-swatch" style="--c:#c62828" title="#c62828"></span> | <span class="es-swatch" style="--c:#b71c1c" title="#b71c1c"></span> |
| `Pink` | <span class="es-swatch" style="--c:#fce4ec" title="#fce4ec"></span> | <span class="es-swatch" style="--c:#f8bbd0" title="#f8bbd0"></span> | <span class="es-swatch" style="--c:#f48fb1" title="#f48fb1"></span> | <span class="es-swatch" style="--c:#f06292" title="#f06292"></span> | <span class="es-swatch" style="--c:#ec407a" title="#ec407a"></span> | <span class="es-swatch" style="--c:#e91e63" title="#e91e63"></span> | <span class="es-swatch" style="--c:#d81b60" title="#d81b60"></span> | <span class="es-swatch" style="--c:#c2185b" title="#c2185b"></span> | <span class="es-swatch" style="--c:#ad1457" title="#ad1457"></span> | <span class="es-swatch" style="--c:#880e4f" title="#880e4f"></span> |
| `Purple` | <span class="es-swatch" style="--c:#f3e5f5" title="#f3e5f5"></span> | <span class="es-swatch" style="--c:#e1bee7" title="#e1bee7"></span> | <span class="es-swatch" style="--c:#ce93d8" title="#ce93d8"></span> | <span class="es-swatch" style="--c:#ba68c8" title="#ba68c8"></span> | <span class="es-swatch" style="--c:#ab47bc" title="#ab47bc"></span> | <span class="es-swatch" style="--c:#9c27b0" title="#9c27b0"></span> | <span class="es-swatch" style="--c:#8e24aa" title="#8e24aa"></span> | <span class="es-swatch" style="--c:#7b1fa2" title="#7b1fa2"></span> | <span class="es-swatch" style="--c:#6a1b9a" title="#6a1b9a"></span> | <span class="es-swatch" style="--c:#4a148c" title="#4a148c"></span> |
| `DeepPurple` | <span class="es-swatch" style="--c:#ede7f6" title="#ede7f6"></span> | <span class="es-swatch" style="--c:#d1c4e9" title="#d1c4e9"></span> | <span class="es-swatch" style="--c:#b39ddb" title="#b39ddb"></span> | <span class="es-swatch" style="--c:#9575cd" title="#9575cd"></span> | <span class="es-swatch" style="--c:#7e57c2" title="#7e57c2"></span> | <span class="es-swatch" style="--c:#673ab7" title="#673ab7"></span> | <span class="es-swatch" style="--c:#5e35b1" title="#5e35b1"></span> | <span class="es-swatch" style="--c:#512da8" title="#512da8"></span> | <span class="es-swatch" style="--c:#4527a0" title="#4527a0"></span> | <span class="es-swatch" style="--c:#311b92" title="#311b92"></span> |
| `Indigo` | <span class="es-swatch" style="--c:#e8eaf6" title="#e8eaf6"></span> | <span class="es-swatch" style="--c:#c5cae9" title="#c5cae9"></span> | <span class="es-swatch" style="--c:#9fa8da" title="#9fa8da"></span> | <span class="es-swatch" style="--c:#7986cb" title="#7986cb"></span> | <span class="es-swatch" style="--c:#5c6bc0" title="#5c6bc0"></span> | <span class="es-swatch" style="--c:#3f51b5" title="#3f51b5"></span> | <span class="es-swatch" style="--c:#3949ab" title="#3949ab"></span> | <span class="es-swatch" style="--c:#303f9f" title="#303f9f"></span> | <span class="es-swatch" style="--c:#283593" title="#283593"></span> | <span class="es-swatch" style="--c:#1a237e" title="#1a237e"></span> |
| `Blue` | <span class="es-swatch" style="--c:#e3f2fd" title="#e3f2fd"></span> | <span class="es-swatch" style="--c:#bbdefb" title="#bbdefb"></span> | <span class="es-swatch" style="--c:#90caf9" title="#90caf9"></span> | <span class="es-swatch" style="--c:#64b5f6" title="#64b5f6"></span> | <span class="es-swatch" style="--c:#42a5f5" title="#42a5f5"></span> | <span class="es-swatch" style="--c:#2196f3" title="#2196f3"></span> | <span class="es-swatch" style="--c:#1e88e5" title="#1e88e5"></span> | <span class="es-swatch" style="--c:#1976d2" title="#1976d2"></span> | <span class="es-swatch" style="--c:#1565c0" title="#1565c0"></span> | <span class="es-swatch" style="--c:#0d47a1" title="#0d47a1"></span> |
| `LightBlue` | <span class="es-swatch" style="--c:#e1f5fe" title="#e1f5fe"></span> | <span class="es-swatch" style="--c:#b3e5fc" title="#b3e5fc"></span> | <span class="es-swatch" style="--c:#81d4fa" title="#81d4fa"></span> | <span class="es-swatch" style="--c:#4fc3f7" title="#4fc3f7"></span> | <span class="es-swatch" style="--c:#29b6f6" title="#29b6f6"></span> | <span class="es-swatch" style="--c:#03a9f4" title="#03a9f4"></span> | <span class="es-swatch" style="--c:#039be5" title="#039be5"></span> | <span class="es-swatch" style="--c:#0288d1" title="#0288d1"></span> | <span class="es-swatch" style="--c:#0277bd" title="#0277bd"></span> | <span class="es-swatch" style="--c:#01579b" title="#01579b"></span> |
| `Cyan` | <span class="es-swatch" style="--c:#e0f7fa" title="#e0f7fa"></span> | <span class="es-swatch" style="--c:#b2ebf2" title="#b2ebf2"></span> | <span class="es-swatch" style="--c:#80deea" title="#80deea"></span> | <span class="es-swatch" style="--c:#4dd0e1" title="#4dd0e1"></span> | <span class="es-swatch" style="--c:#26c6da" title="#26c6da"></span> | <span class="es-swatch" style="--c:#00bcd4" title="#00bcd4"></span> | <span class="es-swatch" style="--c:#00acc1" title="#00acc1"></span> | <span class="es-swatch" style="--c:#0097a7" title="#0097a7"></span> | <span class="es-swatch" style="--c:#00838f" title="#00838f"></span> | <span class="es-swatch" style="--c:#006064" title="#006064"></span> |
| `Teal` | <span class="es-swatch" style="--c:#e0f2f1" title="#e0f2f1"></span> | <span class="es-swatch" style="--c:#b2dfdb" title="#b2dfdb"></span> | <span class="es-swatch" style="--c:#80cbc4" title="#80cbc4"></span> | <span class="es-swatch" style="--c:#4db6ac" title="#4db6ac"></span> | <span class="es-swatch" style="--c:#26a69a" title="#26a69a"></span> | <span class="es-swatch" style="--c:#009688" title="#009688"></span> | <span class="es-swatch" style="--c:#00897b" title="#00897b"></span> | <span class="es-swatch" style="--c:#00796b" title="#00796b"></span> | <span class="es-swatch" style="--c:#00695c" title="#00695c"></span> | <span class="es-swatch" style="--c:#004d40" title="#004d40"></span> |
| `Green` | <span class="es-swatch" style="--c:#e8f5e9" title="#e8f5e9"></span> | <span class="es-swatch" style="--c:#c8e6c9" title="#c8e6c9"></span> | <span class="es-swatch" style="--c:#a5d6a7" title="#a5d6a7"></span> | <span class="es-swatch" style="--c:#81c784" title="#81c784"></span> | <span class="es-swatch" style="--c:#66bb6a" title="#66bb6a"></span> | <span class="es-swatch" style="--c:#4caf50" title="#4caf50"></span> | <span class="es-swatch" style="--c:#43a047" title="#43a047"></span> | <span class="es-swatch" style="--c:#388e3c" title="#388e3c"></span> | <span class="es-swatch" style="--c:#2e7d32" title="#2e7d32"></span> | <span class="es-swatch" style="--c:#1b5e20" title="#1b5e20"></span> |
| `LightGreen` | <span class="es-swatch" style="--c:#f1f8e9" title="#f1f8e9"></span> | <span class="es-swatch" style="--c:#dcedc8" title="#dcedc8"></span> | <span class="es-swatch" style="--c:#c5e1a5" title="#c5e1a5"></span> | <span class="es-swatch" style="--c:#aed581" title="#aed581"></span> | <span class="es-swatch" style="--c:#9ccc65" title="#9ccc65"></span> | <span class="es-swatch" style="--c:#8bc34a" title="#8bc34a"></span> | <span class="es-swatch" style="--c:#7cb342" title="#7cb342"></span> | <span class="es-swatch" style="--c:#689f38" title="#689f38"></span> | <span class="es-swatch" style="--c:#558b2f" title="#558b2f"></span> | <span class="es-swatch" style="--c:#33691e" title="#33691e"></span> |
| `Lime` | <span class="es-swatch" style="--c:#f9fbe7" title="#f9fbe7"></span> | <span class="es-swatch" style="--c:#f0f4c3" title="#f0f4c3"></span> | <span class="es-swatch" style="--c:#e6ee9c" title="#e6ee9c"></span> | <span class="es-swatch" style="--c:#dce775" title="#dce775"></span> | <span class="es-swatch" style="--c:#d4e157" title="#d4e157"></span> | <span class="es-swatch" style="--c:#cddc39" title="#cddc39"></span> | <span class="es-swatch" style="--c:#c0ca33" title="#c0ca33"></span> | <span class="es-swatch" style="--c:#afb42b" title="#afb42b"></span> | <span class="es-swatch" style="--c:#9e9d24" title="#9e9d24"></span> | <span class="es-swatch" style="--c:#827717" title="#827717"></span> |
| `Yellow` | <span class="es-swatch" style="--c:#fffde7" title="#fffde7"></span> | <span class="es-swatch" style="--c:#fff9c4" title="#fff9c4"></span> | <span class="es-swatch" style="--c:#fff59d" title="#fff59d"></span> | <span class="es-swatch" style="--c:#fff176" title="#fff176"></span> | <span class="es-swatch" style="--c:#ffee58" title="#ffee58"></span> | <span class="es-swatch" style="--c:#ffeb3b" title="#ffeb3b"></span> | <span class="es-swatch" style="--c:#fdd835" title="#fdd835"></span> | <span class="es-swatch" style="--c:#fbc02d" title="#fbc02d"></span> | <span class="es-swatch" style="--c:#f9a825" title="#f9a825"></span> | <span class="es-swatch" style="--c:#f57f17" title="#f57f17"></span> |
| `Amber` | <span class="es-swatch" style="--c:#fff8e1" title="#fff8e1"></span> | <span class="es-swatch" style="--c:#ffecb3" title="#ffecb3"></span> | <span class="es-swatch" style="--c:#ffe082" title="#ffe082"></span> | <span class="es-swatch" style="--c:#ffd54f" title="#ffd54f"></span> | <span class="es-swatch" style="--c:#ffca28" title="#ffca28"></span> | <span class="es-swatch" style="--c:#ffc107" title="#ffc107"></span> | <span class="es-swatch" style="--c:#ffb300" title="#ffb300"></span> | <span class="es-swatch" style="--c:#ffa000" title="#ffa000"></span> | <span class="es-swatch" style="--c:#ff8f00" title="#ff8f00"></span> | <span class="es-swatch" style="--c:#ff6f00" title="#ff6f00"></span> |
| `Orange` | <span class="es-swatch" style="--c:#fff3e0" title="#fff3e0"></span> | <span class="es-swatch" style="--c:#ffe0b2" title="#ffe0b2"></span> | <span class="es-swatch" style="--c:#ffcc80" title="#ffcc80"></span> | <span class="es-swatch" style="--c:#ffb74d" title="#ffb74d"></span> | <span class="es-swatch" style="--c:#ffa726" title="#ffa726"></span> | <span class="es-swatch" style="--c:#ff9800" title="#ff9800"></span> | <span class="es-swatch" style="--c:#fb8c00" title="#fb8c00"></span> | <span class="es-swatch" style="--c:#f57c00" title="#f57c00"></span> | <span class="es-swatch" style="--c:#ef6c00" title="#ef6c00"></span> | <span class="es-swatch" style="--c:#e65100" title="#e65100"></span> |
| `DeepOrange` | <span class="es-swatch" style="--c:#fbe9e7" title="#fbe9e7"></span> | <span class="es-swatch" style="--c:#ffccbc" title="#ffccbc"></span> | <span class="es-swatch" style="--c:#ffab91" title="#ffab91"></span> | <span class="es-swatch" style="--c:#ff8a65" title="#ff8a65"></span> | <span class="es-swatch" style="--c:#ff7043" title="#ff7043"></span> | <span class="es-swatch" style="--c:#ff5722" title="#ff5722"></span> | <span class="es-swatch" style="--c:#f4511e" title="#f4511e"></span> | <span class="es-swatch" style="--c:#e64a19" title="#e64a19"></span> | <span class="es-swatch" style="--c:#d84315" title="#d84315"></span> | <span class="es-swatch" style="--c:#bf360c" title="#bf360c"></span> |
| `Brown` | <span class="es-swatch" style="--c:#efebe9" title="#efebe9"></span> | <span class="es-swatch" style="--c:#d7ccc8" title="#d7ccc8"></span> | <span class="es-swatch" style="--c:#bcaaa4" title="#bcaaa4"></span> | <span class="es-swatch" style="--c:#a1887f" title="#a1887f"></span> | <span class="es-swatch" style="--c:#8d6e63" title="#8d6e63"></span> | <span class="es-swatch" style="--c:#795548" title="#795548"></span> | <span class="es-swatch" style="--c:#6d4c41" title="#6d4c41"></span> | <span class="es-swatch" style="--c:#5d4037" title="#5d4037"></span> | <span class="es-swatch" style="--c:#4e342e" title="#4e342e"></span> | <span class="es-swatch" style="--c:#3e2723" title="#3e2723"></span> |
| `Grey` | <span class="es-swatch" style="--c:#fafafa" title="#fafafa"></span> | <span class="es-swatch" style="--c:#f5f5f5" title="#f5f5f5"></span> | <span class="es-swatch" style="--c:#eeeeee" title="#eeeeee"></span> | <span class="es-swatch" style="--c:#e0e0e0" title="#e0e0e0"></span> | <span class="es-swatch" style="--c:#bdbdbd" title="#bdbdbd"></span> | <span class="es-swatch" style="--c:#9e9e9e" title="#9e9e9e"></span> | <span class="es-swatch" style="--c:#757575" title="#757575"></span> | <span class="es-swatch" style="--c:#616161" title="#616161"></span> | <span class="es-swatch" style="--c:#424242" title="#424242"></span> | <span class="es-swatch" style="--c:#212121" title="#212121"></span> |
| `BlueGrey` | <span class="es-swatch" style="--c:#eceff1" title="#eceff1"></span> | <span class="es-swatch" style="--c:#cfd8dc" title="#cfd8dc"></span> | <span class="es-swatch" style="--c:#b0bec5" title="#b0bec5"></span> | <span class="es-swatch" style="--c:#90a4ae" title="#90a4ae"></span> | <span class="es-swatch" style="--c:#78909c" title="#78909c"></span> | <span class="es-swatch" style="--c:#607d8b" title="#607d8b"></span> | <span class="es-swatch" style="--c:#546e7a" title="#546e7a"></span> | <span class="es-swatch" style="--c:#455a64" title="#455a64"></span> | <span class="es-swatch" style="--c:#37474f" title="#37474f"></span> | <span class="es-swatch" style="--c:#263238" title="#263238"></span> |

Hues also have accent shades (`A100`, `A200`, `A400` and `A700`) where Material defines them: `Red`, `Pink`, `Purple`, `DeepPurple`, `Indigo`, `Blue`, `LightBlue`, `Cyan`, `Teal`, `Green`, `LightGreen`, `Lime`, `Yellow`, `Amber`, `Orange`, `DeepOrange`. `Black` and `White` are single colours. `Gray` and `BlueGray` are aliases for `Grey` and `BlueGrey`.

## High contrast

When the player turns on high contrast, `Background`, `Surface`, `OnSurface`, `OnSurfaceVariant`, `Outline` and `OutlineVariant` move towards black and white. See [Accessibility](../Guides/Accessibility.md).
