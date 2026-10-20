# Load data

Use `Load` to get the data for a route before the route shows.

## When to use Load

Use `Load` when a route needs data before it can render, such as a record from a DataStore or the result of a remote call.

## When not to use Load

Do not use `Load` for data that the route can show as it arrives. Render the route straight away, and update a Fusion state when the data comes.

## How it works

Give a route a `Load` function. It can yield. While it runs, the route shows `Pending`. When it returns, `Render` runs and receives the result as `context.Data`:

```luau
{
	Path = "/project/:id",
	Load = function(context)
		return fetchProject(context.Initial.Params.id)
	end,
	Pending = function(scope)
		return scope:LoadingIndicator({})
	end,
	Error = function(scope, context, err)
		return scope:Text({ Text = "Could not load the project." })
	end,
	Render = function(scope, context)
		return scope:Text({ Text = context.Data.Name })
	end,
}
```

## Show a pending view

Give the route a `Pending` function to show something while `Load` runs. To use the same pending view for every route, set `Pending` on the `RouteView` instead.

If a route has no `Pending`, the view of the previous route stays until the data arrives.

## Show an error

Give the route an `Error` function to show something when `Load` fails. It receives the error as its third argument. To use the same error view for every route, set `Error` on the `RouteView`.

If `Load` fails and there is no `Error`, Pantheon Router warns.

## If the player leaves first

If the player leaves the route before `Load` returns, Pantheon Router drops the result. `Render` does not run.

## Parameters

A route with `Load` is rebuilt when its parameters change, so the data always belongs to the current parameters.
