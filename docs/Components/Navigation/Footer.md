---
tags:
  - Navigation
  - Components
---

# Footer

Footer is the strip at the bottom of a [Window](./Window.md). It holds controls in a row, such as the back and next buttons of a form.

## Usage

```luau
scope:Window({
	Footer = scope:Footer({
		Variant = "Gradient",
		Children = { backButton, nextButton },
	}),
	Children = { page },
})
```

With `Variant = "Gradient"` the fill fades out above the controls and the content scrolls behind the footer. Add padding at the bottom of the content so the last row is clear of the footer when it is not scrolled.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | Full width, `Height` plus the fade | A [Window](./Window.md) sets this for you. |
| `ZIndex` | `UsedAs<number>` | :x: | `10` | Z index of the component. |
| `Height` | `number` | :x: | `Metrics.AppBarHeight` | Height of the controls, in pixels. |
| `Variant` | `"Solid" \| "Gradient"` | :x: | `"Solid"` | `"Gradient"` fades the fill out above the controls, with no divider. |
| `FadeHeight` | `number` | :x: | `24` | `Gradient` only. Height of the fade above the controls, in pixels. |
| `FadeTo` | `Color3` | :x: | `SurfaceContainerHigh` | The fill. Match your window. |
| `Radius` | `any` | :x: | - | Corner radius. A Window sets this to match its own corners. |
| `Children` | `any` | :x: | - | Controls, laid out in a row. |
