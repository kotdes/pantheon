---
tags:
  - Overlays
  - Components
---

# EmojiPicker

EmojiPicker lets the user choose an emoji. It shows every emoji in one scrolling list, with a heading for each category. It opens as a sheet or as a popover.

## Usage

Call `Components.EmojiPicker` with a scope and a table of properties:

```luau
scope:EmojiPicker({
	Layer = overlayLayer,
	Open = open,
	OnPick = function(emoji)
		print("Chose", emoji)
	end,
	OnClose = function()
		open:set(false)
	end,
})
```

## Variants

| `Variant` | What the user sees |
| `SheetBelow` | `number` | :x: | `560` | With the popover variant, the picker is a sheet when its layer is narrower than this many pixels, or too short for the popover. It follows the size of the layer as it changes, so a window that is sized down gets the sheet. |
| --------- | ------------------ |
| `"Sheet"` (default) | An [AppSheet](./AppSheet.md). The title is the name of the category with a chevron. Pressing it opens a menu of the categories, and choosing one scrolls the list to it. |
| `"Popover"` | A [Popover](./Popover.md) next to `Target`. A row of category icons sits above the list, and pressing one scrolls the list to it. |

The list is built when the picker opens and removed when it closes. The emoji appear one category at a time, so the picker opens at once.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `ZIndex` | `UsedAs<number>` | :x: | The default of the variant | Z index of the picker. The category menu of the sheet sits 20 above it. |
| `Layer` | `Instance` | :x: | The contextual layer | Layer the picker is mounted on. |
| `Open` | `UsedAs<boolean>` | :x: | - | Whether the picker is shown. Follows the state you pass. |
| `Variant` | `"Sheet" \| "Popover"` | :x: | `"Sheet"` | How the picker opens. |
| `Target` | `Instance` | :x: | - | The element the popover is placed next to. Only for `"Popover"`. |
| `Placement` | `"Auto" \| "Bottom" \| "Top" \| "Left" \| "Right"` | :x: | `"Auto"` | Preferred side of `Target`. Only for `"Popover"`. |
| `Width` | `number` | :x: | `328` | Width of the popover in pixels. |
| `Height` | `number` | :x: | `360` | Height of the popover in pixels. |
| `Detent` | `number` | :x: | `0.6` | Height of the sheet as a fraction of its layer. |
| `Title` | `UsedAs<string>` | :x: | `"Emojis"` | Title the sheet shows to assistive tools. The category menu replaces it on screen. |
| `CloseOnPick` | `boolean` | :x: | `true` | Close the picker after the user chooses an emoji. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnPick: (emoji: string) -> ()` | Runs with the emoji the user chose. |
| `OnClose: () -> ()` | Runs when the picker asks to close: after a choice, or when the user presses outside it or the close button. Set `Open` to `false` here. |

## The emoji data

`Pantheon.Emoji` is the list of categories, each with a `Name`, an `Icon` (a Lucide name) and `Emojis`. Use it if you need the same list somewhere else.

The category at the top of the list is the selected one. In the popover, its tab icon is in the primary colour and the others are muted. In the sheet, the category name rolls to the new name as you scroll. Pressing a category scrolls to it, and keeps it selected while the list scrolls past the ones in between.

## See also

- [AppSheet](./AppSheet.md)
- [Popover](./Popover.md)
