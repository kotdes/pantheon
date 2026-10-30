--!strict
local Types = require(script.Parent.Parent.Types)

--- The default that the theme's blueprint gives to a prop of a component, or nil if it gives none.
--- Write `props.Variant or Defaults.get(theme, "TextField", "Variant")`, so a prop that you set wins.
local Defaults = {}

function Defaults.get(theme: Types.Theme, component: string, prop: string): any
	local defaults = theme.Defaults
	local forComponent = if defaults then defaults[component] else nil
	return if forComponent then forComponent[prop] else nil
end

--- Whether a control draws its outline when it is at rest. The prop of the component wins, then
--- the default of the blueprint for that component, then the blueprint's default for `All`.
--- A theme with no blueprint outlines everything.
function Defaults.outlined(theme: Types.Theme, component: string, prop: boolean?): boolean
	if prop ~= nil then
		return prop
	end
	local own = Defaults.get(theme, component, "Outlined")
	if own ~= nil then
		return own == true
	end
	return Defaults.get(theme, "All", "Outlined") ~= false
end

return Defaults
