--!strict

local Packages = script.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Types)

local contextual = Fusion.Contextual(nil :: Types.Router?)

local Context = {}

function Context.provide(router: Types.Router, render: () -> Instance?): Instance?
	return contextual:is(router):during(render)
end

function Context.use(): Types.Router?
	return contextual:now()
end

return Context
