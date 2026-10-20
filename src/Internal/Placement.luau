--!strict
--[[
	Pick where a floating card goes relative to a target: the requested side, or with
	"Auto" whichever side overflows the viewport least. A requested side that does not fit
	flips to the opposite side when that overflows less. Shared by Tooltip / Coachmark / Popover.
	Returns (position, chosenSide) with the position clamped inside the viewport.
]]
local Types = require(script.Parent.Parent.Types)

local function place(
	placement: Types.TooltipPlacement,
	targetPos: Vector2,
	targetSize: Vector2,
	tipSize: Vector2,
	gap: number,
	viewport: Vector2
): (UDim2, Types.TooltipPlacement)
	local function forSide(side: Types.TooltipPlacement): (number, number, number)
		local x, y
		if side == "Bottom" then
			x = targetPos.X + targetSize.X * 0.5 - tipSize.X * 0.5
			y = targetPos.Y + targetSize.Y + gap
		elseif side == "Top" then
			x = targetPos.X + targetSize.X * 0.5 - tipSize.X * 0.5
			y = targetPos.Y - tipSize.Y - gap
		elseif side == "Left" then
			x = targetPos.X - tipSize.X - gap
			y = targetPos.Y + targetSize.Y * 0.5 - tipSize.Y * 0.5
		else -- Right
			x = targetPos.X + targetSize.X + gap
			y = targetPos.Y + targetSize.Y * 0.5 - tipSize.Y * 0.5
		end
		local overflow = 0
		if x < 8 then
			overflow += 8 - x
		end
		if y < 8 then
			overflow += 8 - y
		end
		if x + tipSize.X > viewport.X - 8 then
			overflow += (x + tipSize.X) - (viewport.X - 8)
		end
		if y + tipSize.Y > viewport.Y - 8 then
			overflow += (y + tipSize.Y) - (viewport.Y - 8)
		end
		return x, y, overflow
	end

	local chosen: Types.TooltipPlacement = if placement == "Auto" then "Bottom" else placement
	local bestX, bestY, bestOverflow = forSide(chosen)

	if placement == "Auto" then
		bestOverflow = math.huge
		local function trySide(side: Types.TooltipPlacement)
			local x, y, overflow = forSide(side)
			if overflow < bestOverflow then
				bestOverflow = overflow
				bestX, bestY = x, y
				chosen = side
			end
		end
		trySide("Bottom")
		trySide("Top")
		trySide("Right")
		trySide("Left")
	end

	if placement ~= "Auto" and bestOverflow > 0 then
		local opposite: Types.TooltipPlacement = if placement == "Bottom"
			then "Top"
			elseif placement == "Top" then "Bottom"
			elseif placement == "Left" then "Right"
			else "Left"
		local x, y, overflow = forSide(opposite)
		if overflow < bestOverflow then
			bestX, bestY = x, y
			chosen = opposite
		end
	end

	bestX = math.clamp(bestX, 8, math.max(8, viewport.X - tipSize.X - 8))
	bestY = math.clamp(bestY, 8, math.max(8, viewport.Y - tipSize.Y - 8))
	return UDim2.fromOffset(bestX, bestY), chosen
end

return place
