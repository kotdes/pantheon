--!strict
--[[
	Respect system accessibility prefs (Roblox GuiService / UserGameSettings).
]]
local GuiService = game:GetService("GuiService")
local UserSettings = UserSettings()
local UserGameSettings = UserSettings:GetService("UserGameSettings")

export type PreferredTextSizeName = "Medium" | "Large" | "Larger" | "Largest"

export type Prefs = {
	ReduceMotion: boolean,
	PreferredTransparency: number, -- 0 = opaque preferred, 1 = more transparent UI ok
	HighContrast: boolean?,
	PreferredTextSize: PreferredTextSizeName?,
}

local TEXT_SCALE: { [string]: number } = {
	Medium = 1,
	Large = 1.15,
	Larger = 1.3,
	Largest = 1.5,
}

local Accessibility = {}

local function readPreferredTextSize(): PreferredTextSizeName?
	local ok, value = pcall(function()
		return (GuiService :: any).PreferredTextSize
	end)
	if not ok or value == nil then
		return nil
	end
	if typeof(value) == "EnumItem" then
		local name = value.Name
		if TEXT_SCALE[name] then
			return name :: PreferredTextSizeName
		end
	elseif typeof(value) == "string" and TEXT_SCALE[value] then
		return value :: PreferredTextSizeName
	end
	return nil
end

function Accessibility.read(): Prefs
	local reduceMotion = false
	pcall(function()
		reduceMotion = (UserGameSettings :: any).ReducedMotion == true
	end)
	local preferredTransparency = 0
	pcall(function()
		preferredTransparency = GuiService.PreferredTransparency or 0
	end)
	return {
		ReduceMotion = reduceMotion,
		PreferredTransparency = preferredTransparency,
		PreferredTextSize = readPreferredTextSize(),
	}
end

--[[
	Apply prefs onto a Theme table (returns a shallow-cloned theme).
	ReduceMotion → near-instant springs.
	PreferredTransparency → densify scrim when user prefers less transparency.
	HighContrast → push surfaces / ink toward extremes.
	PreferredTextSize → scale typography sizes.
]]
function Accessibility.apply(theme: any, prefs: Prefs?): any
	local resolved: Prefs = prefs or Accessibility.read()
	local out = table.clone(theme)
	out.Colors = table.clone(theme.Colors)
	out.Motion = table.clone(theme.Motion)
	if theme.Palette then
		out.Palette = table.clone(theme.Palette)
	end
	if theme.Controls then
		out.Controls = table.clone(theme.Controls)
	end
	out.Accessibility = resolved

	if resolved.ReduceMotion then
		-- Critically damped Fusion spring (ratio 1) + fast settle
		out.Motion.SpringSpeed = math.max(out.Motion.SpringSpeed, 400)
		out.Motion.SpringDamping = 1
		out.Motion.PressScale = 1
		-- The named springs and the stagger follow, so no role moves more than `SpringSpeed` does.
		local springs = {}
		for role in out.Motion.Springs or {} do
			springs[role] = { Speed = out.Motion.SpringSpeed, Damping = 1 }
		end
		out.Motion.Springs = springs
		out.Motion.Stagger = 0
		out.Motion.Presence = { ScaleFrom = 1, FromOrigin = false }
	end

	-- PreferredTransparency: higher = user wants more transparency allowed.
	-- We *reduce* scrim when they want less see-through chrome (low value).
	local t = math.clamp(resolved.PreferredTransparency, 0, 1)
	if t < 0.5 then
		local densify = (0.5 - t) * 2
		local scrim = out.Colors.Scrim :: Color3
		out.Colors.Scrim = Color3.new(
			scrim.R * (1 - densify * 0.35),
			scrim.G * (1 - densify * 0.35),
			scrim.B * (1 - densify * 0.35)
		)
	end

	if resolved.HighContrast == true then
		local colors = theme.Colors
		local followsSurface = colors.Sidebar == colors.Surface
		local followsInk = colors.OnSidebar == colors.OnSurface
		if out.Mode == "Dark" then
			out.Colors.Background = Color3.new(0, 0, 0)
			out.Colors.Surface = Color3.fromRGB(12, 12, 14)
			out.Colors.OnSurface = Color3.new(1, 1, 1)
			out.Colors.OnSurfaceVariant = Color3.fromRGB(230, 230, 235)
			out.Colors.Outline = Color3.fromRGB(200, 205, 215)
			out.Colors.OutlineVariant = Color3.fromRGB(140, 145, 155)
		else
			out.Colors.Background = Color3.new(1, 1, 1)
			out.Colors.Surface = Color3.new(1, 1, 1)
			out.Colors.OnSurface = Color3.new(0, 0, 0)
			out.Colors.OnSurfaceVariant = Color3.fromRGB(30, 30, 35)
			out.Colors.Outline = Color3.fromRGB(40, 40, 45)
			out.Colors.OutlineVariant = Color3.fromRGB(80, 80, 90)
		end
		-- A sidebar that follows the surface follows it here too. A sidebar of its own colour keeps
		-- that colour, and its ink goes to white or black, whichever reads better on it.
		if followsSurface then
			out.Colors.Sidebar = out.Colors.Surface
		end
		if followsInk then
			out.Colors.OnSidebar = out.Colors.OnSurface
		else
			local white, black = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
			local fill = out.Colors.Sidebar :: Color3
			out.Colors.OnSidebar = if Accessibility.contrast(white, fill)
					>= Accessibility.contrast(black, fill)
				then white
				else black
		end
	end

	local textSize = resolved.PreferredTextSize
	local scale = if textSize then TEXT_SCALE[textSize] else 1
	if scale ~= nil and scale ~= 1 and theme.Typography then
		local typography = table.clone(theme.Typography)
		for key, style in theme.Typography do
			typography[key] = {
				Font = style.Font,
				Size = math.round(style.Size * scale),
				LineHeight = style.LineHeight,
			}
		end
		out.Typography = typography
	end

	return out
end

--- The multiplier for text, from the text size the player prefers. 1 for the default size.
function Accessibility.textScale(theme: any): number
	local prefs = theme and theme.Accessibility
	local name = prefs and prefs.PreferredTextSize
	return (name and TEXT_SCALE[name]) or 1
end

--- `base` text size scaled by the text size the player prefers. Use it for sizes that do not come
--- from `theme.Typography`.
function Accessibility.size(theme: any, base: number): number
	return math.round(base * Accessibility.textScale(theme))
end

function Accessibility.motionSpeed(theme: any, multiplier: number?): number
	local m = multiplier or 1
	if theme.Accessibility and theme.Accessibility.ReduceMotion then
		return theme.Motion.SpringSpeed
	end
	return theme.Motion.SpringSpeed * m
end

--- Relative luminance of a colour, as WCAG defines it (0 black, 1 white).
function Accessibility.luminance(color: Color3): number
	local function linear(value: number): number
		return if value <= 0.03928 then value / 12.92 else ((value + 0.055) / 1.055) ^ 2.4
	end
	return 0.2126 * linear(color.R) + 0.7152 * linear(color.G) + 0.0722 * linear(color.B)
end

--- Contrast ratio between two colours, from 1 (the same) to 21 (black on white).
function Accessibility.contrast(a: Color3, b: Color3): number
	local la, lb = Accessibility.luminance(a), Accessibility.luminance(b)
	return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05)
end

export type Finding = {
	Foreground: string,
	Background: string,
	Ratio: number,
	--- 4.5 for text and 3 for graphics and borders (WCAG 2.1 AA).
	Required: number,
	Ok: boolean,
}

local TEXT_PAIRS = {
	{ "OnPrimary", "Primary" },
	{ "OnPrimaryContainer", "PrimaryContainer" },
	{ "OnError", "Error" },
	{ "OnSuccess", "Success" },
	{ "OnWarning", "Warning" },
	{ "OnInfo", "Info" },
	{ "InverseOnSurface", "InverseSurface" },
	{ "OnSurface", "Surface" },
	{ "OnSurface", "Background" },
	{ "OnSurface", "SurfaceContainer" },
	{ "OnSurface", "SurfaceContainerHigh" },
	{ "OnSurfaceVariant", "Surface" },
	{ "OnSurfaceVariant", "SurfaceContainer" },
	{ "OnSidebar", "Sidebar" },
	{ "OnSidebar", "SidebarSelected" },
}
local GRAPHIC_PAIRS = {
	{ "Primary", "Surface" },
	{ "Outline", "Surface" },
}

--- Check the colours of a theme against WCAG 2.1 AA: text on the colour it is drawn on needs a
--- ratio of 4.5, and the colours of controls and their borders need 3. Returns every pair, with
--- `Ok` false for those that fall short. `Outline` is a soft border by design and is expected to
--- fall short in the default themes; `HighContrast` raises it.
function Accessibility.audit(theme: any): { Finding }
	local findings: { Finding } = {}
	local function check(pairs: { { string } }, required: number)
		for _, pair in pairs do
			local foreground = theme.Colors[pair[1]]
			local background = theme.Colors[pair[2]]
			if foreground and background then
				local ratio = Accessibility.contrast(foreground, background)
				table.insert(findings, {
					Foreground = pair[1],
					Background = pair[2],
					Ratio = ratio,
					Required = required,
					Ok = ratio >= required,
				})
			end
		end
	end
	check(TEXT_PAIRS, 4.5)
	check(GRAPHIC_PAIRS, 3)
	return findings
end

Accessibility.TEXT_SCALE = TEXT_SCALE

return Accessibility
