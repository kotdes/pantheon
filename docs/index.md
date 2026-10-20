---
hide:
  - navigation
  - toc
  - title
---

<div class="es-hero" markdown>

<img src="assets/branding/pantheon-logo.svg" alt="Pantheon wordmark" class="es-hero-logo">

</div>

Pantheon is a set of user interface components for Roblox. It is built on [Fusion](https://elttob.uk/Fusion/0.3/) 0.3. It has about 70 components, a light and a dark theme, and a separate set for game HUDs.

[Get started](Tutorials/InstallingPantheon.md){ .md-button .md-button--primary }
[Using Pantheon](Tutorials/UsingPantheon.md){ .md-button }

!!! note

    Pantheon is still being built. It is not on Wally yet, and parts of it will change before version 1.

## Features

<div class="grid cards" markdown>

-   :material-format-color-fill:{ .lg .middle } __Theming__

    ---

    Components take their colours, fonts and spacing from a theme. Change the theme and every component changes with it. Light and dark themes are included.

    [:octicons-arrow-right-24: Theming](Guides/Theming.md)

-   :material-content-save-outline:{ .lg .middle } __State that survives a rebuild__

    ---

    Controls can keep what the user entered when you rebuild the interface. This means you can change the theme or the layout without losing anything.

    [:octicons-arrow-right-24: Persisting state](Guides/PersistingState.md)

-   :material-human-handsup:{ .lg .middle } __Accessibility__

    ---

    Components follow the player's settings for reduced motion, transparency and text size. Controls work with a keyboard or a gamepad.

    [:octicons-arrow-right-24: Accessibility](Guides/Accessibility.md)

-   :material-gamepad-variant-outline:{ .lg .middle } __Game components__

    ---

    A hotbar with an inventory panel, and a backpack that feeds it. They are styled for games and do not use the app theme.

    [:octicons-arrow-right-24: Hotbar](Game/Hotbar.md)

-   :material-bug-outline:{ .lg .middle } __DevTools__

    ---

    A panel for inspecting an interface while it runs. You can browse the element tree and change properties.

    [:octicons-arrow-right-24: DevTools](Modules/DevTools.md)

-   :material-library:{ .lg .middle } __Built with Fusion__

    ---

    You can give most properties a Fusion state. The component updates when the state changes. If you give a control a `Value`, the control and the `Value` stay in step both ways.

    [:octicons-arrow-right-24: Common properties](Guides/CommonProperties.md)

</div>

## A first look

```luau
local Pantheon = require(Packages.Pantheon)

local scope = Pantheon.scoped()
local theme = Pantheon.Theme.create("Light")

Pantheon.Theme.Provide(theme, function()
	scope:Button({
		Text = "Run",
		Variant = "Filled",
		OnClick = function()
			print("Running")
		end,
	})
end)
```

## Where to go next

- [Install Pantheon](Tutorials/InstallingPantheon.md) to add the library to a project.
- [Use Pantheon](Tutorials/UsingPantheon.md) to build a small interface.
- [Common properties](Guides/CommonProperties.md) lists what every component accepts.
- Find a component in the navigation. They are grouped by what they do.
