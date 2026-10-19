---
tags:
  - Overlays
  - Components
---

# Coachmark

Coachmark points at an element to introduce it. It dims everything else, cuts a hole around the element, rings it with a pulse and shows a card with some text and a button.

## Usage

Call `Components.Coachmark` with a scope and a table of properties:

```luau
local open = scope:Value(true)

scope:Coachmark({
	Layer = overlayLayer,
	Target = newButton,
	Open = open,
	Step = "1 of 3",
	Title = "Try this first",
	Text = "The new button starts a project.",
	OnDismiss = function()
		open:set(false)
	end,
})
```

## Scrim

The scrim is four rectangles around the element, not one dimmed layer, so the element stays visible and can still be pressed.

## Position

The card and the pulse are placed in the space of the layer and kept inside it, so inside a [Window](../Navigation/Window.md) the card stays in the window.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Target` | `Instance` | :white_check_mark: | - | The element to point at. |
| `Open` | `UsedAs<boolean>` | :x: | - | Whether the coachmark is shown. Pass a `Value` so the card can close itself. |
| `Title` | `string` | :x: | - | Heading of the card. |
| `Text` | `string` | :x: | - | Text of the card. |
| `Step` | `string` | :x: | - | Small caption above the title, such as `"1 of 3"`. |
| `ActionText` | `string` | :x: | `"Got it"` | Label of the button. It also dismisses the coachmark. |
| `Placement` | `TooltipPlacement` | :x: | `"Auto"` | Preferred side of the target for the card. |
| `Spotlight` | `boolean` | :x: | `true` | Dim everything except the target. |
| `Dim` | `number` | :x: | `0.55` | How dark the scrim is, from `0` to `1`. |
| `DismissOnScrim` | `boolean` | :x: | `false` | Close the coachmark when the dimmed area is pressed. |
| `TargetPadding` | `number` | :x: | `6` | Space in pixels around the cut-out. |
| `Gap` | `number` | :x: | `16` | Space in pixels between the target and the card. |
| `Width` | `number` | :x: | `280` | Width of the card in pixels. |
| `Tone` | `"Primary" \| "Surface"` | :x: | `"Primary"` | `"Primary"` for a card in the brand colour, `"Surface"` for a plain card. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnAction: () -> ()` | Runs when the button is pressed. |
| `OnDismiss: () -> ()` | Runs when the coachmark closes. |

## See also

- [Tooltip](./Tooltip.md)
