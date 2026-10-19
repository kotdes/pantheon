---
tags:
  - Overlays
  - Components
---

# Popover

Popover opens a [Menu](./Menu.md) next to an element. A press anywhere else closes it.

## Usage

Call `Components.Popover` with a scope and a table of properties:

```luau
local open = scope:Value(false)
local button = scope:Button({ Text = "Options", OnClick = function() open:set(true) end })

scope:Popover({
	Layer = overlayLayer,
	Target = button,
	Open = open,
	Placement = "Bottom",
	Items = {
		{ Text = "Rename", Icon = "pencil" },
		{ Text = "Delete", Color = "error" },
	},
	OnClose = function()
		open:set(false)
	end,
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Open` | `UsedAs<boolean>` | :x: | - | Whether the popover is shown. Follows the state you pass. |
| `Target` | `Instance` | :x: | - | The element the popover is placed next to. |
| `Placement` | `"Bottom" \| "Top" \| "Left" \| "Right"` | :x: | `"Bottom"` | Preferred side of the target: `"Bottom"`, `"Top"`, `"Left"` or `"Right"`. |
| `Items` | `{ any }` | :x: | - | Menu rows. See [MenuButton](./MenuButton.md). |
| `Sections` | `{ MenuSectionProps }` | :x: | - | Groups of rows. See [MenuSection](./MenuSection.md). |
| `MaxHeight` | `number` | :x: | - | Largest height in pixels of the menu. It scrolls past that. |
| `Children` | `any` | :x: | - | Menu content built from [MenuSection](./MenuSection.md) and [MenuButton](./MenuButton.md). |
| `Width` | `number` | :x: | `240` | Width of the popover in pixels. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClose: () -> ()` | Runs when the user presses outside the popover, or an item that closes it. |

## See also

- [Menu](./Menu.md)
- [Tooltip](./Tooltip.md)
