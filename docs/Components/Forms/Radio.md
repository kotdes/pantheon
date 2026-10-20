---
tags:
  - Forms
  - Components
---

# Radio

Radio is one option in a group where the user can choose only one. Most of the time you should use [RadioGroup](./RadioGroup.md), which looks after the group for you.

## Usage

Call `Components.Radio` with a scope and a table of properties:

```luau
local choice = scope:Value("a")

scope:Radio({
	Label = "Option A",
	Checked = scope:Computed(function(use)
		return use(choice) == "a"
	end),
	OnClick = function()
		choice:set("a")
	end,
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Checked` | `UsedAs<boolean>` | :white_check_mark: | - | Whether the option is chosen. It follows the state you pass. |
| `Label` | `UsedAs<string>` | :x: | - | Text next to the button. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the button reacting to input. The component reads this once, when it creates the button. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnClick: () -> ()` | Runs when the user presses the button. The component does not choose itself, so update the state you pass to `Checked`. |

## See also

- [RadioGroup](./RadioGroup.md)
