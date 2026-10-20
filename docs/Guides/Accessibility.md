---
description: How Pantheon follows the accessibility settings of the player, works with a keyboard or a gamepad, and checks colour contrast.
---

# Accessibility

Pantheon helps in three ways: the theme follows the accessibility settings of the player, the controls can be used from the keyboard and a gamepad, and a helper checks the contrast of your colours.

## Settings of the player

When you make a theme with `Theme.create`, Pantheon reads the settings of the player and applies them to the theme. This is on by default. Pass `RespectAccessibility = false` to turn it off.

| Setting | Effect |
| ------- | ------ |
| `ReduceMotion` | Springs become almost instant and the press scale is removed. |
| `PreferredTransparency` | A low value makes scrims more opaque. The value is from `0` to `1`. |
| `HighContrast` | Surfaces and text move towards their extremes. |
| `PreferredTextSize` | The sizes of the type scales are multiplied by `1` for `"Medium"`, `1.15` for `"Large"`, `1.3` for `"Larger"` and `1.5` for `"Largest"`. |

`ReduceMotion`, `PreferredTransparency` and `PreferredTextSize` are read from `UserGameSettings.ReducedMotion`, `GuiService.PreferredTransparency` and the preferred text size of the player. `HighContrast` is not read from the system, so it is only on when you give it.

## Setting them yourself

To use fixed settings, for a storybook or a test, give them to `Theme.create`:

```luau
local theme = Pantheon.Theme.create("Light", {
	Accessibility = {
		ReduceMotion = true,
		PreferredTransparency = 0.2,
		PreferredTextSize = "Large",
	},
})
```

You can also apply settings to a theme you already have:

```luau
local adjusted = Pantheon.Accessibility.apply(theme, { HighContrast = true })
```

`Accessibility.apply` returns a copy of the theme. `Accessibility.read` returns the settings of the player. `Accessibility.motionSpeed(theme, multiplier)` returns the spring speed of the theme times `multiplier`, or the speed of the theme alone when reduced motion is on, for animation of your own.

## Keyboard and gamepad

Every control that reacts to input, such as buttons, switches, checkboxes, radio buttons, segmented controls, menu rows, list rows and the keypoints of a curve editor, can take focus. Text fields can too.

| Key | What it does |
| --- | ------------ |
| Tab, Shift+Tab | Moves focus to the next or previous control, in reading order: top to bottom, then left to right. |
| Enter, Space | Activates the focused control, as a click does. |
| Arrow keys | On a slider, change the value by one step. Home and End jump to the ends. On a segmented control, move to the next segment. On a split pane divider, move the divider. In the Explorer, move through the tree. |
| Escape | Closes the open dialog, sheet, drawer, popover, menu, select or radial menu. The gamepad B button does the same. |

The focused control is drawn with a ring, in place of the white box Roblox draws. On a gamepad, focus is Roblox's own `GuiService.SelectedObject`, so the thumbstick and the D-pad move it and the A button activates the control.

### Dialogs and sheets

While a dialog, an app sheet, a navigation drawer or a popover is open, Tab stays inside it. Focus moves to its first control when it opens, and goes back to where it was when it closes.

### In your own components

[Focus](../Modules/Focus.md) is the module behind this. A control you make yourself joins in with one call:

```luau
Pantheon.Focus.manage(myButton, theme)
```

Enter and Space then activate it by running the handler you gave to `OnEvent("Activated")`.

## Contrast

`Accessibility.audit` checks a theme against WCAG 2.1 AA. Text on the colour it is drawn on needs a contrast ratio of 4.5, and controls and their borders need 3:

```luau
for _, finding in Pantheon.Accessibility.audit(theme) do
	if not finding.Ok then
		print(`{finding.Foreground} on {finding.Background}: {finding.Ratio}`)
	end
end
```

The default themes pass for text. The soft `Outline` colour has a ratio of about 1.7 on `Surface`, which is below 3 on purpose, since the thin borders it draws are decoration next to a fill. Turn on `HighContrast` and it becomes a strong line. If your design uses `Outline` as the only sign that an input is there, use a darker colour for it.

## What is not covered

Roblox has no screen reader support for custom interface, so the components cannot name themselves to a screen reader. The things above, keyboard use, focus, motion, text size and contrast, are what can be done.
