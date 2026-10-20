# Changelog

This page lists what changed in each version of Pantheon Router. The newest version is first. Read [Versions](Versions.md) to find the pages for an older version.

## 0.1.0 (not released)

This is the first version.

- Routes with static segments, parameters and `*`, written as a table of paths or as a list of records.
- Nested routes that show a child where the parent calls `context.Outlet()`.
- `Push`, `Replace`, `Back`, `Forward`, `Go`, `Link`, `Resolve`, `Href` and `Active`.
- The current route, `CanGoBack` and `CanGoForward` as Fusion states.
- Views that update in place when only the parameters change, and a `Key` to rebuild them.
- `Load`, with a pending view and an error view.
- `BeforeLeave`, `BeforeEach` and `BeforeEnter` guards that can cancel, redirect or wait.
- `Router.use()` to find the router while a route renders.
- Transitions, with `Router.Transitions.Slide()`.
