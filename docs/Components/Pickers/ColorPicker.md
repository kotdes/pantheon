---
tags:
  - Pickers
  - Components
---

# ColorPicker

ColorPicker chooses one colour. It has three tabs: swatches, a saturation and brightness square with a hue slider, and sliders for each channel of a colour model. [GradientPicker](./GradientPicker.md) uses it to edit the stops of a gradient.

## Usage

Call `Components.ColorPicker` with a scope and a table of properties:

```luau
local color = scope:Value(Color3.fromRGB(0, 105, 92))

scope:ColorPicker({
	Value = color, -- (1)!
	OnChange = function(newColor, alpha)
		print(newColor, alpha)
	end,
})
```

1.  `Value` is a `Color3` or a `Value<Color3>`. A `Value` and the picker follow each other: setting the state moves the picker, and moving the picker sets the state.

## Tabs

- **Grid** shows swatches. `Palette` replaces them.
- **Spectrum** is a saturation and brightness square with a hue slider. With `Area = "Wheel"` it is a hue ring around the square instead. The ring needs conical gradients and falls back to the square without them.
- **Sliders** has one slider for each channel of a model: `"RGB"`, `"HSB"` (also `"HSV"`), `"HSL"`, `"LAB"` or `"Hex"`. The models show as chips under the tabs.

## Sliders and thumbs

Each slider is filled with the gradient of its channel and has a number field. The thumb is small at rest and grows to the height of the track while it is pressed. The handles on the square and the ring behave the same way.

## Alpha

There is an alpha slider over a checkerboard on every tab. Set `ShowAlpha = false` to remove it.

## Properties

| Name | Type | Required | Default | Description |
| ---- | ---- | -------- | ------- | ----------- |
| `Theme` | `ThemeRef` | :x: | The contextual theme | Theme to use for this component instead of the one from `Theme.Provide`. |
| `LayoutOrder` | `UsedAs<number>` | :x: | `0` | Position in a parent `UIListLayout` or `UIGridLayout`. |
| `Size` | `UsedAs<UDim2>` | :x: | - | Size of the component. |
| `Value` | `UsedAs<Color3>` | :x: | `Color3.fromRGB(0, 105, 92)` | The colour, as a `Color3` or a `Value<Color3>`. A `Value` is followed, and is set when the user changes the colour. |
| `Alpha` | `UsedAs<number>` | :x: | `1` | Opacity from `0` to `1`. A `Value` is followed, and is set when the user changes it. |
| `ShowAlpha` | `boolean` | :x: | `true` | Show the alpha slider. |
| `Modes` | `{ string }` | :x: | `{ "Grid", "Spectrum", "Sliders" }` | The tabs, in order, from `"Grid"`, `"Spectrum"` and `"Sliders"`. |
| `Mode` | `string` | :x: | The first mode | Tab to show first. |
| `Models` | `{ string }` | :x: | `{ "RGB", "HSB", "HSL", "LAB", "Hex" }` | The colour models offered on the Sliders tab, from `"RGB"`, `"HSB"`, `"HSV"`, `"HSL"`, `"LAB"` and `"Hex"`. |
| `Model` | `string` | :x: | The first model | Model to show first. |
| `Area` | `"Square" \| "Wheel"` | :x: | `"Square"` | `"Square"` or `"Wheel"` for the Spectrum tab. |
| `Palette` | `{ Color3 }` | :x: | A grey ramp and a grid of hues | Swatches for the Grid tab. |
| `Footer` | `boolean` | :x: | `true` | Show the swatch, hex field and alpha readout at the bottom. |
| `Background` | `Color3` | :x: | `Colors.Surface` | Fill colour of the picker. |
| `Id` | `string` | :x: | - | Key that identifies this component when state is kept across rebuilds. See [Persist](../../Guides/PersistingState.md). |

## Callbacks

| Name | Description |
| ---- | ----------- |
| `OnChanged: (Color3) -> ()` | Runs with the colour when it changes. |
| `OnAlphaChanged: (number) -> ()` | Runs with the alpha when it changes. |
| `OnChange: (Color3, number) -> ()` | Runs with the colour and the alpha when either changes. |

## See also

- [GradientPicker](./GradientPicker.md)
