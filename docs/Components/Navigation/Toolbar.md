---
tags:
  - Navigation
  - Components
---

# Toolbar

Toolbar is a bar of tool buttons. A button can be a toggle, show a tooltip with its shortcut, and be disabled. Separators group the buttons.

## Usage

Call `Components.Toolbar` with a scope and a table of properties:

```luau
scope:Toolbar({
	Layer = overlayLayer, -- (1)!
	Items = {
		{ Id = "select", Icon = "mouse-pointer", Tooltip = "Select", Shortcut = "V", Toggle = true, Toggled = true },
		{ Id = "move", Icon = "move-3d", Tooltip = "Move", Shortcut = "W", Toggle = true },
		{ Separator = true },
		{ Id = "snap", Icon = "sliders-horizontal", Text = "Snap", Toggle = true, Toggled = snap },
		{ Spacer = true },
		{ Id = "play", Icon = "play", Text = "Play", OnClick = play },
	},
})
```

1.  `Layer` is where the tooltips are mounted. Without it, or a layer from `Layer.Provide` or `Layer.bind`, there are no tooltips.

## Items

| Field | Type | Description |
| ----- | ---- | ----------- |
| `Id` | `string?` | Name of the button. |
| `Icon` | `string?` | Lucide icon. |
| `Text` | `string?` | Label next to the icon. |
| `Tooltip` | `string?` | Tooltip text. It is `Text` when left out. |
| `Shortcut` | `string?` | Added to the tooltip in brackets, such as `Ctrl+S`. |
| `Toggled` | `UsedAs<boolean>?` | Draws the button as pressed in. A state is followed. |
| `Toggle` | `boolean?` | Flips `Toggled` when the button is pressed. A `Value` is set. Without one, the button keeps its own state. |
| `Disabled` | `UsedAs<boolean>?` | Stops the button reacting to input. |
| `OnClick` | `() -> ()` | Runs when the user presses the button. |
| `Separator` | `boolean?` | A thin line between groups. |
| `Spacer` | `boolean?` | Takes the room that is left, pushing the items after it to the end. |
| `Content` | `Instance?` | Your own element in the bar. |

## See also

- [StatusBar](./StatusBar.md)
- [IconButton](../Foundations/IconButton.md)
