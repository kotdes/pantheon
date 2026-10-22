--!strict
--[[
	EdgeFade.luau

	A common utility for fading the edges of a bar. This is seen in components such as the AppBar and its footer counterpart.
]]
local EdgeFade = {}

EdgeFade.HeightAttribute = "PantheonBarHeight"
EdgeFade.FadeAttribute = "PantheonBarFade"

function EdgeFade.gradient(scope: any, rotation: number, barHeight: number, fadeHeight: number)
	local solid = math.clamp(barHeight / math.max(barHeight + fadeHeight, 1), 0, 0.99)
	return scope:New("UIGradient")({
		Rotation = rotation,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(solid, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
	})
end

return EdgeFade
