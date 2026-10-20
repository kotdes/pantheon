# Nested routes

Use nested routes to show one route inside another.

## When to use nested routes

Use nested routes when part of the interface stays the same while the rest changes. For example, a settings screen can keep its title and menu while the panel beside it changes between Appearance and Sort.

## When not to use nested routes

Do not nest routes only to share the start of a path. Put the routes at the top level, and write the shared start in each path.

## How it works

A parent route shows its child where the parent calls `context.Outlet()`. The path of a child follows the path of its parent, so the child `appearance` of `/settings` is `/settings/appearance`.

```luau
["/settings"] = {
	Redirect = "/settings/appearance", -- (1)!
	Render = function(scope, context)
		return scope:Frame({
			[Children] = {
				scope:Text({ Text = "Settings" }),
				context.Outlet({ LayoutOrder = 2 }),
			},
		})
	end,
	Children = {
		["appearance"] = renderAppearance,
		["sort"] = renderSort,
	},
}
```

1.  A route with `Redirect` sends the player to its target when the route is the match. Use it so that `/settings` opens its first child.

Call `context.Outlet()` once, and parent the result.

When the player moves between the children, the parent stays and only the child changes.

`route.Matched` lists the route and its parents, outermost first.
