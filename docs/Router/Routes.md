# Routes and paths

Use routes to say what to show for each path.

## How it works

A route has a path and a `Render` function. Pantheon Router shows the route whose path matches the current path.

Give `Router.mount` a table, with a path as each key:

```luau
Router.mount(scope, {
	["/today"] = renderToday,
	["/project/:id"] = { Name = "project", Render = renderProject },
})
```

A `Render` function receives the scope for the route and a [context](#use-the-context). It returns the interface for the route. Pantheon Router cleans up the scope when the player leaves the route, so everything you make in the scope goes with it.

## Choose between a table and a list

Use a table of paths when each route is a `Render` function, or a short record with a `Name` or other options.

Use a list of records when you build the routes in code, or when you want the `Path` next to the other options of the route:

```luau
Router.mount(scope, {
	{ Path = "/today", Name = "today", Render = renderToday },
	{ Path = "/project/:id", Name = "project", Render = renderProject },
})
```

The two forms mean the same. Leave `Path` out of a record that is a value in a table. The key is its path, and a different `Path` is an error.

## Write paths

| Path | Matches | Gives |
| ---- | ------- | ----- |
| `/today` | `/today` | Nothing |
| `/project/:id` | `/project/Work` | `Params.id = "Work"` |
| `/files/*` | `/files/a/b` | `Params["*"] = "a/b"` |

Use `:name` for a part of the path that changes. Use `*` as the last part to match the rest of the path.

When more than one path matches, the most specific one wins. A fixed part beats a parameter, and a parameter beats `*`.

Pantheon Router encodes and decodes parameters and query values for you.

## Use the context

Every `Render` function receives a context:

| Field | Type | Use it for |
| ----- | ---- | ---------- |
| `context.Param(name)` | State | One parameter. It changes only when that parameter changes. |
| `context.Params`, `context.Query` | States | All the parameters, or the query. |
| `context.Route` | State | The current route. |
| `context.Initial` | Value | The route when the view was made. It never changes. |
| `context.Router` | Router | Moving from inside the route. |
| `context.Data` | Value | What `Load` returned. |
| `context.Outlet()` | Function | Showing a child route. |

Use the states to show a parameter. They change in place, so the view keeps its scroll position and its animations when only a parameter changes.

Do not read `context.Initial` for a value that can change while the view stays. It does not update.

## Rebuild a view instead of updating it

By default, a view updates in place when only the parameters change.

Give the route a `Key` when you want a new view instead. Pantheon Router rebuilds the view when the key changes:

```luau
{
	Path = "/project/:id",
	Key = function(route)
		return route.Params.id
	end,
	Render = renderProject,
}
```

Use a `Key` when the old view should not carry over to the new one, for example when you want a [transition](Transitions.md) between the two.

A route with `Load` is always rebuilt when its parameters change, because the data belongs to those parameters.

## Show something when no route matches

If no route matches, `route.Matched` is empty. Give `RouteView` a `NotFound` function to show a message, such as "This page does not exist".

A move to a path that matches no route does not go anywhere.
