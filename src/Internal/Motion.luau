--!strict
local Types = require(script.Parent.Parent.Types)

--[[
	Springs by role. A component asks for a role, such as "Snappy", and not for a number, so
	a blueprint can change how all of them move. `speedScale` is for a component that has
	always moved a little faster or slower than its role.
]]
local Motion = {}

function Motion.tuning(theme: Types.Theme, role: string, speedScale: number?): (number, number)
	local motion = theme.Motion
	local tuning = if motion.Springs then motion.Springs[role] else nil
	local speed = if tuning then tuning.Speed else motion.SpringSpeed
	local damping = if tuning then tuning.Damping else motion.SpringDamping
	return speed * (speedScale or 1), damping
end

function Motion.spring(
	scope: Types.Scope,
	goal: any,
	theme: Types.Theme,
	role: string,
	speedScale: number?
): any
	local speed, damping = Motion.tuning(theme, role, speedScale)
	return scope:Spring(goal, speed, damping)
end

return Motion
