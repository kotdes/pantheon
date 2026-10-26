# Pantheon Router

Pantheon Router is a router for [Fusion](https://elttob.uk/Fusion/) 0.3 and later on Roblox. The current route is a Fusion state. Each route renders in its own scope, and Pantheon Router cleans up that scope when you leave the route. This is a successor to Koute and FusionRouter, with a simpler API and more features for power users and advanced large-scale applications. It is designed for single-page apps, but it can also be used for multi-page apps.

It works with any Fusion scope. It is made for [Pantheon](https://github.com/kotdes/pantheon), but it does not depend on Pantheon, so you are more than welcome to just take the router and use it in your own Fusion project.

## Install

Start by adding Pantheon Router with pesde:

```sh
pesde add kotdes/pantheon_router --alias PantheonRouter
```

### Source
In case you need to use the source directly, the source code is in the Pantheon main repository, in [`libs/router`](https://github.com/kotdes/pantheon/tree/main/libs/router).

## Get started

You can give `Router.mount` a table of paths and functions. It will return a view and the router. All you need to do is put the view in a `ScreenGui` and call `router:Push()` to change the route.

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

The router always starts on the `"/"` route by default just like how a web browser works. To start somewhere else, or if you have no `"/"` route, set `Initial` in the [options](#options).

## Documentation

Read the full documentation at [pantheon.7kayoh.net/Router](https://pantheon.7kayoh.net/Router/). It covers routes and paths, nested routes, navigation, loading data, guards and transitions. The pages are in `docs/Router` in the Pantheon repository.

## Run the tests

The tests use [TestEZ](https://roblox.github.io/testez/). They cover the path, history, router and view logic.

To run them, you need the [`luau`](https://github.com/luau-lang/luau) command line tool and [Wally](https://github.com/UpliftGames/wally):

```sh
wally install
tests/run.sh
```

The tests do not cover `RouteView`, `Router.use()` and `Transitions` as they are hard to test in a headless environment.

## Licence

Pantheon Router uses the MIT licence. Read `LICENSE` for the full text.
