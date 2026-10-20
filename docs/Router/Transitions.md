# Transitions

Use a transition to animate the change from one route to another.

## When to use a transition

Use a transition when the movement helps players follow where they are going. For example, a page that slides in the direction of travel shows whether the player went forward or back.

## When not to use a transition

Do not use a transition when the route only updates in place, for example when only a parameter changes. The view stays, so there is nothing to animate. Give the route a [`Key`](Routes.md#rebuild-a-view-instead-of-updating-it) if you want a new view and a transition.

Do not use a long transition for a screen that players move through often.

## How it works

By default, the old view goes as soon as Pantheon Router makes the new one. To animate the change, give `RouteView` a `Transition`:

```luau
Router.mount(scope, routes, {
	ClipsDescendants = true,
	Transition = Router.Transitions.Slide(),
})
```

`Router.Transitions.Slide()` moves the views sideways. When the player goes forward, the new view comes in from the right. When they go back, it comes in from the left. A `Replace` and the first view do not animate.

`Slide` needs both views to be `GuiObject`s, and `ClipsDescendants = true` on the view.

## Write your own transition

A transition is a function. It receives one table:

```luau
Transition = function(info)
	fadeOut(info.Leaving, info.Finish)
end
```

| Field | What it is |
| ----- | ---------- |
| `info.Entering` | The new view. |
| `info.Leaving` | The old view. |
| `info.Direction` | `"Initial"`, `"Forward"`, `"Back"` or `"Replace"`. |
| `info.From`, `info.To` | The old route and the new route. |
| `info.Finish` | A function that removes the old view. |

Call `info.Finish` when your animation ends. If the route changes again first, Pantheon Router removes the old view at once.
