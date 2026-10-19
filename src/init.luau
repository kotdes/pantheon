--!strict
--[[
	koterahq/pantheon: Cadence/Tithe design system for Fusion + Iona.
	Vuetify-scale component kit.
]]

local Packages = script.Parent
local Fusion = require(Packages.Fusion)
local Iona = require(Packages.Iona)

local Theme = require(script.Theme)
local Directives = require(script.Internal.Directives)
local RawComponents = require(script.Components)
local Types = require(script.Types)
local Layer = require(script.Internal.Layer)

require(script.Internal.FusionPerf).apply()


local Components: { [string]: any } = {}
for name, component in RawComponents :: any do
	Components[name] = if typeof(component) == "function"
		then Directives.wrap(component)
		else component
end
table.freeze(Components)

export type Theme = Types.Theme
export type ThemeMode = Types.ThemeMode
export type Scope = Types.Scope
export type ButtonProps = Types.ButtonProps
export type TextFieldProps = Types.TextFieldProps
export type ListItemProps = Types.ListItemProps
export type ButtonVariant = Types.ButtonVariant
export type ColorInput = Types.ColorInput
export type ThemeColorRole = Types.ThemeColorRole
export type ThemePalette = Types.ThemePalette

local Pantheon = {
	Theme = Theme,
	Components = Components,
	Directives = Directives,

	Game = require(script.Game),
	Types = Types,
	Layer = Layer,
	Flags = require(script.Internal.Flags),
	--- Inspect overlay + properties panel; needs Flags.DevTools (see DevTools/init).
	DevTools = require(script.DevTools),
	CanvasFade = require(script.Internal.CanvasFade),
	Validators = require(script.Internal.Validators),
	Accessibility = require(script.Internal.Accessibility),
	Shadow = require(script.Internal.Shadow),
	--- Fade a whole subtree by driving every descendant's transparency (no CanvasGroup).
	GroupFade = require(script.Internal.GroupFade),
	--- Opt-in state persistence across rebuilds (see Internal/Persist).
	Persist = require(script.Internal.Persist),
	--- Keyboard and gamepad focus (see Internal/Focus).
	Focus = require(script.Internal.Focus),
	Style = require(script.Style),
	Color = require(script.Internal.Color),
	Material = require(script.Internal.MaterialColors),
	Fusion = Fusion,
	Iona = Iona,
	Version = { major = 0, minor = 1, isRelease = false },
}

-- Fusion's Hydrate is slated for deprecation. Pantheon scopes expose its own
-- `Apply` (and keep `Hydrate` as an alias so Iona / older code keeps working)
-- without touching Fusion's implementation.
local Apply = require(script.Internal.Apply)
local FusionMethods = table.clone(Fusion :: any)
FusionMethods.Hydrate = Apply
FusionMethods.Apply = Apply
table.freeze(FusionMethods)

Pantheon.Apply = Apply

-- Components are `(scope, props) -> Instance`, so they work as scope methods as they are:
-- `scope:Button({ ... })` is `Components.Button(scope, { ... })`. Scope methods share one
-- namespace with Fusion's and Iona's, so a clash is an error here, not a silent override.
local ComponentMethods = table.clone(Components :: any)
for name in ComponentMethods do
	if (FusionMethods :: any)[name] ~= nil or (Iona :: any)[name] ~= nil then
		error(`[Pantheon] component "{name}" clashes with a Fusion or Iona scope method`, 0)
	end
end
table.freeze(ComponentMethods)

function Pantheon.scoped(): Types.Scope
	return Fusion.scoped(FusionMethods, Iona, ComponentMethods) :: any
end

return Pantheon
