---
tags:
  - Layout
  - Components
---

# ScrollArea

ScrollArea is a scrolling container with its own scroll bar. It scrolls with the mouse wheel and keeps moving after a flick. It stretches past the edge and springs back. You can run an action when the user pulls past the top, for example to refresh.

## Usage

Call `Components.ScrollArea` with a scope and a table of properties:

```luau
scope:ScrollArea({
	Size = UDim2.fromScale(1, 1),
	Children = {
		scope:Text({ Text = "Long content" }),
	},
	OnRefresh = function() -- (1)!
		reload()
	end,
})
```

1.  `OnRefresh` is called when the user pulls past the top and lets go. While the user pulls, a hint shows what will happen. It is not limited to refreshing.

## Controls inside a scroll area

A control inside the area that follows a drag, such as a slider or a colour picker, keeps the drag to itself. The area does not scroll along with it.

## Virtual content

To show a very long list, use [VirtualList](./VirtualList.md), which is built on ScrollArea. Set `ContentLayout = "None"` and `ContentPadding = 0` if you place content yourself.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Visible` | `UsedAs<boolean>` | :x: | `true` | Whether the component is shown. |
| `ZIndex` | `UsedAs<number>` | :x: | - | Z index of the component. |
| `Children` | `any` | :x: | - | Content of the area. It is stacked in a list, unless `ContentLayout` is `"None"`. |
| `Orientation` | `"Vertical" \| "Horizontal"` | :x: | `"Vertical"` | Direction of scrolling. |
| `ScrollBarThickness` | `number` | :x: | `8` | Width of the scroll bar thumb in pixels. |
| `ScrollBarColor` | `Color3` | :x: | `Colors.Outline` | Colour of the thumb. |
| `ScrollBarActiveColor` | `Color3` | :x: | `Colors.Primary` | Colour of the thumb while it is dragged. |
| `ScrollBarRailThickness` | `number` | :x: | `2` | Width of the thin line the thumb moves along, in pixels. |
| `ScrollBarRailBackground` | `boolean` | :x: | `true` | Draw the line the thumb moves along. |
| `ScrollBarRailColor` | `Color3` | :x: | `Colors.OutlineVariant` | Colour of that line. |
| `ScrollBarPadding` | `number` | :x: | `6` | Space between the scroll bar and the edge of the area, in pixels. |
| `Smooth` | `boolean` | :x: | `true` | Animate wheel scrolling instead of jumping. |
| `Inertia` | `boolean` | :x: | `true` | Keep scrolling for a moment after a flick. |
| `Keyboard` | `boolean` | :x: | `true` | Scroll with the arrow keys, Page Up, Page Down, Home and End. |
| `AutoCanvas` | `boolean` | :x: | `true` | Size the scrollable area to the content. |
| `CanvasSize` | `UsedAs<UDim2>` | :x: | - | Size of the scrollable area. Use it when `AutoCanvas` is `false`. |
| `ScrollBarRail` | `boolean` | :x: | `true` | Pressing the line the thumb moves along jumps there. |
| `AutoHideScrollBar` | `boolean` | :x: | `true` | Fade the scroll bar out when it is not in use. |
| `ScrollBarOverlay` | `boolean` | :x: | `false` | Draw the scroll bar over the content. By default the content gives up a column of its width to the bar while it scrolls. |
| `AutoHideDelay` | `number` | :x: | `0.85` | Time in seconds before the scroll bar fades out. |
| `ScrollButtons` | `boolean` | :x: | `false` | Show buttons at the ends of the scroll bar. |
| `ScrollButtonStep` | `number` | :x: | `64` | Distance in pixels one press of a scroll button scrolls. |
| `ScrollOffset` | `UsedAs<number>` | :x: | `0` | Scroll position in pixels. Pass a `Value` to also scroll from code. |
| `Overscroll` | `boolean` | :x: | `true when Inertia` | Let the content stretch past its edges and spring back. When left out it is on if `Inertia` is on or `OnRefresh` is set. |
| `RefreshThreshold` | `number` | :x: | `72` | How far in pixels the user must pull for `OnRefresh` to run. |
| `PullIndicator` | `boolean` | :x: | `true when OnRefresh is set` | Show the hint while pulling. On when `OnRefresh` is set. |
| `Refreshing` | `boolean \| State<boolean>` | :x: | | True while refreshing. The content rests at the threshold with a spinner until it turns false. |
| `RefreshingHint` | `string` | :x: | `"Refreshing…"` | Text beside the spinner while `Refreshing`. |
| `PullHint` | `string` | :x: | `"Keep scrolling to continue"` | Hint shown while the pull is short of the threshold. |
| `ReleaseHint` | `string` | :x: | `"Release to continue"` | Hint shown once the pull is past the threshold. |
| `DragToScroll` | `boolean` | :x: | `touch, or mouse when OnRefresh is set` | Scroll by dragging anywhere in the area. On for touch. With a mouse it is on when `OnRefresh` is set. |
| `ContentLayout` | `"List" \| "None"` | :x: | `"List"` | `"List"` stacks the children. `"None"` leaves them where you put them. |
| `ContentPadding` | `number` | :x: | `Metrics.SpaceMd` | Padding around the content in pixels. Use `0` for virtual lists. |
| `ListPadding` | `number` | :x: | `Metrics.SpaceLg` | Gap between children in pixels. |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnScroll: (offset: number) -> ()` | Runs with the scroll position in pixels when it changes. |
| `OnRefresh: () -> ()` | Runs when the user pulls past the top and lets go. |
| `OnPullCancel: () -> ()` | Runs when the user pulled but let go before reaching the threshold. |

## See also

- [VirtualList](./VirtualList.md)
