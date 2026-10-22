--!strict

local RunService = game:GetService("RunService")

local Types = require(script.Parent.Types)

export type SlideOptions = {
	Travel: number?,
	Speed: number?,
	Damping: number?,
}

local SETTLED = 0.001

local function step(
	offset: number,
	velocity: number,
	speed: number,
	damping: number,
	dt: number
): (number, number)
	if damping >= 1 then
		local decay = math.exp(-speed * dt)
		local push = velocity + speed * offset
		return (offset + push * dt) * decay, (velocity - push * speed * dt) * decay
	end
	local decay = math.exp(-damping * speed * dt)
	local rate = speed * math.sqrt(1 - damping * damping)
	local cos, sin = math.cos(rate * dt), math.sin(rate * dt)
	local wide = (velocity + damping * speed * offset) / rate
	return decay * (offset * cos + wide * sin),
		decay
			* (
				cos * (wide * rate - damping * speed * offset)
				- sin * (offset * rate + damping * speed * wide)
			)
end

local Transitions = {}

function Transitions.Slide(options: SlideOptions?): Types.Transition
	local settings: SlideOptions = options or {}
	local travel = settings.Travel or 0.2
	local speed = settings.Speed or 14
	local damping = settings.Damping or 0.78

	return function(transition: Types.TransitionInfo)
		local entering, leaving = transition.Entering, transition.Leaving
		if
			(transition.Direction ~= "Forward" and transition.Direction ~= "Back")
			or not entering:IsA("GuiObject")
			or not leaving:IsA("GuiObject")
		then
			transition.Finish()
			return
		end

		local sign = if transition.Direction == "Back" then -1 else 1
		local enteringRest, leavingRest = entering.Position, leaving.Position
		local enteringOffset, enteringVelocity = sign, 0
		local leavingOffset, leavingVelocity = 0, 0
		local leavingTarget = -sign

		local connection: RBXScriptConnection
		local function apply()
			entering.Position = enteringRest + UDim2.fromScale(enteringOffset * travel, 0)
			leaving.Position = leavingRest + UDim2.fromScale(leavingOffset * travel, 0)
		end
		apply()

		connection = RunService.Heartbeat:Connect(function(dt: number)
			if entering.Parent == nil or leaving.Parent == nil then
				connection:Disconnect()
				return
			end
			enteringOffset, enteringVelocity =
				step(enteringOffset, enteringVelocity, speed, damping, dt)
			local relative, relativeVelocity =
				step(leavingOffset - leavingTarget, leavingVelocity, speed, damping, dt)
			leavingOffset, leavingVelocity = relative + leavingTarget, relativeVelocity
			apply()

			if
				math.abs(enteringOffset) < SETTLED
				and math.abs(enteringVelocity) < SETTLED
				and math.abs(leavingOffset - leavingTarget) < SETTLED
				and math.abs(leavingVelocity) < SETTLED
			then
				connection:Disconnect()
				enteringOffset, leavingOffset = 0, leavingTarget
				apply()
				transition.Finish()
			end
		end)
	end
end

return Transitions
