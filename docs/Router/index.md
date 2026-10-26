# Pantheon Router

Use Pantheon Router to show a different part of your interface for each path. It is a router for [Fusion](https://elttob.uk/Fusion/) 0.3 and later on Roblox.

These pages describe Pantheon Router 0.1. Pantheon Router has its own version number, which does not change when Pantheon does. Read [Versions](Versions.md) to find the pages for another version, and the [changelog](Changelog.md) for what changed.

## When to use Pantheon Router

Use Pantheon Router when your interface has several screens that players move between, and you want to:

- go back and forward through the screens they visited
- link to a screen by its path, with parameters such as a project name
- highlight the current screen in a menu
- load data before a screen shows
- stop or redirect a move, for example when there are unsaved changes

## When not to use Pantheon Router

Do not use Pantheon Router for an interface with one screen.

Do not use it to show or hide a small part of a screen, such as a tooltip, a dialogue or a menu. Use a Fusion `Value` for that.

Do not use it to move players between places or servers.

## How it works

Each screen is a route with a path, such as `/project/:id`. The router keeps the current route as a Fusion state, and a history of the routes the player visited.

When the route changes, Pantheon Router shows the new route and removes the old one. Each route builds its interface in its own scope, so everything you make in the scope is cleaned up when the player leaves the route.

Pantheon Router works with any Fusion scope. It is made for [Pantheon](https://github.com/kotdes/pantheon), but it does not depend on Pantheon.

## Install

Add Pantheon Router with pesde:

```sh
pesde add kotdes/pantheon_router --alias PantheonRouter
```

The source is in the Pantheon repository, in [`libs/router`](https://github.com/kotdes/pantheon/tree/main/libs/router).

## Get started

Give `Router.mount` a table of paths and functions. It returns a view and the router. Parent the view yourself.

```luau
local Router = require(Packages.PantheonRouter)

local view, router = Router.mount(scope, {
	["/"] = function(scope)
		return scope:Text({ Text = "Home" })
	end,
	["/project/:id"] = function(scope, context)
		return scope:Text({ Text = context.Param("id") }) -- (1)!
	end,
})

view.Parent = screenGui
router:Push("/project/Work")
```

1.  `context.Param("id")` is a Fusion state. When you go from `/project/Work` to `/project/Home`, the text changes and the view stays.

The router starts on the `"/"` route. To start somewhere else, or if you have no `"/"` route, set `Initial` in the [options](#options).

You do not need the other pages to get started. Each page adds one feature.

## Pages

- [Routes and paths](Routes.md): write routes, paths and parameters, and use the context.
- [Nested routes](NestedRoutes.md): show one route inside another.
- [Navigation](Navigation.md): move between routes, link to them and find the router.
- [Load data](LoadData.md): load data before a route shows.
- [Guards](Guards.md): stop, redirect or wait before a move.
- [Transitions](Transitions.md): animate between routes.

## Options

To set more than the routes, pass options. Both `Router.mount(scope, options, viewProps)` and `Router.new(scope, options)` take them:

| Option | What it does |
| ------ | ------------ |
| `Routes` | The routes, as a table of paths or a list of records. |
| `Initial` | Where to start. The default is `"/"`. |
| `BeforeEach` | A guard that runs before every move. |
| `OnChanged` | Runs after every move. It receives the new route and the old route. |
| `HistoryLimit` | The most entries in the history. The default is 100. |

To make a router without a view, use `Router.new`. To show a router somewhere else, use `Router.RouteView(scope, { Router = router })`. You can make more than one router.
