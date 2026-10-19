---
tags:
  - Feedback
  - Components
---

# SnackbarHost

SnackbarHost shows toasts as a stack. The newest is in front and the ones before it peek out behind. Move the pointer over the stack and it spreads out so you can read every toast. It does not return an instance: it returns a table with a `Show` function that adds a toast and a `Clear` function that removes them all.

## Usage

Call `Components.SnackbarHost` with a scope and a table of properties:

```luau
local toasts = scope:SnackbarHost({
	Layer = overlayLayer,
	MaxVisible = 5,
})

local dismiss = toasts.Show("Saved", "Undo", function()
	print("Undone")
end, {
	Icon = "check",
	Dismissible = true, -- (1)!
	Duration = 5,
})

dismiss() -- (2)!
```

1.  `Dismissible` adds a close button to the toast.
2.  `Show` returns a function that dismisses only that toast.

## The stack

While the stack is closed, the newest toast is in front at full size. Each older toast is a little narrower and sits a little higher behind it, and its text is hidden so it reads as a shape. Only the three toasts at the front are shown, and the rest fade out of view.

When the pointer is over the stack or next to it, the toasts spread out into a column and their timers stop. When the pointer leaves, the stack closes and the timers start again.

## Adding to a toast

`Leading` and `Trailing` in the options add your own elements before the message and after the action button. Give an element, or a function that builds one. A function is called with the scope of the toast, so what it creates is cleaned up with it, and with a function that dismisses the toast:

```luau
toasts.Show("Uploading", nil, nil, {
	Duration = math.huge,
	Trailing = function(toastScope, dismiss)
		return toastScope:Button({ Text = "Cancel", OnClick = dismiss })
	end,
})
```

## Where it goes

The host is mounted on `Layer`, or on a layer set with `Layer.Provide` or `Layer.bind`. Without either, parent `Instance` yourself.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `MaxVisible` | `number` | :x: | `5` | Most toasts kept at once. The oldest is dismissed past that. |
| `Width` | `number` | :x: | `360` | Width of the stack in pixels. |

## Returned table

| Name | Type | Description |
| ---- | ---- | ----------- |
| `Instance` | `Frame` | The host frame. |
| `Show` | `(message: string, actionText: string?, onAction: (() -> ())?, options: ShowOptions?) -> () -> ()` | Shows a toast and returns a function that dismisses it. |
| `Clear` | `() -> ()` | Dismisses every toast. |

## ShowOptions

| Field | Type | Description |
| ----- | ---- | ----------- |
| `Duration` | `number?` | Seconds on screen, `3` by default. `math.huge` keeps it until dismissed. |
| `Icon` | `string?` | Lucide icon before the message. |
| `Leading` | `Instance` or `(scope, dismiss) -> Instance` | Element before the message. |
| `Trailing` | `Instance` or `(scope, dismiss) -> Instance` | Element after the action button. |
| `Dismissible` | `boolean?` | Show a close button. |
| `OnDismiss` | `() -> ()` | Runs when the user presses the close button. |

## See also

- [Snackbar](./Snackbar.md)
