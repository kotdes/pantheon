--!strict
local Types = require(script.Parent.Parent.Types)
local Prompt = require(script.Parent.Prompt)

--[[
	Deprecated: use `Prompt` with `Destructive = true`. This stays so that existing code keeps
	working. It passes every prop on to `Prompt`, and is destructive unless you say it is not.
]]
return function(scope: Types.Scope, props: Types.ConfirmDialogProps): Instance
	local merged = table.clone(props :: any)
	if merged.Destructive == nil then
		merged.Destructive = true
	end
	return Prompt(scope, merged)
end
