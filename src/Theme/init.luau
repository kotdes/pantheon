--!strict
local Packages = script.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Types)
local Accessibility = require(script.Parent.Internal.Accessibility)
local Color = require(script.Parent.Internal.Color)
local Flags = require(script.Parent.Internal.Flags)
local Blueprints = require(script.Blueprints)

local peek = Fusion.peek

local themeContext = Fusion.Contextual(nil :: Types.ThemeRef?)
--[[
	Fusion Contextual only applies during the Provide call stack. Computed /
	Observer callbacks re-run later and lose context, keep a root fallback.
]]
local rootTheme: Types.ThemeRef? = nil

local MontserratMedium =
	Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium)
local MontserratBold = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold)
local MontserratSemi =
	Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
local Mono = Font.new("rbxasset://fonts/families/RobotoMono.json")

local function lightColors(): Types.ThemeColors
	return {
		Primary = Color3.fromRGB(0, 105, 92),
		OnPrimary = Color3.fromRGB(255, 255, 255),
		PrimaryContainer = Color3.fromRGB(178, 223, 219),
		OnPrimaryContainer = Color3.fromRGB(0, 40, 35),
		Background = Color3.fromRGB(244, 246, 250),
		Surface = Color3.fromRGB(255, 255, 255),
		SurfaceDim = Color3.fromRGB(232, 235, 241),
		SurfaceBright = Color3.fromRGB(255, 255, 255),
		OnSurface = Color3.fromRGB(28, 27, 31),
		OnSurfaceVariant = Color3.fromRGB(68, 71, 79),
		SurfaceContainer = Color3.fromRGB(238, 241, 246),
		SurfaceContainerHigh = Color3.fromRGB(226, 230, 237),
		Outline = Color3.fromRGB(196, 199, 207),
		OutlineVariant = Color3.fromRGB(218, 221, 228),
		Error = Color3.fromRGB(211, 47, 47),
		OnError = Color3.fromRGB(255, 255, 255),
		Success = Color3.fromRGB(46, 125, 50),
		OnSuccess = Color3.fromRGB(255, 255, 255),
		Warning = Color3.fromRGB(237, 108, 2),
		OnWarning = Color3.fromRGB(33, 25, 0),
		Scrim = Color3.fromRGB(16, 20, 24),
		-- Contrasting roles for toasts / tips: dark on a light theme, light on a dark one.
		InverseSurface = Color3.fromRGB(38, 45, 54),
		InverseOnSurface = Color3.fromRGB(240, 243, 247),
		InversePrimary = Color3.fromRGB(77, 182, 172),
		Info = Color3.fromRGB(1, 115, 180),
		OnInfo = Color3.fromRGB(255, 255, 255),
		Sidebar = Color3.fromRGB(255, 255, 255),
		OnSidebar = Color3.fromRGB(28, 27, 31),
		SidebarSelected = Color3.fromRGB(238, 241, 246),
	}
end

local function darkColors(): Types.ThemeColors
	return {
		Primary = Color3.fromRGB(77, 182, 172),
		OnPrimary = Color3.fromRGB(0, 55, 49),
		PrimaryContainer = Color3.fromRGB(0, 77, 68),
		OnPrimaryContainer = Color3.fromRGB(178, 223, 219),
		Background = Color3.fromRGB(16, 20, 24),
		Surface = Color3.fromRGB(26, 31, 38),
		SurfaceDim = Color3.fromRGB(16, 20, 24),
		SurfaceBright = Color3.fromRGB(40, 48, 58),
		OnSurface = Color3.fromRGB(230, 232, 236),
		OnSurfaceVariant = Color3.fromRGB(184, 190, 200),
		SurfaceContainer = Color3.fromRGB(35, 42, 51),
		SurfaceContainerHigh = Color3.fromRGB(45, 54, 65),
		Outline = Color3.fromRGB(52, 61, 72),
		OutlineVariant = Color3.fromRGB(42, 50, 60),
		Error = Color3.fromRGB(239, 83, 80),
		OnError = Color3.fromRGB(26, 31, 38),
		Success = Color3.fromRGB(102, 187, 106),
		OnSuccess = Color3.fromRGB(26, 31, 38),
		Warning = Color3.fromRGB(255, 183, 77),
		OnWarning = Color3.fromRGB(26, 31, 38),
		Scrim = Color3.fromRGB(0, 0, 0),
		InverseSurface = Color3.fromRGB(226, 230, 237),
		InverseOnSurface = Color3.fromRGB(28, 27, 31),
		InversePrimary = Color3.fromRGB(0, 105, 92),
		Info = Color3.fromRGB(79, 195, 247),
		OnInfo = Color3.fromRGB(26, 31, 38),
		Sidebar = Color3.fromRGB(26, 31, 38),
		OnSidebar = Color3.fromRGB(230, 232, 236),
		SidebarSelected = Color3.fromRGB(35, 42, 51),
	}
end

--[[
	Default semantic palette (primary/secondary/…).
	Full Material hue/shade system: Internal.MaterialColors / Color = "Blue 500".
]]
local function defaultPalette(colors: Types.ThemeColors, mode: Types.ThemeMode): Types.ThemePalette
	local secondarySeed = if mode == "Dark"
		then Color3.fromRGB(156, 163, 175)
		else Color3.fromRGB(97, 97, 97)
	return {
		primary = {
			Base = colors.Primary,
			OnBase = colors.OnPrimary,
			Container = colors.PrimaryContainer,
			OnContainer = colors.OnPrimaryContainer,
		},
		secondary = Color.rolesFromSeed(secondarySeed, mode),
		surface = {
			Base = colors.SurfaceContainerHigh,
			OnBase = colors.OnSurface,
			Container = colors.SurfaceContainer,
			OnContainer = colors.OnSurfaceVariant,
		},
		error = {
			Base = colors.Error,
			OnBase = colors.OnError,
			Container = Color.lerp(colors.Error, colors.Surface, 0.78),
			OnContainer = colors.Error,
		},
		success = {
			Base = colors.Success,
			OnBase = colors.OnSuccess,
			Container = Color.lerp(colors.Success, colors.Surface, 0.78),
			OnContainer = colors.Success,
		},
		warning = {
			Base = colors.Warning,
			OnBase = colors.OnWarning,
			Container = Color.lerp(colors.Warning, colors.Surface, 0.78),
			OnContainer = colors.Warning,
		},
		info = {
			Base = colors.Info,
			OnBase = colors.OnInfo,
			Container = Color.lerp(colors.Info, colors.Surface, 0.78),
			OnContainer = colors.Info,
		},
	}
end

local defaultMetrics: Types.ThemeMetrics = {
	Space2xs = 4,
	SpaceXs = 8,
	SpaceSm = 12,
	SpaceMd = 16,
	SpaceLg = 24,
	SpaceXl = 32,
	RadiusNone = 0,
	Radius2xs = 2,
	RadiusXs = 4,
	RadiusSm = 8,
	RadiusMd = 12,
	RadiusLg = 16,
	RadiusXl = 20,
	Radius2xl = 24,
	Radius3xl = 32,
	RadiusPanel = 12,
	RadiusPill = 999,
	AppBarHeight = 64,
	DrawerWidth = 280,
	SidebarInset = 4,
	SidebarItemRadius = 8,
	RailWidth = 72,
	ButtonPadX = 20,
	ButtonPadY = 4,
	ControlHeight = 40,
	ControlHeightCompact = 28,
	ControlHeightLarge = 48,
	FieldLabelHeight = 20,
	IconSm = 16,
	IconMd = 18,
	IconLg = 20,
	IconXl = 24,
}

local function typography(): Types.ThemeTypography
	return {
		Display = { Font = MontserratBold, Size = 32, LineHeight = 1.2 },
		Headline = { Font = MontserratBold, Size = 24, LineHeight = 1.25 },
		Title = { Font = MontserratSemi, Size = 18, LineHeight = 1.3 },
		Button = { Font = MontserratSemi, Size = 16, LineHeight = 1.4 },
		BoldBody = { Font = MontserratBold, Size = 16, LineHeight = 1.4 },
		Body = { Font = MontserratMedium, Size = 16, LineHeight = 1.4 },
		Label = { Font = MontserratSemi, Size = 14, LineHeight = 1.3 },
		Caption = { Font = MontserratSemi, Size = 12, LineHeight = 1.3 },
		Mono = { Font = Mono, Size = 13, LineHeight = 1.35 },
	}
end

--- A theme that sets `Surface`, `OnSurface` or `SurfaceContainer` but not the sidebar roles gets a
--- sidebar that follows them, so only a theme that wants a different sidebar needs to name it.
local function followSurface(colors: Types.ThemeColors, given: { [string]: any }?)
	local set = given or {}
	if set.Sidebar == nil then
		colors.Sidebar = colors.Surface
	end
	if set.OnSidebar == nil then
		colors.OnSidebar = colors.OnSurface
	end
	if set.SidebarSelected == nil then
		colors.SidebarSelected = colors.SurfaceContainer
	end
end

local function lerpColor(a: Color3, b: Color3, t: number): Color3
	return Color.lerp(a, b, t)
end

local function blendThemes(a: Types.Theme, b: Types.Theme, t: number): Types.Theme
	t = math.clamp(t, 0, 1)
	if t <= 0 then
		return a
	end
	if t >= 1 then
		return b
	end
	local colors: any = {}
	for key, value in a.Colors :: any do
		if typeof(value) == "Color3" then
			colors[key] = lerpColor(value, (b.Colors :: any)[key], t)
		else
			colors[key] = value
		end
	end
	local palette: any = {}
	local aPal: Types.ThemePalette = a.Palette or {}
	local bPal: Types.ThemePalette = b.Palette or {}
	local keys: { [string]: boolean } = {}
	for k in aPal do
		keys[k] = true
	end
	for k in bPal do
		keys[k] = true
	end
	for k in keys do
		local ar = aPal[k]
		local br = bPal[k]
		if ar and br then
			palette[k] = {
				Base = lerpColor(ar.Base, br.Base, t),
				OnBase = lerpColor(ar.OnBase, br.OnBase, t),
				Container = lerpColor(ar.Container, br.Container, t),
				OnContainer = lerpColor(ar.OnContainer, br.OnContainer, t),
			}
		else
			palette[k] = br or ar
		end
	end
	local out = table.clone(b)
	out.Colors = colors
	out.Palette = palette
	out.Mode = if t < 0.5 then a.Mode else b.Mode
	return out
end

local Theme = {}

export type ThemeCreateOpts = {
	--- When false, skip system accessibility prefs (unless `Accessibility` is set).
	RespectAccessibility: boolean?,
	--- Explicit prefs override (storybooks / tests). Takes priority over system read.
	Accessibility: Types.AccessibilityPrefs?,
	Controls: Types.ThemeControls?,
	--- A preset for the theme. `Blueprints.Materia` when you do not name one.
	Blueprint: Types.Blueprint?,
	Overrides: { [string]: any }?,
	--- Extra / override named colors (seed Color3, hex, or full ThemeColorRole)
	Palette: { [string]: Color3 | Types.ThemeColorRole | Types.ColorInput }?,
	--- Merge custom typography scales (keeps required defaults)
	Typography: { [string]: Types.TypeScale }?,
}

local function deepMerge(base: any, over: any): any
	if typeof(over) ~= "table" then
		return over
	end
	if typeof(base) ~= "table" then
		return table.clone(over)
	end
	local out = table.clone(base)
	for key, value in over do
		local existing = out[key]
		local mtValue: any = getmetatable(value)
		local mtExisting: any = getmetatable(existing)
		if
			typeof(value) == "table"
			and typeof(existing) == "table"
			and mtValue == nil
			and mtExisting == nil
		then
			local isArray = #value > 0 or #existing > 0
			if isArray then
				out[key] = table.clone(value)
			else
				out[key] = deepMerge(existing, value)
			end
		else
			out[key] = value
		end
	end
	return out
end

function Theme.create(mode: Types.ThemeMode?, opts: ThemeCreateOpts?): Types.Theme
	local resolved: Types.ThemeMode = mode or "Light"
	local switchIcons = true
	if opts ~= nil and opts.Controls ~= nil and opts.Controls.SwitchIcons ~= nil then
		switchIcons = opts.Controls.SwitchIcons
	end
	local colors = if resolved == "Dark" then darkColors() else lightColors()
	local theme: Types.Theme = {
		Mode = resolved,
		Colors = colors,
		Palette = defaultPalette(colors, resolved),
		Fonts = {
			Heading = MontserratBold,
			Body = MontserratMedium,
			Mono = Mono,
		},
		Typography = typography(),
		Metrics = table.clone(defaultMetrics),
		Icons = {},
		Audio = {
			open = "",
			success = "",
			error = "",
			confirm = "",
		},
		Motion = {
			SpringSpeed = 640,
			SpringDamping = 20,
			PressScale = 1,
			Springs = {
				Snappy = { Speed = 640, Damping = 20 },
				Smooth = { Speed = 640, Damping = 20 },
				Soft = { Speed = 640, Damping = 20 },
				Bouncy = { Speed = 640, Damping = 20 },
				Gentle = { Speed = 640, Damping = 20 },
				LiquidMove = { Speed = 640, Damping = 20 },
				LiquidWidth = { Speed = 640, Damping = 20 },
				LiquidHeight = { Speed = 640, Damping = 20 },
				LiquidShape = { Speed = 640, Damping = 20 },
			},
			Stagger = 0,
			Presence = { ScaleFrom = 0.92, FromOrigin = false },
		},
		Controls = {
			SwitchIcons = switchIcons,
		},
	}
	local blueprint = Blueprints.resolve((opts and opts.Blueprint) or Blueprints.Materia)
	theme.Defaults = blueprint.Defaults or {}
	if blueprint.Metrics then
		theme.Metrics = deepMerge(theme.Metrics, blueprint.Metrics)
	end
	if blueprint.Typography then
		theme.Typography = deepMerge(theme.Typography, blueprint.Typography)
	end
	if blueprint.Motion then
		theme.Motion = deepMerge(theme.Motion, blueprint.Motion)
	end
	local modeColors = if resolved == "Dark" then blueprint.DarkColors else blueprint.LightColors
	local recoloured = false
	for _, tweaks in { blueprint.Colors, modeColors } do
		if tweaks then
			theme.Colors = deepMerge(theme.Colors, tweaks)
			followSurface(theme.Colors, tweaks)
			recoloured = true
		end
	end
	if recoloured then
		-- The named colours (primary, secondary, ...) come from the theme colours.
		theme.Palette = defaultPalette(theme.Colors, resolved)
	end
	if opts and opts.Overrides then
		theme = deepMerge(theme, opts.Overrides) :: Types.Theme
		theme.Mode = resolved
		followSurface(theme.Colors, opts.Overrides.Colors)
	end
	if opts and opts.Palette then
		theme.Palette = Color.normalizePalette(opts.Palette, resolved, theme.Palette)
	end
	if opts and opts.Typography then
		theme.Typography = deepMerge(theme.Typography, opts.Typography) :: Types.ThemeTypography
	end
	if opts and opts.Controls then
		theme.Controls = deepMerge(theme.Controls or {}, opts.Controls)
	end
	if opts and opts.Accessibility ~= nil then
		theme = Accessibility.apply(theme, opts.Accessibility :: any)
	elseif opts == nil or opts.RespectAccessibility ~= false then
		theme = Accessibility.apply(theme)
	end
	return theme
end

--[[
	Animated theme ref: springs between Light/Dark when mode changes.
	Pass Animate = false for instant swap.
]]
function Theme.createAnimated(
	scope: Types.Scope,
	mode: any,
	opts: {
		Animate: boolean?,
		Blueprint: Types.Blueprint?,
		RespectAccessibility: boolean?,
		Accessibility: Types.AccessibilityPrefs?,
		Controls: Types.ThemeControls?,
		Overrides: { [string]: any }?,
		Palette: { [string]: Color3 | Types.ThemeColorRole | Types.ColorInput }?,
		Typography: { [string]: Types.TypeScale }?,
	}?
): Types.ThemeRef
	local animate = if opts and opts.Animate == false then false else true
	local respect = if opts and opts.RespectAccessibility == false then false else true
	local createOpts: ThemeCreateOpts = {
		RespectAccessibility = respect,
		Blueprint = if opts then opts.Blueprint else nil,
		Accessibility = if opts then opts.Accessibility else nil,
		Controls = if opts then opts.Controls else nil,
		Overrides = if opts then opts.Overrides else nil,
		Palette = if opts then opts.Palette else nil,
		Typography = if opts then opts.Typography else nil,
	}
	local light = Theme.create("Light", createOpts)
	local dark = Theme.create("Dark", createOpts)

	local goal = scope:Computed(function(use)
		local m = if typeof(mode) == "table" then use(mode) else mode
		return if m == "Dark" then 1 else 0
	end)

	if not animate or (light.Accessibility and light.Accessibility.ReduceMotion) then
		return scope:Computed(function(use)
			return if use(goal) > 0.5 then dark else light
		end)
	end

	local blend = scope:Spring(goal, light.Motion.SpringSpeed * 0.05, 1)
	return scope:Computed(function(use)
		return blendThemes(light, dark, use(blend))
	end)
end

function Theme.Provide<T...>(theme: Types.ThemeRef, callback: (T...) -> ...any, ...: T...): ...any
	rootTheme = theme
	return themeContext:is(theme):during(callback, ...)
end

--- Like `Provide`, but it does not become the fallback for UI built later outside any `Provide`.
--- Use it for a part of the UI that has its own theme, such as a dark HUD.
function Theme.Scoped<T...>(theme: Types.ThemeRef, callback: (T...) -> ...any, ...: T...): ...any
	return themeContext:is(theme):during(callback, ...)
end

function Theme.use(): Types.Theme
	local ref = themeContext:now() or rootTheme
	assert(ref ~= nil, "Pantheon.Theme.Provide required, wrap your UI root in Theme.Provide")
	return peek(ref) :: Types.Theme
end

function Theme.useRef(): Types.ThemeRef
	local ref = themeContext:now() or rootTheme
	assert(ref ~= nil, "Pantheon.Theme.Provide required")
	return ref :: Types.ThemeRef
end

-- Views of a theme state, one for each state, so a role is turned into a Computed only once.
local reactiveViews: { [any]: Types.Theme } = setmetatable({}, { __mode = "k" }) :: any
local viewScope = Fusion.scoped(Fusion)

local function isState(value: any): boolean
	return typeof(value) == "table" and (value :: any).type == "State"
end

--- A theme whose `Colors` are states: `view.Colors.Surface` is a Computed of the colour in the
--- current theme of `ref`. Everything else reads the current theme when it is asked for. A
--- property can take a colour state as it is; maths on a colour needs `use`.
function Theme.reactive(ref: Types.ThemeRef): Types.Theme
	if not isState(ref) then
		return peek(ref) :: Types.Theme
	end
	local cached = reactiveViews[ref]
	if cached then
		return cached
	end
	local colors = setmetatable({}, {
		__index = function(self: any, key: string)
			local state = viewScope:Computed(function(use)
				return ((use(ref :: any) :: any).Colors :: any)[key]
			end)
			rawset(self, key, state)
			return state
		end,
	})
	-- Roles (Button's "primary", "secondary", ...) are built from the palette, so each of their
	-- four colours follows the theme as well.
	local palette: { [string]: any } = {}
	local current = (peek(ref :: any) :: any).Palette
	if current then
		for roleName in current do
			local role: { [string]: any } = {}
			for _, field in { "Base", "OnBase", "Container", "OnContainer" } do
				role[field] = viewScope:Computed(function(use)
					local source = (use(ref :: any) :: any).Palette
					local entry = if source then source[roleName] else nil
					return if entry then entry[field] else nil
				end)
			end
			palette[roleName] = role
		end
	end
	local view = setmetatable({ Colors = colors, Palette = palette }, {
		__index = function(_, key: string)
			return ((peek(ref) :: any) :: { [string]: any })[key]
		end,
	}) :: any
	reactiveViews[ref] = view
	return view
end

function Theme.resolve(props: { Theme: Types.ThemeRef? }?): Types.Theme
	local given = if props then props.Theme else nil
	if Flags.ReactiveTheme then
		local ref = given or themeContext:now() or rootTheme
		if ref ~= nil and isState(ref) then
			return Theme.reactive(ref)
		end
	end
	if given ~= nil then
		return peek(given) :: Types.Theme
	end
	return Theme.use()
end

Theme.Contextual = themeContext
Theme.Accessibility = Accessibility
Theme.Color = Color
Theme.Material = Color.Material
Theme.blend = blendThemes
Theme.deepMerge = deepMerge
Theme.Blueprints = Blueprints

return Theme
