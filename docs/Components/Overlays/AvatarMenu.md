---
tags:
  - Overlays
  - Components
---

# AvatarMenu

AvatarMenu is an account popover. It has a profile header with a picture and name and a menu of actions below it.

## Usage

Call `Components.AvatarMenu` with a scope and a table of properties:

```luau
scope:AvatarMenu({
	Layer = overlayLayer,
	Target = avatarButton,
	Open = open,
	Name = "Ada Lovelace",
	Subtitle = "ada@example.com",
	Initials = "AL",
	Items = {
		{ Text = "Account", Icon = "user" },
		{ Text = "Sign out", Icon = "log-out", Color = "error" },
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
| `Open` | `UsedAs<boolean>` | :x: | - | Whether the menu is shown. Follows the state you pass. |
| `Target` | `Instance` | :x: | - | The element the menu is placed next to. |
| `MorphTarget` | `Instance` | :x: | `Target` | The element that the shape grows out of when the blueprint morphs panels (`FromOrigin`, as in Pantheon). Set it to grow out of some other element than the one the panel is placed beside. For a RadialMenu it is also where the ring opens. |
| `Sections` | `{ MenuSectionProps }` | :x: | - | Groups of rows. See [MenuSection](./MenuSection.md). |
| `MaxHeight` | `number` | :x: | - | Largest height of the menu in pixels. |
| `Image` | `string` | :x: | - | Asset ID of the picture in the header. |
| `Initials` | `string` | :x: | `"?"` | Initials shown when there is no picture. |
| `Name` | `UsedAs<string>` | :x: | `"Account"` | Name in the header. |
| `Subtitle` | `UsedAs<string>` | :x: | - | Smaller text under the name. |
| `Items` | `{ any }` | :x: | - | Rows of the menu. See [MenuButton](./MenuButton.md). |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClose: () -> ()` | Runs when the user presses outside the menu or presses a row that closes it. |

## See also

- [Popover](./Popover.md)
- [Avatar](../Foundations/Avatar.md)
