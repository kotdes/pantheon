---
tags:
  - Overlays
  - Components
---

# ConfirmDialog

!!! warning "Deprecated"
    ConfirmDialog is the same component as [Prompt](./Prompt.md). Use `Prompt` with `Destructive = true`. ConfirmDialog stays so that existing code keeps working.

ConfirmDialog takes every property that Prompt takes, and passes them all on. The only difference is that `Destructive` is `true` unless you set it to `false`.

```luau
-- These are the same.
scope:ConfirmDialog({ Title = "Delete project?", OnConfirm = deleteProject })
scope:Prompt({ Title = "Delete project?", Destructive = true, OnConfirm = deleteProject })
```

## See also

- [Prompt](./Prompt.md)
