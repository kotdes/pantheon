# Directives

A directive adds behaviour to any component without the component having a property for it. You put it in the properties of the component, as a key:

```luau
local tw = Pantheon.Directives.Tag(tag)

scope:Button({
	Text = "Save",
	[tw] = "px-4 rounded-md",
})
```

Pantheon takes the directive out of the properties before the component sees them. It builds the component, and then applies the directive to the instance the component returns, which is its root.

Use a directive for something that is not part of how a component looks or is used, such as a utility class or a tag for tests. Anything the user sees as a setting of the component stays a plain property.

Directives work with `scope:Button(...)` and with `Pantheon.Components.Button(scope, ...)`. A component that you call straight from its module does not get them.

## Utility classes with Tilly

[Tilly](https://github.com/imavafe/tilly) gives Roblox Tailwind-style utility classes. It is not a dependency of Pantheon. Install it yourself, create it with a `StyleSheet`, and give the `tag` function it returns to `Directives.Tag`:

```luau
local Tilly = require(Packages.Tilly)

local tag, destroy = Tilly(styleSheet)
local tw = Pantheon.Directives.Tag(tag)

scope:Card({ [tw] = "p-4 bg-neutral-900" })
```

The value is a string of classes, or a state that holds one. When the state changes, Pantheon removes the old classes from the instance and adds the new ones.

!!! note

    Tilly changes how the instance looks through `StyleRule`s. If a component sets the same property itself, the result depends on the order the engine applies them in.

## Writing your own

`Directives.create` makes a directive from a function. The function runs once with the scope, the value you gave the directive, and the root instance:

```luau
local testId = Pantheon.Directives.create(function(scope, value, target)
	target:SetAttribute("TestId", Fusion.peek(value))
end)

scope:Switch({ [testId] = "sound-toggle" })
```

Anything the directive needs to clean up can be put in `scope`, like other Fusion objects.
