---
tags:
  - Design tokens
---

# Motion

Components animate with Fusion springs. `theme.Motion` sets how they move.

| Name | Default | Meaning |
| ---- | ------- | ------- |
| `SpringSpeed` | 640 | How fast springs move. Higher is faster. |
| `SpringDamping` | 20 | How much springs settle. 1 stops without overshoot. |
| `PressScale` | 1 | Size of a pressed control. 1 means no change. |

```luau
scope:Spring(target, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
```

## Reduced motion

When the player turns on reduced motion in Roblox, Pantheon raises `SpringSpeed` to at least 400, sets `SpringDamping` to 1 and sets `PressScale` to 1. See [Accessibility](../Guides/Accessibility.md).

## Other values

| Field | Default | Meaning |
| ----- | ------- | ------- |
| `Controls.SwitchIcons` | `true` | Show I and O marks on a [Switch](../Components/Forms/Switch.md). |
| `Icons` | `{}` | Names of icons. |
| `Audio` | Empty strings for `open`, `success`, `error` and `confirm` | Asset IDs of sounds. |
