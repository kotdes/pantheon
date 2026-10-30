--!strict
local Types = require(script.Parent.Parent.Types)
local Motion = require(script.Parent.Motion)

--[[
	The coming and going of an overlay. `Progress` is a spring that goes to 1 when `open` is
	true and to 0 when it is false, and `Mounted` stays true until it has gone back to 0,
	so the exit can finish before the overlay is hidden.
]]
local Presence = {}

export type Result = {
	Progress: any,
	Mounted: any,
}

function Presence.create(
	scope: Types.Scope,
	open: any,
	theme: Types.Theme,
	role: string,
	speedScale: number?
): Result
	local progress = Motion.spring(
		scope,
		scope:Computed(function(use)
			return if use(open) then 1 else 0
		end),
		theme,
		role,
		speedScale
	)
	return {
		Progress = progress,
		Mounted = scope:Computed(function(use)
			return use(open) == true or use(progress) > 0.02
		end),
	}
end

local function presenceOf(theme: Types.Theme): Types.ThemePresence
	return theme.Motion.Presence or {}
end

--- The scale of an overlay at `progress` (0 to 1, or a little past 1 with a springy theme).
function Presence.scaleAt(theme: Types.Theme, progress: number): number
	local from = presenceOf(theme).ScaleFrom or 1
	return from + (1 - from) * progress
end

--- The progress of the item at `index` (1 for the first) of a list that comes in together.
--- Each item starts a little after the one before it, and all of them end together, so the
--- list is never slower than its spring. Returns nil when the theme has no stagger, so a
--- caller can skip the work.
function Presence.stagger(
	scope: Types.Scope,
	progress: any,
	index: number,
	theme: Types.Theme
): any?
	local stagger = theme.Motion.Stagger or 0
	if stagger <= 0 or progress == nil then
		return nil
	end
	-- A spring has no fixed length, so the gap is a share of its travel: 250 ms is one whole travel.
	local delay = math.min((index - 1) * stagger / 250, 0.6)
	return scope:Computed(function(use)
		return math.clamp((use(progress) - delay) / (1 - delay), 0, 1)
	end)
end

--- True when an overlay should grow out of the control that opened it.
function Presence.fromOrigin(theme: Types.Theme): boolean
	return presenceOf(theme).FromOrigin == true
end

return Presence
