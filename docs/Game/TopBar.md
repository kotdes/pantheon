---
tags:
  - Game
  - Components
---

# TopBar

!!! note

    Parent the bar to a `ScreenGui` with `IgnoreGuiInset` set to `true`. The bar adds its own top margin of 12 px.

TopBar is a row of round icon buttons docked to the top left and top right of the screen, as in the Roblox top bar. A button can have a badge and can be highlighted while its panel is open.

## Usage

Call `Pantheon.Game.TopBar` with a scope and a table of properties:

```luau
local Game = Pantheon.Game

local unread = scope:Value(3)
local chatOpen = scope:Value(false)

Game.TopBar(scope, {
	Left = {
		{ Id = "menu", Text = "≡" },
		{
			Id = "chat",
			Image = "rbxassetid://0", -- (1)!
			Badge = unread,
			Active = chatOpen,
			OnClick = function()
				chatOpen:set(not peek(chatOpen))
			end,
		},
	},
	Right = { { Id = "settings", Text = "⚙" } },
})
```

1.  An item shows `Image`, or `Text` when it has no image.

## Items

| Field | Type | Description |
| ----- | ---- | ----------- |
| `Id` | `string` | Name of the button. |
| `Image` | `string?` | Asset ID of the icon. |
| `Text` | `string?` | Text shown when there is no image. |
| `Badge` | `number` or `State<number>` | Number in the red marker on the corner. A value of `0` hides the marker. |
| `Active` | `boolean` or `State<boolean>` | Highlights the button, for example while the panel it opens is shown. |
| `OnClick` | `() -> ()` | Runs when the user presses the button. |

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Left` | `{ TopBarItem }` | :x: | - | Buttons docked to the top left. |
| `Right` | `{ TopBarItem }` | :x: | - | Buttons docked to the top right. |
| `Center` | `Instance` | :x: | - | An element placed in the middle of the bar. |
| `Height` | `number` | :x: | `44` | Height and width of each button in pixels. |
| `LayoutOrder` | `number` | :x: | `0` | Position in a parent layout. |

## See also

- [Hotbar](./Hotbar.md)
