---
tags:
  - Game
  - Components
---

# Hotbar

Hotbar is an inventory bar for a game. The number keys equip the slots, items can be dragged between slots, and the backtick key opens the whole inventory in a searchable panel above the bar. It can use your own inventory data or the Roblox backpack.

## Usage

Call `Pantheon.Game.Hotbar` with a scope and a table of properties:

```luau
local Game = Pantheon.Game

local items = scope:Value({
	[1] = { Name = "Sword", Description = "Starter blade", Tags = { "weapon" } },
	[2] = { Name = "Bow", Count = 24 },
	[11] = { Name = "Torch" },
})

Game.Hotbar(scope, {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -16),
	Items = items, -- (1)!
	Slots = 9,
	Capacity = 27,
	OnSelect = function(slot)
		print("Equipped slot", slot)
	end,
})
```

1.  `Items` is a table from slot number to item. Pass a `Value` and a drag writes the new order back to it. Otherwise handle `OnMove`.

## Items

An item is a table with these fields:

| Field | Type | Description |
| ----- | ---- | ----------- |
| `Name` | `string?` | Name shown in the tooltip. Without an `Image`, its first two letters are drawn on the slot. |
| `Description` | `string?` | Second line of the tooltip. |
| `Image` | `string?` | Asset ID of the icon. |
| `Count` | `number?` | Stack size, shown on the slot when it is above `1`. |
| `Cooldown` | `number` or `State<number>` | Part of the cooldown that is left, from `0` to `1`. It draws as a block that shrinks down the slot. |
| `Id`, `Tags` | `string`, `{ string }` | Extra names the search can match. |

Other string fields are searchable too.

## Using the bar

- The number keys `1` to `9` and `0` equip the slot, and pressing the same key again unequips it. Set `BindKeys = false` to handle keys yourself.
- A click equips a slot. Press and drag past a few pixels to pick an item up, and drop it on another slot to swap the two. The equipped item stays with its item.
- The equipped slot turns white with dark content and casts a shadow. A dragged item casts a larger one.
- A slot grows a little when hovered and shows the name and description of its item.

## Slots that have no item

Empty slots are hidden and the bar closes up around the items. They come back while you drag, so you can drop an item on one, and while the inventory is open.

An item that arrives slides up from below, scales up and fades in. A removed item keeps sliding up, scales down and fades out. The space it takes in the bar opens straight away and closes only after the exit animation, so neighbouring slots never overlap.

## The inventory panel

The backtick key opens a panel above the bar. It scales up and slides up as it fades in. It holds a search box and a grid of every slot beyond the bar. The grid is a [VirtualList](../Components/Layout/VirtualList.md) in a [ScrollArea](../Components/Layout/ScrollArea.md), so only the rows in view are built, and it scrolls once it is taller than `ExpandedRows`. The bar shows all its slots, numbered, while the panel is open. Pass a `Value` as `Expanded` to open and close it from code.

## Search

The search box is a [TextField](../Components/Forms/TextField.md). It filters the grid with a fuzzy match, so `hlng` finds `Healing Potion`, and orders the results by how well they match.

A word is matched against the name, the description, the `Id`, the `Tags` and any other string field of the item. To match only one of them, write `scope:text`, for example `name:bow`. Add your own scopes with `SearchScopes`:

```luau
Game.Hotbar(scope, {
	Items = items,
	SearchScopes = {
		type = function(item)
			return item.Type
		end,
	},
})
```

A scope returns a string, or a list of strings, for an item. A search for `type:weapon` then matches those items, and `weapon` alone matches them too.

## Roblox backpack

`Game.Hotbar` does not need a custom inventory. [Backpack](./Backpack.md) turns the tools of a player into the `Items`, `Selected`, `OnSelect` and `OnMove` that the bar needs. The default Roblox backpack is hidden while the bar exists, and shown again when the scope is destroyed. Set `DisableDefault = false` to keep it.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Items` | `any` | :white_check_mark: | - | The items, as a table from slot number to item, or a `Value` of one. |
| `Selected` | `any` | :x: | A state kept by the bar | A `Value<number?>` holding the equipped slot. The bar keeps its own when left out. |
| `Expanded` | `any` | :x: | - | A `Value<boolean>` that says whether the inventory panel is open. |
| `Slots` | `number` | :x: | `9` | Number of slots on the bar. At most 10, one for each number key. |
| `Capacity` | `number` | :x: | `3 × Slots` | Number of slots in all, including the ones only shown in the panel. |
| `Columns` | `number` | :x: | `Slots` | Slots in a row of the panel. |
| `ExpandedRows` | `number` | :x: | `4` | Rows of the panel visible before it scrolls. |
| `SlotSize` | `number` | :x: | `56` | Width and height of a slot in pixels. |
| `BindKeys` | `boolean` | :x: | `true` | Use the number keys to equip slots and the backtick key to open the panel. |
| `DisableDefault` | `boolean` | :x: | `true` | Hide the default Roblox backpack. |
| `SearchScopes` | `{ [string]: (item: any) -> (string \| { string })? }` | :x: | - | Extra scopes for the search. Each is a function from an item to a string or a list of strings. |
| `Position` | `UDim2` | :x: | - | Position of the bar. |
| `AnchorPoint` | `Vector2` | :x: | - | Anchor point of the bar. |
| `LayoutOrder` | `number` | :x: | `0` | Position in a parent layout. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnSelect: (slot: number?) -> ()` | Runs with the slot that was equipped, or `nil` when it was unequipped. |
| `OnMove: (from: number, to: number) -> ()` | Runs with the slot an item was dragged from and the slot it was dropped on. When it is given it owns the inventory, and the bar does not swap the items itself. Without it, the bar swaps the items of a `Value` passed as `Items`. |

## See also

- [Backpack](./Backpack.md)
