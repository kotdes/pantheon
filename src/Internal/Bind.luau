--!strict
--[[
	Two-way binding between a component's own state and a state the caller passes in.

	A control keeps its value in a Value of its own. If the caller gives a state for that value,
	`Bind.link` keeps the two equal: setting the caller's state moves the control, and the user
	changing the control sets the caller's state, as long as it is a Value. A Computed can't be
	set, so it only drives the control. A plain value isn't a state and is left alone.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)

local peek = Fusion.peek

local function sameValue(a: any, b: any): boolean
	return a == b
end

export type Options = {
	--- Convert a value of the caller's state into the control's own form.
	toInternal: ((value: any) -> any)?,
	--- Convert the control's value into the form the caller's state holds.
	toProp: ((value: any) -> any)?,
	--- Compare two values. Needed for tables; the default is `==`.
	equals: ((a: any, b: any) -> boolean)?,
}

--- A state that can't be set (a Computed) only drives the control. If the user then changes the
--- control, the two disagree, and the state can't follow properly. This warns the developer that the two are in conflict.
local function warnReadOnly(scope: Types.Scope, prop: any, internal: any)
	local warned = false
	table.insert(
		scope,
		scope:Observer(internal):onChange(function()
			if warned or peek(internal) == peek(prop) then
				return
			end
			warned = true
			warn(
				"[Pantheon] An external entity changed a control whose value is a read-only state (a "
					.. "Computed), so the two now in conflict. Pass a Value to sync."
			)
		end)
	)
end

local Bind = {}

function Bind.isState(value: any): boolean
	return typeof(value) == "table" and (value :: any).type == "State"
end

function Bind.isWritable(value: any): boolean
	return Bind.isState(value) and typeof((value :: any).set) == "function"
end

--- Equality for lists of strings or numbers.
function Bind.listEquals(a: any, b: any): boolean
	if a == b then
		return true
	end
	if typeof(a) ~= "table" or typeof(b) ~= "table" or #a ~= #b then
		return false
	end
	for index, value in a do
		if b[index] ~= value then
			return false
		end
	end
	return true
end

--- Link `internal` (the control's Value) with `prop` (what the caller passed).
function Bind.link(scope: Types.Scope, prop: any, internal: any, options: Options?)
	if not Bind.isState(prop) then
		return
	end
	local toInternal = if options and options.toInternal then options.toInternal else nil
	local toProp = if options and options.toProp then options.toProp else nil
	local equals: (a: any, b: any) -> boolean = (options and options.equals) or sameValue

	local syncing = false
	table.insert(
		scope,
		scope:Observer(prop):onChange(function()
			if syncing then
				return
			end
			local incoming = peek(prop)
			if toInternal then
				incoming = toInternal(incoming)
			end
			if not equals(incoming, peek(internal)) then
				syncing = true
				internal:set(incoming)
				syncing = false
			end
		end)
	)
	if Bind.isWritable(prop) then
		table.insert(
			scope,
			scope:Observer(internal):onChange(function()
				if syncing then
					return
				end
				local current = peek(internal)
				-- `equals` works on the control's form, so bring the caller's value to it.
				local theirs = peek(prop)
				if toInternal then
					theirs = toInternal(theirs)
				end
				if not equals(current, theirs) then
					syncing = true
					prop:set(if toProp then toProp(current) else current)
					syncing = false
				end
			end)
		)
	elseif not toInternal and not toProp and not (options and options.equals) then
		warnReadOnly(scope, prop, internal)
	end
end

--- Like `link`, for a value the control keeps in several Values: a range in two ends, a date in
--- year, month and day. `join` builds the caller's value from the parts, `split` takes it apart.
--- `split` may return nothing usable (for example for a malformed date): the parts are then kept.
function Bind.linkParts(
	scope: Types.Scope,
	prop: any,
	parts: { any },
	join: (...any) -> any,
	split: (value: any) -> { any }?,
	equals: ((a: any, b: any) -> boolean)?
)
	if not Bind.isState(prop) then
		return
	end
	local same: (a: any, b: any) -> boolean = equals or sameValue
	local syncing = false
	table.insert(
		scope,
		scope:Observer(prop):onChange(function()
			if syncing then
				return
			end
			local values = split(peek(prop))
			if values == nil then
				return
			end
			syncing = true
			for index, part in parts do
				if values[index] ~= nil and peek(part) ~= values[index] then
					part:set(values[index])
				end
			end
			syncing = false
		end)
	)
	if Bind.isWritable(prop) then
		local function push()
			if syncing then
				return
			end
			local values = {}
			for index, part in parts do
				values[index] = peek(part)
			end
			local outgoing = join(table.unpack(values))
			if not same(outgoing, peek(prop)) then
				syncing = true
				prop:set(outgoing)
				syncing = false
			end
		end
		for _, part in parts do
			table.insert(scope, scope:Observer(part):onChange(push))
		end
	end
end

return Bind
