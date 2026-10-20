---
tags:
  - Modules
---

# Validators

A validator is a function that checks a value and returns whether it is valid, and a message when it is not:

```luau
type Validator = (value: any) -> (boolean, string?)
```

[TextField](../Components/Forms/TextField.md), [ChoiceGroup](../Components/Forms/ChoiceGroup.md), [Select](../Components/Forms/Select.md) and [MultiSelect](../Components/Forms/MultiSelect.md) take a list of them in `Validators`. They are checked in order, and the first one that fails shows its message.

```luau
local V = Pantheon.Validators

scope:TextField({
	Label = "Username",
	Validators = { V.required(), V.minLength(3), V.maxLength(20) },
})
```

## Functions

Each function that makes a validator takes an optional message, which replaces the default.

| Name | Passes when | Default message |
| ---- | ----------- | --------------- |
| `required(message?)` | The value is not `nil`, an empty string or an empty list. | `Required` |
| `minLength(n, message?)` | The text has at least `n` characters. | `At least n characters` |
| `maxLength(n, message?)` | The text has at most `n` characters. | `At most n characters` |
| `email(message?)` | The text looks like an email address. An empty text passes. | `Enter a valid email` |
| `pattern(pattern, message?)` | The text matches a Luau pattern. An empty text passes. | `Invalid format` |
| `numberRange(min?, max?, message?)` | The value is a number between `min` and `max`. | `Out of range` |
| `all(list)` | Every validator in `list` passes. | The message of the first that fails |
| `run(list?, value)` | Returns the result of the first validator in `list` that fails, or `true` when they all pass. | |

An empty text passes `email` and `pattern`, so a field that may be left empty does not need a special case. Add `required` for a field that may not be.
