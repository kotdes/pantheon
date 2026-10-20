---
tags:
  - Forms
  - Components
---

# Form

Form puts its children in a column with equal spacing. It can have a title. It grows to fit its children.

## Usage

Call `Components.Form` with a scope and a table of properties:

```luau
scope:Form({
	Title = "Sign in",
	Children = {
		scope:TextField({ Label = "Email" }),
		scope:TextField({ Label = "Password" }),
		scope:Button({ Text = "Continue", Variant = "Filled" }),
	},
})
```

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Title` | `UsedAs<string>` | :x: | - | Heading above the children. |
| `Children` | `any` | :x: | - | The content of the form. |
