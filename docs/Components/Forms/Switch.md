---
tags:
  - Forms
  - Components
---

# Switch

Switch turns a setting on or off. The handle stretches as it moves. The track can show I and O marks.

<div class="es-preview" data-component="Switch"></div>

## Usage

Call `Components.Switch` with a scope and a table of properties:

```luau
scope:Switch({
	Label = "Notifications",
	Checked = true,
	OnChanged = function(on)
		print("Notifications", on)
	end,
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Checked` | `UsedAs<boolean>` | :x: | `false` | The value. A plain value is only the starting value. A `Value` stays in step with the control: the user's changes set it, and setting it changes the control. |
| `Label` | `UsedAs<string>` | :x: | - | Text next to the switch. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the switch reacting to input. The component reads this once, when it creates the switch. |
| `Icons` | `boolean` | :x: | `theme.Controls.SwitchIcons` | Show the I and O marks on the track. Overrides `theme.Controls.SwitchIcons`. |
| `Id` | `string` | :x: | - | Key that identifies this component when state is kept across rebuilds. See [Persist](../../Guides/PersistingState.md). |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (boolean) -> ()` | Runs with the new value when the user turns the switch on or off. |

## See also

- [Checkbox](./Checkbox.md)
