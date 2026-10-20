--!strict
--[[
	Opt-in state persistence across rebuilds.

	Components keep their user-visible state (the selected tab, a switch, a slider's value,
	a collapsed section…) in Fusion Values created in their own scope, so rebuilding the UI,
	to switch theme or layout, throws all of it away. Give the app a store and those Values
	live in the store's scope instead, so a rebuild picks them up again:

		local store = Pantheon.Persist.createStore(rootScope)

		local function rebuild()
			Pantheon.Persist.Provide(store, function()
				-- build the UI: every Switch, Tabs, Slider… reuses its state from last time
			end)
		end

	How a new component finds its old state: by id if you give it one
	(`[Pantheon.Persist.Id] = "settings.sound"`), otherwise by kind and creation order within the
	pass (the 3rd Switch is "Switch#3"). UI that may be rebuilt in a different order should give ids
	to its components (such as compute-based ones).
]]
local Types = require(script.Parent.Parent.Types)
local Directives = require(script.Parent.Directives)

type Store = {
	scope: Types.Scope,
	values: { [string]: any },
	counters: { [string]: number },
}

local current: Store? = nil
local pending: { kind: string, id: string }? = nil

local Persist = {}

function Persist.createStore(scope: Types.Scope): Store
	return { scope = scope, values = {}, counters = {} }
end

--- Build with `store` active. Counters restart, so the Nth component of a kind maps to the
--- same state as last pass.
function Persist.Provide<T...>(store: Store, build: (T...) -> ...any, ...: T...): ...any
	local previous = current
	current = store
	store.counters = {}
	local results = table.pack(pcall(build, ...))
	current = previous
	if not results[1] then
		error(results[2], 0)
	end
	return table.unpack(results, 2, results.n)
end

--- Give one component a stable id: `scope:Switch({ [Persist.Id] = "settings.sound" })`. The
--- state is then found by that id, not by the order the component was created in.
Persist.Id = Directives.create(nil, function(_scope, value, build, kind)
	local previous = pending
	pending = if typeof(value) == "string" then { kind = kind, id = value } else nil
	local ok, result = pcall(build)
	pending = previous
	if not ok then
		error(result, 0)
	end
	return result
end)

--- A stable key for one component instance, or nil when there is no store or the control is
--- already controlled by a state the app owns.
function Persist.key(kind: string, controlled: boolean?): string?
	local store = current
	local asked = pending
	if asked ~= nil and asked.kind == kind then
		pending = nil
	else
		asked = nil
	end
	if store == nil or controlled then
		return nil
	end
	if asked then
		return `{kind}:{asked.id}`
	end
	local n = (store.counters[kind] or 0) + 1
	store.counters[kind] = n
	return `{kind}#{n}`
end

--- The Value for one piece of a component's state: the stored one if there is one, else a new
--- one (kept in the store when there is a key). `initial` is only used the first time.
function Persist.value(scope: Types.Scope, key: string?, slot: string, initial: any): any
	local store = current
	if key == nil or store == nil then
		return scope:Value(initial)
	end
	local full = `{key}/{slot}`
	local existing = store.values[full]
	if existing == nil then
		existing = store.scope:Value(initial)
		store.values[full] = existing
	end
	return existing
end

return Persist
