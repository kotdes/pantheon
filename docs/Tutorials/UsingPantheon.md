# Using Pantheon

This page builds a small interface. You need to know the basics of Fusion: values, computeds and scopes. If you do not, read the [Fusion tutorials](https://elttob.uk/Fusion/0.3/tutorials/) first.

## Scopes

Fusion keeps everything it creates in a scope, and destroys it when you clean the scope up. Pantheon has its own `scoped`. It gives you the usual Fusion methods, the instance methods from Iona such as `scope:Frame`, and every Pantheon component, such as `scope:Button`:

```luau
local Pantheon = require(Packages.Pantheon)
local Fusion = Pantheon.Fusion

local scope = Pantheon.scoped()
```

## The theme

Components take their look from a theme. Build your interface inside `Theme.Provide`:

```luau
local theme = Pantheon.Theme.create("Dark")

Pantheon.Theme.Provide(theme, function()
	-- build the interface here
end)
```

If you leave this out, creating a component fails with the error `Pantheon.Theme.Provide required`. To give one component its own theme, use its `Theme` property. See [Theming](../Guides/Theming.md).

## A component

A component is a method on the scope. It takes a table of properties and returns an instance. `scope:Button({ ... })` is the same as `Pantheon.Components.Button(scope, { ... })`, which you can use when you want the typed function:

```luau
local save = scope:Button({
	Text = "Save",
	Variant = "Filled",
	OnClick = function()
		print("Saved")
	end,
})
```

A property of type `UsedAs<T>` takes a plain value or a Fusion state. If you give it a state, the component follows the state:

```luau
local name = scope:Value("Ada")

scope:Text({
	Text = scope:Computed(function(use)
		return "Hello, " .. use(name)
	end),
})

name:set("Grace") -- the text changes
```

Controls that the user changes, such as `Slider` and `Checkbox`, work both ways. A plain value sets only the starting value. A `Value` stays in step with the control. See [Common properties](../Guides/CommonProperties.md).

## Putting it on screen

A component returns an ordinary instance. Put it in a `ScreenGui`:

```luau
local gui = scope:New("ScreenGui")({
	Name = "App",
	ResetOnSpawn = false,
	Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	[Fusion.Children] = {
		scope:Window({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(480, 320),
			AppBar = scope:AppBar({ Title = "My app" }),
			Children = { save },
		}),
	},
})
```

## Cleaning up

Cleaning up the scope destroys everything in it:

```luau
Fusion.doCleanup(scope)
```

To rebuild an interface, for example when the theme changes, make a new inner scope for each build and clean up the old one. [Persisting state](../Guides/PersistingState.md) shows how to keep what the user entered.
