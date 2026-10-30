--!strict
--[[
	Run `step` on RenderStepped only while `active(peek)` holds.

	Replaces always-on `RenderStepped:Connect(function() if open then … end end)`
	loops: closed popovers / tooltips no longer cost a connection per frame.
]]
local RunService = game:GetService("RunService")

local Fusion = require(script.Parent.Parent.Parent.Fusion)
local Types = require(script.Parent.Parent.Types)

local peek = Fusion.peek

local function whileActive(
	scope: Types.Scope,
	source: any,
	isActive: (value: any) -> boolean,
	step: (dt: number) -> ()
)
	local conn: RBXScriptConnection? = nil
	local function sync()
		local on = isActive(peek(source))
		if on and not conn then
			conn = RunService.RenderStepped:Connect(step)
			task.defer(function()
				if conn then
					step(0)
				end
			end)
		elseif not on and conn then
			conn:Disconnect()
			conn = nil
		end
	end
	table.insert(scope, scope:Observer(source):onBind(sync))
	table.insert(scope, function()
		if conn then
			conn:Disconnect()
			conn = nil
		end
	end)
end

return whileActive
