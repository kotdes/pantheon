---
tags:
  - Navigation
  - Components
---

# AppBar

AppBar is the bar at the top of a screen or a [Window](./Window.md), with a title, an optional leading control and actions at the end.

## Usage

Call `Components.AppBar` with a scope and a table of properties:

```luau
scope:AppBar({
	Title = "Library",
	Leading = scope:IconButton({ Name = "menu", OnClick = openDrawer }),
	Actions = { scope:IconButton({ Name = "search" }) },
	FadeAtTop = true, -- (1)!
	ScrollOffset = scrollY,
})
```

1.  With `FadeAtTop` the bar is flat at the top of the content, with no divider or shadow, and becomes raised as `ScrollOffset` grows.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Radius` | `any` | :x: | `{ Metrics.RadiusPanel, 0 }` | Corner radius, as a number or a table with one radius per corner. The default rounds the top corners. |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | `UDim2.new(1, 0, 0, Metrics.AppBarHeight)` | Size of the component. |
| `ZIndex` | `UsedAs<number>` | :x: | `10` | Z index of the component. |
| `Title` | `UsedAs<string>` | :x: | - | Text shown in the bar. |
| `Leading` | `Instance` | :x: | - | Control at the start of the bar, such as a menu button. |
| `Actions` | `{ Instance }` | :x: | - | Controls at the end of the bar, laid out in a row. |
| `Variant` | `"Solid" \| "Gradient"` | :x: | `"Solid"` | `"Gradient"` gives a flat fill that fades out below the controls, with no divider or shadow. In a [Window](./Window.md) the content runs behind the bar. |
| `FadeHeight` | `number` | :x: | `24` | `Gradient` only. Height of the fade below the bar, in pixels. |
| `TitleContent` | `Instance` | :x: | - | Replaces the title text, for example with a button. |
| `FadeAtTop` | `boolean` | :x: | - | Start flat and become raised as the content scrolls under the bar. |
| `ScrollOffset` | `UsedAs<number>` | :x: | - | Scroll position of the content in pixels, as a number or a state. It drives `FadeAtTop`. |
| `FadeRamp` | `number` | :x: | `24` | Scroll distance in pixels over which the bar goes from flat to raised. |
| `FadeTo` | `Color3` | :x: | `Colors.SurfaceContainerHigh` | Fill of the flat bar. Match the content or window fill. |
| `RaisedColor` | `Color3` | :x: | `Colors.Surface` | Fill of the raised bar. |
| `Shadow` | `boolean` | :x: | `true` | Set `false` to remove the shadow. |

## See also

- [Window](./Window.md)
- [NavigationRail](./NavigationRail.md)
