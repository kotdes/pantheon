--!strict
local Types = require(script.Parent.Parent.Types)

--[[
	A blueprint is a preset for a theme: metrics, type, colours and the default props of
	components. See rfcs/0003-blueprints.md.
]]
local Blueprints = {}

--- The Material-based look. It is the blueprint for a theme that does not name one.
Blueprints.Materia = {
	Name = "Materia",
	Defaults = {
		TextField = { Variant = "Outlined" },
		IconButton = { AspectRatio = 1 },
	},
} :: Types.Blueprint

local MONTSERRAT = "rbxasset://fonts/families/Montserrat.json"

--- The soft look: large rounded shapes, tonal layers and no outlines at rest, heavy type, and
--- springy motion. It starts from `Materia` and changes what differs. Its springs have not been
--- tuned in Studio yet.
Blueprints.Pantheon = {
	Name = "Pantheon",
	Extends = Blueprints.Materia,
	Metrics = {
		Radius2xs = 4,
		RadiusXs = 8,
		RadiusSm = 12,
		RadiusMd = 16,
		RadiusLg = 20,
		RadiusXl = 28,
		Radius2xl = 32,
		Radius3xl = 40,
		RadiusPanel = 24,
		ControlHeight = 48,
		ControlHeightCompact = 36,
		ControlHeightLarge = 56,
		ButtonPadX = 32,
		ButtonPadY = 12,
		SidebarInset = 8,
		-- Rows follow the round corners of the sidebar.
		SidebarItemRadius = 20,
	},
	Typography = {
		Display = { Font = Font.new(MONTSERRAT, Enum.FontWeight.Bold), Size = 40, LineHeight = 1.1 },
		Headline = {
			Font = Font.new(MONTSERRAT, Enum.FontWeight.Bold),
			Size = 28,
			LineHeight = 1.15,
		},
		Title = { Font = Font.new(MONTSERRAT, Enum.FontWeight.Bold), Size = 20, LineHeight = 1.25 },
		Button = { Font = Font.new(MONTSERRAT, Enum.FontWeight.Bold), Size = 16, LineHeight = 1.4 },
		-- Big numbers and headlines, such as an amount or a balance.
		Hero = { Font = Font.new(MONTSERRAT, Enum.FontWeight.Bold), Size = 56, LineHeight = 1.05 },
	},
	-- Neutral greys, and an ink that is close to black (white in the dark theme) for primary
	-- controls. Strokes are for focus and error only, so surfaces are told apart by tone.
	LightColors = {
		Primary = Color3.fromRGB(17, 17, 20),
		OnPrimary = Color3.fromRGB(255, 255, 255),
		PrimaryContainer = Color3.fromRGB(232, 232, 237),
		OnPrimaryContainer = Color3.fromRGB(17, 17, 20),
		Background = Color3.fromRGB(242, 242, 247),
		Surface = Color3.fromRGB(255, 255, 255),
		SurfaceDim = Color3.fromRGB(235, 235, 240),
		SurfaceContainer = Color3.fromRGB(242, 242, 247),
		SurfaceContainerHigh = Color3.fromRGB(232, 232, 237),
		OnSurface = Color3.fromRGB(17, 17, 20),
		OnSurfaceVariant = Color3.fromRGB(122, 122, 130),
		Outline = Color3.fromRGB(209, 209, 214),
		OutlineVariant = Color3.fromRGB(229, 229, 234),
	},
	DarkColors = {
		Primary = Color3.fromRGB(255, 255, 255),
		OnPrimary = Color3.fromRGB(0, 0, 0),
		PrimaryContainer = Color3.fromRGB(58, 58, 60),
		OnPrimaryContainer = Color3.fromRGB(255, 255, 255),
		Background = Color3.fromRGB(0, 0, 0),
		Surface = Color3.fromRGB(28, 28, 30),
		SurfaceDim = Color3.fromRGB(0, 0, 0),
		SurfaceBright = Color3.fromRGB(44, 44, 46),
		SurfaceContainer = Color3.fromRGB(44, 44, 46),
		SurfaceContainerHigh = Color3.fromRGB(58, 58, 60),
		OnSurface = Color3.fromRGB(245, 245, 247),
		OnSurfaceVariant = Color3.fromRGB(152, 152, 159),
		Outline = Color3.fromRGB(72, 72, 74),
		OutlineVariant = Color3.fromRGB(44, 44, 46),
	},
	Motion = {
		Springs = {
			Snappy = { Speed = 50, Damping = 0.85 },
			Smooth = { Speed = 30, Damping = 1 },
			Soft = { Speed = 22, Damping = 0.9 },
			Bouncy = { Speed = 30, Damping = 0.85 },
			-- Slow, for things that explain: a coachmark moving between targets.
			Gentle = { Speed = 20, Damping = 0.9 },
			-- A shape that flows from one place to another. Each part of it has its own spring:
			-- the width leads and wobbles, the height follows more slowly and stretches, and the
			-- position takes a curved path because the two axes move at different speeds.
			LiquidMove = { Speed = 26, Damping = 0.8 },
			LiquidWidth = { Speed = 34, Damping = 0.62 },
			LiquidHeight = { Speed = 21, Damping = 0.7 },
			LiquidShape = { Speed = 28, Damping = 1 },
		},
		Stagger = 30,
		Presence = { ScaleFrom = 0.78, FromOrigin = true },
	},
	Defaults = {
		-- Nothing is outlined at rest.
		All = { Outlined = false },
		-- A multi-line field has the radius of a card, so it matches the lists around it.
		TextField = { Variant = "Filled", Pill = true, MultilineRadius = "RadiusMd" },
		ListItem = { Flat = true },
		Tooltip = { Tail = true },
		-- The same space on every side of a sidebar. A 36 pixel row is a pill with a radius of 18, so
		-- a row at the bottom clears a corner of 24 (a sidebar that is flush with its window) with 6
		-- pixels, and one of 28 (an inset sidebar) with 10. 8 is the nearest step of the scale to both.
		NavigationDrawer = { Padding = 8 },
		Slider = { Thickness = 8, ThumbSize = 24 },
		RangeSlider = { Thickness = 8, ThumbSize = 24 },
		IconButton = { AspectRatio = 1.25 },
	},
} :: Types.Blueprint

--- Flattens `Extends`, so that the blueprint that is named wins over the one it starts from.
function Blueprints.resolve(blueprint: Types.Blueprint): Types.Blueprint
	local base = blueprint.Extends
	if base == nil then
		return blueprint
	end
	local parent = Blueprints.resolve(base)
	local defaults: Types.ThemeDefaults = {}
	for component, props in parent.Defaults or {} do
		defaults[component] = table.clone(props)
	end
	for component, props in blueprint.Defaults or {} do
		local merged = defaults[component] or {}
		for name, value in props do
			merged[name] = value
		end
		defaults[component] = merged
	end
	local function merge(a: { [string]: any }?, b: { [string]: any }?): { [string]: any }?
		if a == nil or b == nil then
			return b or a
		end
		local out = table.clone(a)
		for key, value in b do
			out[key] = value
		end
		return out
	end
	return {
		Name = blueprint.Name,
		Metrics = merge(parent.Metrics, blueprint.Metrics) :: any,
		Typography = merge(parent.Typography, blueprint.Typography) :: any,
		Colors = merge(parent.Colors, blueprint.Colors),
		LightColors = merge(parent.LightColors, blueprint.LightColors),
		DarkColors = merge(parent.DarkColors, blueprint.DarkColors),
		Motion = merge(parent.Motion, blueprint.Motion),
		Defaults = defaults,
	}
end

return Blueprints
