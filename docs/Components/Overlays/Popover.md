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
| `MorphTarget` | `Instance` | :x: | `Target` | The element that the shape grows out of when the blueprint morphs panels (`FromOrigin`, as in Pantheon). Set it to grow out of some other element than the one the panel is placed beside. For a RadialMenu it is also where the ring opens. |
| `Placement` | `"Auto" \| "Bottom" \| "Top" \| "Left" \| "Right"` | :x: | `"Bottom"` | Preferred side of the target. If the popover does not fit on that side, it moves to the opposite side, and it always stays inside its layer. `"Auto"` picks the side with the most room. |
| `Items` | `{ any }` | :x: | - | Menu rows. See [MenuButton](./MenuButton.md). |
| `Sections` | `{ MenuSectionProps }` | :x: | - | Groups of rows. See [MenuSection](./MenuSection.md). |
| `MaxHeight` | `number` | :x: | - | Largest height in pixels of the menu. It scrolls past that. |
| `AutoHeight` | `boolean` | :x: | `true` | Make the popover as tall as its content, up to `MaxHeight`, and change height with a spring when the content or the page changes. Set `false` for a fixed height. |
| `Children` | `any` | :x: | - | Menu content built from [MenuSection](./MenuSection.md) and [MenuButton](./MenuButton.md). |
| `Width` | `number` | :x: | `240` | Width of the popover in pixels. |
| `RootPage` | `string` | :x: | The first page | Id of the first [MenuPage](./MenuPage.md) when `Children` has pages. Set it to `"root"` to show `Items` or `Sections` first. |
| `Page` | `UsedAs<string>` | :x: | - | Id of the page to show. The popover moves to it when it changes. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClose: () -> ()` | Runs when the user presses outside the popover, or an item that closes it. |
| `OnChanged: (string) -> ()` | Runs with the id of the page when the user moves between pages. |

## See also

- [Menu](./Menu.md)
- [Tooltip](./Tooltip.md)
