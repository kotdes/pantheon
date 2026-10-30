---
tags:
  - Forms
  - Components
---

# TextField

TextField is a text box. Its outline shows when it has focus. It can have a label and helper text, and it can check what the user types. It can also be a multiline editor.

<div class="es-preview" data-component="TextField"></div>

## Usage

Call `Components.TextField` with a scope and a table of properties:

```luau
scope:TextField({
	Label = "Email",
	Placeholder = "you@example.com",
	Helper = "We never share it.",
	Validators = { V.required(), V.email() }, -- (1)!
	OnChanged = function(text)
		print("Typed", text)
	end,
})
```

1.  `V` is `Pantheon.Validators`. The validators run when the field loses focus. If one fails, its message replaces the helper text. If several fail, the first one shows. See [Validators](../../Modules/Validators.md).

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `Text` | `UsedAs<string>` | :x: | `""` | The text. A plain string is only the starting text. A `Value` stays in step with the box: it changes as the user types, and setting it changes the box. |
| `Placeholder` | `UsedAs<string>` | :x: | `""` | Text to show while the box is empty. |
| `Label` | `UsedAs<string>` | :x: | - | Small label above the box. |
| `Helper` | `UsedAs<string>` | :x: | - | Hint under the box. An error replaces it. |
| `Error` | `UsedAs<string>` | :x: | - | Error message to show. It overrides the result of `Validators`. |
| `Multiline` | `boolean` | :x: | `false` | Allow several lines of text. |
| `MinLines` | `number` | :x: | `1`, or `3` when multiline | Height of the box, in lines, when it is empty. |
| `MaxLines` | `number` | :x: | `1`, or `12` when multiline | Greatest height, in lines, that the box grows to. |
| `Resize` | `TextFieldResize` | :x: | `"None"`, or `"Y"` when multiline | Which directions the handle in the corner can resize. |
| `Disabled` | `UsedAs<boolean>` | :x: | `false` | Stops the user editing the box. The component reads this once, when it creates the field. |
| `LeadingIcon` | `string` | :x: | - | Lucide icon at the start of the box. |
| `TrailingIcon` | `string` | :x: | - | Lucide icon at the end of the box. |
| `Action` | `Instance` | :x: | - | A control inside the box, such as an `IconButton` that is 32 pixels square. It sits at the end of a one-line box, and in the bottom right corner of a multi-line box. The box makes room for it. A multi-line box with an `Action` has no resize handle. |
| `Validators` | `{ Validator }` | :x: | - | Validators to run on the text. The component checks them in order. |
| `ValidateOnBlur` | `boolean` | :x: | `true` | Run the validators when the box loses focus. Set it to `false` to use `Error` only. |
| `Compact` | `boolean` | :x: | `false` | A smaller version for fields inside other widgets. It is 28 pixels tall, with less padding and 14-pixel text. |
| `Height` | `number` | :x: | `40`, or `28` when compact | Height of the box, in pixels. |
| `Variant` | `"Outlined" \| "Filled"` | :x: | `"Outlined"` | `Outlined` has a recessed fill and a 1 pixel stroke. `Filled` has a stronger tonal fill and shows a stroke only on focus or on error. |
| `Pill` | `boolean` | :x: | `false`, or from the blueprint for a one-line field | Fully rounded ends. Use it where the field sits next to pill-shaped controls, such as the hex field in a colour picker. |
| `CornerRadius` | `number` | :x: | `RadiusSm`, or concentric in a container | Corner radius in pixels. It wins over `Pill`. |
| `Prefix` | `string` | :x: | - | Fixed text at the start of the box, such as `"#"`. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (string) -> ()` | Runs with the text each time it changes. |
| `OnSubmit: (text: string, box: TextBox) -> ()` | Runs with the text and the `TextBox` when the user presses Enter or clicks away. Use it to confirm the value or to restore the old text. |

## See also

- [Validators](../../Modules/Validators.md)
- [Form](./Form.md)
