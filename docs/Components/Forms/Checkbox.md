---
tags:
  - Forms
  - Components
---

# Checkbox

!!! note

    Use a Checkbox when the user chooses items from a list. Use a [Switch](./Switch.md) for a setting that takes effect immediately.

Checkbox lets the user turn one option on or off. The check mark is drawn in two strokes.

<div class="es-preview" data-component="Checkbox"></div>

## Usage

Call `Components.Checkbox` with a scope and a table of properties:

```luau
scope:Checkbox({
	Label = "Remember me",
	Checked = true,
	OnChanged = function(checked)
		print("Checked:", checked)
	end,
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Checked` | `UsedAs<boolean>` | :x: | `false` | The value. A plain value is only the starting value. A `Value` stays in step with the control: the user's changes set it, and setting it changes the control. |
| `Label` | `UsedAs<string>` | :x: | - | Text next to the box. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the box reacting to input. The component reads this once, when it creates the checkbox. |
| `Id` | `string` | :x: | - | Key that identifies this component when state is kept across rebuilds. See [Persist](../../Guides/PersistingState.md). |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (boolean) -> ()` | Runs with the new value when the user turns the box on or off. |

## See also

- [Switch](./Switch.md)
- [RadioGroup](./RadioGroup.md)
