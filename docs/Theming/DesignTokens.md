---
tags:
  - Design tokens
---

# Design tokens

A design token is a named value, such as a colour or a gap, that the theme holds. Use tokens instead of numbers and hex codes, so your interface follows the theme and changes with light and dark mode.

You read tokens from the current theme:

```luau
local theme = Pantheon.Theme.use()

theme.Colors.Primary
theme.Typography.Title
theme.Metrics.SpaceMd
theme.Metrics.RadiusSm
theme.Motion.SpringSpeed
```

## Find a token

| Looking for | Read | Page |
| ----------- | ---- | ---- |
| Colours | `theme.Colors`, `theme.Palette` | [Colours](Colours.md) |
| Font, size and line height | `theme.Typography` | [Typography](Typography.md) |
| Padding, gaps and sizes | `theme.Metrics.Space*` and sizes | [Spacing and sizes](Spacing.md) |
| Rounded corners | `theme.Metrics.Radius*` | [Corners](Corners.md) |
| Springs | `theme.Motion` | [Motion](Motion.md) |

## Names

Tokens use these patterns:

- Sizes go `2xs`, `Xs`, `Sm`, `Md`, `Lg`, `Xl`, `2xl`, `3xl`.
- Spacing starts with `Space`, for example `SpaceMd`. There is no `Padding` token.
- Corners start with `Radius`, for example `RadiusSm`.
- A colour that starts with `On` is the colour of content on the matching base.

The names are case sensitive. `SpaceXs` works. `SpaceXS` is `nil`.

## Override tokens

See [Theming](index.md) to change tokens with `Theme.create`.
