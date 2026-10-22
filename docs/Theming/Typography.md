---
tags:
  - Design tokens
---

# Typography

A type scale is a font, a size in pixels and a line height. The theme holds nine of them in `theme.Typography`. The [Text](../Components/Foundations/Text.md) component picks one with its `Variant` property.

```luau
scope:Text({ Text = "Settings", Variant = "Headline" })
```

## Scales

<div class="es-types" markdown="0">
<div class="es-type"><code>Display</code><span style="font:700 32px/1.2 Montserrat, sans-serif">The quick brown fox jumps</span></div>
<div class="es-type"><code>Headline</code><span style="font:700 24px/1.25 Montserrat, sans-serif">The quick brown fox jumps</span></div>
<div class="es-type"><code>Title</code><span style="font:700 18px/1.3 Montserrat, sans-serif">The quick brown fox jumps</span></div>
<div class="es-type"><code>Button</code><span style="font:700 16px/1.4 Montserrat, sans-serif">The quick brown fox jumps</span></div>
<div class="es-type"><code>BoldBody</code><span style="font:700 16px/1.4 Montserrat, sans-serif">The quick brown fox jumps</span></div>
<div class="es-type"><code>Body</code><span style="font:500 16px/1.4 Montserrat, sans-serif">The quick brown fox jumps</span></div>
<div class="es-type"><code>Label</code><span style="font:700 14px/1.3 Montserrat, sans-serif">The quick brown fox jumps</span></div>
<div class="es-type"><code>Caption</code><span style="font:700 12px/1.3 Montserrat, sans-serif">The quick brown fox jumps</span></div>
<div class="es-type"><code>Mono</code><span style="font:400 13px/1.35 Roboto Mono, monospace">The quick brown fox jumps</span></div>
</div>

The preview draws the text in Montserrat and Roboto Mono, the fonts of the default theme.

| Name | Font | Size | Line height | Use |
| ---- | ---- | ---- | ----------- | --- |
| `Display` | Montserrat Bold | 32 | 1.2 | Big page titles. |
| `Headline` | Montserrat Bold | 24 | 1.25 | Section headings. |
| `Title` | Montserrat SemiBold | 18 | 1.3 | Titles of cards, dialogs and app bars. |
| `Button` | Montserrat SemiBold | 16 | 1.4 | Labels on buttons. |
| `BoldBody` | Montserrat Bold | 16 | 1.4 | Emphasis inside body text. |
| `Body` | Montserrat Medium | 16 | 1.4 | Default text. |
| `Label` | Montserrat SemiBold | 14 | 1.3 | Field labels and small controls. |
| `Caption` | Montserrat SemiBold | 12 | 1.3 | Hints and small print. |
| `Mono` | Roboto Mono | 13 | 1.35 | Code and numbers that must line up. |

`Line height` is a multiple of the size. A `Body` line is 16 × 1.4 = 22.4 pixels tall.

!!! note

    `BoldBody` is in the default theme but not in the `ThemeTypography` type. Read it with `theme.Typography.BoldBody`, which the `[string]` index allows.

## Fonts

`theme.Fonts` holds three fonts for your own use:

| Name | Value |
| ---- | ----- |
| `Heading` | Montserrat Bold |
| `Body` | Montserrat Medium |
| `Mono` | Roboto Mono |

## Add or replace a scale

Pass `Typography` to `Theme.create`. Scales you do not name keep their defaults.

```luau
local theme = Pantheon.Theme.create("Light", {
	Typography = {
		Hero = { Font = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.ExtraBold), Size = 48, LineHeight = 1.1 },
	},
})

scope:Text({ Text = "Welcome", Variant = "Hero" })
```

## Text size setting

When the player picks a larger text size in Roblox, Pantheon multiplies every `Size` and rounds it. Spacing and corners do not change.

| Setting | Multiplier | `Body` size |
| ------- | ---------- | ----------- |
| `Medium` | 1 | 16 |
| `Large` | 1.15 | 18 |
| `Larger` | 1.3 | 21 |
| `Largest` | 1.5 | 24 |
