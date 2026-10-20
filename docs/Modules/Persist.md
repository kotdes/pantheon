---
tags:
  - Modules
---

# Persist

Persist keeps the state of components across rebuilds of an interface. [Persisting state](../Guides/PersistingState.md) explains the idea.

## Functions

| Name | Description |
| ---- | ----------- |
| `createStore: (scope: Scope) -> Store` | Makes a store. Its values live in `scope`, so they last as long as it does. |
| `Provide: (store: Store, build: (...) -> ..., ...) -> ...` | Makes `store` the current store while `build` runs, and returns what it returns. The counters that name components start again, so the same code finds the same state. If `build` errors, the store is restored and the error is raised again. |
| `Id` | A [directive](../Guides/Directives.md) that gives one component an id: `[Persist.Id] = "settings.sound"`. The state is then found by that id, not by the order the component was created in. |
| `key: (kind: string, controlled: boolean?) -> string?` | The key of a component: the id from `Persist.Id`, or `kind` and the number of the component in this build. It is `nil` when there is no store, or when `controlled` is `true`. |
| `value: (scope: Scope, key: string?, slot: string, initial: any) -> Value` | The value for one piece of a component's state. It is the stored one when the key has one, and a new `Value` otherwise. `initial` is only used the first time. |

`key` and `value` are for the components. You only need them to give your own component this behaviour:

```luau
local key = Persist.key("MyToggle")
local on = Persist.value(scope, key, "on", false)
```
