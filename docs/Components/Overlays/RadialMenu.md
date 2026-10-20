---
tags:
  - Overlays
  - Components
---

# RadialMenu

RadialMenu shows a ring of choices around the pointer, as in the emote wheel of many games. Point in the direction of a choice and release the key, or click it.

## Usage

Call `Components.RadialMenu` with a scope and a table of properties:

```luau
scope:RadialMenu({
	Layer = overlayLayer,
	Hotkey = Enum.KeyCode.Q, -- (1)!
	Title = "Emote",
	Items = {
		{ Id = "wave", Icon = "hand", Text = "Wave" },
		{ Id = "dance", Icon = "music", Text = "Dance" },
		{ Id = "sit", Icon = "armchair", Text = "Sit" },
	},
	OnSelect = function(id)
		print("Chose", id)
	end,
})
```

1.  Hold the key to open the ring where the pointer is. Move toward a choice and let go to pick it. Without `Hotkey`, open it by setting `Open`, and click a choice to pick it.

## Choosing

The choice under the pointer is the one in its direction from the centre of the ring, so you do not have to reach it. A small area in the middle chooses nothing. The name of the highlighted choice is shown in the middle.

With a gamepad, push the left thumbstick toward a choice and press A. B closes the ring, and so does Escape.

## Layer

The ring is mounted on a layer, so it needs `Layer`, or one from `Layer.Provide` or `Layer.bind`. Without one, the component warns.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |

## See also

- [Menu](./Menu.md)
- [Popover](./Popover.md)
