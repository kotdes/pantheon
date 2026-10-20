# Guards

Use a guard to stop, redirect or delay a move between routes.

## When to use a guard

Use a guard when a move should depend on something that is not in the path. For example:

- the player has unsaved changes
- the player must be signed in
- a route is no longer available, and the player should go somewhere else

## When not to use a guard

Do not use a guard to change what a route shows. Use `Render`, `Load` or `Redirect` for that.

## How it works

A guard is a function that runs before a move. It receives the route the player is going to, and the route they are leaving. It returns one of these:

- `true`, or nothing, to continue
- `false` to cancel the move
- a target to redirect

```luau
{
	Path = "/editor",
	BeforeLeave = function(to, from)
		if hasUnsavedChanges() then
			return askToDiscard() -- (1)!
		end
	end,
}
```

1.  A guard can yield. Here the move waits until the player answers, and `askToDiscard` returns `true` to go on or `false` to stay.

## Choose where to put a guard

- Use `BeforeLeave` on a route to ask before the player leaves it.
- Use `BeforeEnter` on a route to check before the player enters it.
- Use `BeforeEach` in the router options for a check that applies to every move.

Guards run in this order:

1. `BeforeLeave` of the routes the player leaves, innermost first.
2. `BeforeEach`.
3. `BeforeEnter` of the routes the player enters, outermost first.

The first guard to cancel or redirect decides. The guards after it do not run.

## If another move starts

If another move starts while a guard waits, Pantheon Router drops the waiting move.

## The first route

Guards do not run for the `Initial` route.
