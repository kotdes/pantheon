---
description: How to add Pantheon to a Roblox project with Wally.
---

# Installing Pantheon

Pantheon is on Wally. Add it to your `wally.toml` and run `wally install`:

```toml
[dependencies]
Pantheon = "koterahq/pantheon@0.1.0"
```

Wally installs the libraries Pantheon needs too. To run the demo, or to work on Pantheon itself, install it from the repository as below.

## What you need

Pantheon needs these libraries. Wally installs them.

| Library | Version | Used for |
| ------- | ------- | -------- |
| [Fusion](https://elttob.uk/Fusion/0.3/) | 0.3.0 | State and instances |
| Iona (`koterahq/iona`) | 0.3.0 | Short forms for properties such as `CornerRadius` and `Layout` |
| [Lucide icons](https://github.com/latte-soft/lucide-icons) | 0.1.3 | The icons of `Icon`, `IconButton` and others |
| [Snapdragon](https://github.com/vorlias/snapdragon) | 2.0.0 | Dragging |

## Steps

Clone the repository. In it, run:

```bash
rokit install
wally install
rojo serve demo.project.json
```

`rokit install` installs Rojo, Wally, StyLua and Selene at the versions in `rokit.toml`. `wally install` fills the `Packages` folder. `rojo serve` syncs the project with Studio.

Open `demo.rbxlx` in Studio and connect the Rojo plugin. Press Play to run the storyboard. It shows every component in light and dark mode.

## Using it in your own project

Add the `src` folder to your Rojo project as `Pantheon`, next to the packages it needs:

```json
{
	"name": "my-game",
	"tree": {
		"$className": "DataModel",
		"ReplicatedStorage": {
			"Packages": {
				"$path": "Packages",
				"Pantheon": { "$path": "../pantheon/src" }
			}
		}
	}
}
```

Then require it in a client script:

```luau
local Pantheon = require(ReplicatedStorage.Packages.Pantheon)
```

Next, [build an interface](UsingPantheon.md).
