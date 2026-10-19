--!strict
--[[
	Directives: behaviour you can put on any component without it having a prop for it.

		local tw = Pantheon.Directives.Tag(tag)

		scope:Button({
			Text = "Save",
			[tw] = "px-4 rounded-md",
		})

	A directive is a SpecialKey in a component constructor's props. Pantheon will take it out before the component
	sees the props, builds the component, then applies the directive to the Instance the component
	returns (its root). Directives are for things that are not part of what a component looks like
	or how it is used: a Tailwind-style class, a test tag, an analytics hook, etc.

	Directives run for `scope:X(props)` and for `Pantheon.Components.X(scope, props)`.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)

local peek = Fusion.peek

local Directives = {}

local function isState(value: any): boolean
	return typeof(value) == "table" and (value :: any).type == "State"
end

--- Is `key` a directive made by `Directives.create`?
function Directives.is(key: any): boolean
	return typeof(key) == "table" and (key :: any).type == "Directive"
end

--- Create a directive. `apply(scope, value, target)` runs once, with the root Instance of the
--- component and the value it was given (a plain value or a state). Anything that needs
--- cleaning up can be put in `scope`.
function Directives.create(
	apply: (scope: Types.Scope, value: any, target: Instance) -> ()
): Types.Directive
	return table.freeze({
		type = "Directive",
		apply = function(_self: any, scope: Types.Scope, value: any, target: Instance)
			apply(scope, value, target)
		end,
	}) :: any
end

--- A directive that applies utility classes. `tag(instance, classes)` is the function that
--- turns a string of space-separated class names into styling; it is expected to add each name
--- to the Instance as a CollectionService tag.
--- The value is a string of classes, or a state of one; when the state changes the old classes
--- are removed from the Instance and the new ones added.
function Directives.Tag(tag: (instance: Instance, classes: string) -> ()): Types.Directive
	return Directives.create(function(scope, value, target)
		local applied: { string } = {}
		local function set(classes: any)
			for _, name in applied do
				target:RemoveTag(name)
			end
			applied = {}
			if typeof(classes) ~= "string" then
				return
			end
			for name in string.gmatch(classes, "%S+") do
				table.insert(applied, name)
			end
			-- One space between names, so `tag` never sees an empty name.
			tag(target, table.concat(applied, " "))
		end
		set(peek(value))
		if isState(value) then
			table.insert(
				scope,
				scope:Observer(value):onChange(function()
					set(peek(value))
				end)
			)
		end
	end)
end

--- Wrap a component `(scope, props) -> Instance` so it understands directives. Props without
--- one go straight through, so a component that is not given a directive costs one table scan.
function Directives.wrap(component: (scope: Types.Scope, props: any) -> Instance)
	return function(scope: Types.Scope, props: any): Instance
		local found: { [any]: any }? = nil
		for key, value in props do
			if Directives.is(key) then
				if found == nil then
					found = {}
				end
				(found :: any)[key] = value
			end
		end
		if found == nil then
			return component(scope, props)
		end
		local plain = table.clone(props)
		for key in found do
			plain[key] = nil
		end
		local instance = component(scope, plain)
		for key, value in found do
			key:apply(scope, value, instance)
		end
		return instance
	end
end

return Directives
