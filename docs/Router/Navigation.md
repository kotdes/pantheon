# Navigation

Use the router to move between routes, link to them and show which one is current.

## How it works

| Method | What it does |
| ------ | ------------ |
| `router:Push(target)` | Goes to a target and adds it to the history. Returns `false` if it does not go. |
| `router:Replace(target)` | Goes to a target and replaces the current history entry. |
| `router:Back()`, `router:Forward()`, `router:Go(n)` | Moves through the history. |
| `router:Link(target)` | Returns a function that pushes the target. Use it for `OnClick`. |
| `router:Resolve(target)` | Returns the route for a target without going there. |
| `router:Href(target)` | Returns the URL for a target. |
| `router:Active(target, exact)` | Returns a state. It is `true` while the current route is the target, or below it. Set `exact` to `true` to match the target only. |

A target is one of these:

- a path, such as `"/project/Work"`
- a route name, such as `"today"`
- a table with a `Name` or a `Path`, and optional `Params` and `Query`

```luau
router:Push({ Name = "project", Params = { id = "Home" }, Query = { tab = "open" } })
```

## Choose between Push and Replace

Use `Push` when the player goes somewhere new. Back then returns to where they were.

Use `Replace` when Back should not return to the old route. For example, use it to update the query as the player types in a search field. A `Push` for each letter would fill the history.

Pantheon Router does not add an entry when you push the route the player is already on.

## Show which route is current

`router.Route` is the current route, as a Fusion state. `router.CanGoBack` and `router.CanGoForward` say whether the history has somewhere to go.

Because they are states, you can pass them straight to components. Use `router:Active` to highlight the current route in a menu:

```luau
scope:MenuButton({
	Text = "Today",
	Selected = router:Active("/today"),
	OnClick = router:Link("/today"),
})
```

`Active` stays `true` below the target. `router:Active("/settings")` is still `true` on `/settings/sort`. Set `exact` to `true` if you do not want that.

## Find out which way the player moved

Every route has a `Direction`: `"Initial"`, `"Forward"`, `"Back"` or `"Replace"`. A [transition](Transitions.md) uses it to move the views the right way.

## Find the router

Inside a `Render`, any component can call `Router.use()` to get the router. You do not need to pass the router down.

```luau
local function BackButton(scope)
	local router = Router.use() -- (1)!
	return scope:Button({ Text = "Back", OnClick = function() router:Back() end })
end
```

1.  `Router.use()` works only while the route renders. Keep the router in a local variable for callbacks.
