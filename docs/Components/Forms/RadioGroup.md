---
tags:
  - Forms
  - Components
---

# RadioGroup

RadioGroup shows a list of options. The user chooses one.

## Usage

Call `Components.RadioGroup` with a scope and a table of properties:

```luau
local plan = scope:Value("free")

scope:RadioGroup({
	Options = {
		{ Value = "free", Label = "Free" },
		{ Value = "pro", Label = "Pro" },
	},
	Value = plan, -- (1)!
})
```

1.  `Value` is the state of the group. The group sets it when the user chooses an option. If you set it, the choice changes to match.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Options` | `{ RadioOption }` | :white_check_mark: | - | The options, each with a `Value` and a `Label`. |
| `Value` | `UsedAs<string>` | :x: | - | A `Value<string>` that holds the chosen option. If you leave it out, the group keeps its own state and starts on the first option. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the options reacting to input. The component reads this once, when it creates the group. |
| `Id` | `string` | :x: | - | Key that identifies this component when state is kept across rebuilds. See [Persist](../../Guides/PersistingState.md). |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (string) -> ()` | Runs with the `Value` of the option the user chose. |

## See also

- [Radio](./Radio.md)
- [ChoiceGroup](./ChoiceGroup.md)
