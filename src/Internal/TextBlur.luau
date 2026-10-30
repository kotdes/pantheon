--!strict
local Types = require(script.Parent.Parent.Types)
local Features = require(script.Parent.Features)

--[[
	Motion blur for text: a text-mode UIShadow in the colour of the text, as NumberSpinner uses.
	`amount` is a state from 0 (sharp, in place) to 1 (as blurred as it gets). The shadow rises
	quickly with it, then fades before it reaches 1, where the text is gone anyway.

	Returns the shadow to put in the children of the label, or nil on an engine that has no text
	shadows, so a caller can write it into a list of children without a check.
]]
local TextBlur = {}

local MAX = 0.2 -- blur radius, as a share of the text size, at its peak

local function strength(p: number): number
	local rise = math.clamp(p / 0.2, 0, 1)
	local fall = 1 - math.clamp((p - 0.55) / 0.45, 0, 1)
	return rise * fall
end

function TextBlur.shadow(scope: Types.Scope, textSize: number, colour: any, amount: any): Instance?
	if not Features.shadowText() then
		return nil
	end
	return scope:New("UIShadow")({
		Mode = "Text",
		Color = colour,
		Offset = UDim2.fromOffset(0, 0),
		Transparency = scope:Computed(function(use)
			return 1 - 0.75 * strength(math.clamp(use(amount) :: number, 0, 1))
		end),
		BlurRadius = scope:Computed(function(use)
			return UDim.new(0, textSize * MAX * math.clamp(use(amount) :: number, 0, 1) ^ 0.8)
		end),
	})
end

return TextBlur
