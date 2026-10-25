--!strict
--[[
	Group fade without a CanvasGroup: a "layer transparency" modifier.

	CanvasGroup flattens its subtree to a texture: extra memory and draw cost, softer
	text, and it clips anything that spills outside it (UIShadow, UIStroke…). Instead we
	fade every descendant's own transparency by one shared multiplier:

		transparency = 1 − (1 − base) × alpha

	so an opaque panel, its text, icons, strokes, shadows and scrollbars all fade
	together, and nothing is clipped or rasterised.

	How it stays correct while the UI keeps animating inside the group (hover springs,
	pulsing strokes…): every tick we first compare each property with the value *we* last
	wrote. If it differs, something else changed it, so that new value becomes the base.
	Then we write the faded value. At alpha = 1 the exact bases are restored and all
	tracking stops, so a fully visible group costs nothing.

	Elements can opt out with the attribute `PantheonNoFade = true`.
]]
local Fusion = require(script.Parent.Parent.Parent.Fusion)
local Types = require(script.Parent.Parent.Types)

local peek = Fusion.peek

-- Roblox stores these as float32, so allow rounding when checking our own write.
local TOLERANCE = 0.002
-- At or above this the group counts as fully shown: restore bases and stop tracking.
local SETTLED = 0.998

--- One record for each faded property, shared by every group that fades it. When a group inside
--- another group fades too, they both use the true base value, and the property gets the product of
--- their alphas. Without this the inner group would keep the outer group's faded value as its base.
type Record = { base: number, written: number, alphas: { [number]: number } }
type Entry = { inst: Instance, prop: string, rec: Record }

local records: { [Instance]: { [string]: Record } } = setmetatable({}, { __mode = "k" }) :: any
local nextId = 0

local function faded(rec: Record): number
	local product = 1
	for _, alpha in rec.alphas do
		product *= alpha
	end
	return 1 - (1 - rec.base) * product
end

--- Transparency properties to drive, by class.
local function propsFor(inst: Instance): { string }?
	if inst:GetAttribute("PantheonNoFade") == true then
		return nil
	end
	if inst:IsA("GuiObject") then
		local list = { "BackgroundTransparency" }
		if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
			table.insert(list, "TextTransparency")
			table.insert(list, "TextStrokeTransparency")
		elseif inst:IsA("ImageLabel") or inst:IsA("ImageButton") or inst:IsA("ViewportFrame") then
			table.insert(list, "ImageTransparency")
		elseif inst:IsA("ScrollingFrame") then
			table.insert(list, "ScrollBarImageTransparency")
		end
		return list
	elseif inst:IsA("UIStroke") or inst.ClassName == "UIShadow" then
		return { "Transparency" }
	end
	return nil
end

local GroupFade = {}

--- Fade `root` and everything under it with `alpha` (a state: 0 = invisible, 1 = shown).
function GroupFade.bind(scope: Types.Scope, root: Instance, alpha: any)
	nextId += 1
	local id = nextId
	local entries: { Entry } = {}
	local tracked: { [Instance]: boolean } = {}
	local active = false
	local added: RBXScriptConnection? = nil

	local function track(inst: Instance)
		if tracked[inst] then
			return
		end
		local list = propsFor(inst)
		if list == nil then
			return
		end
		tracked[inst] = true
		for _, prop in list do
			local ok, value = pcall(function()
				return (inst :: any)[prop]
			end)
			if ok and typeof(value) == "number" then
				local byProp = records[inst]
				if byProp == nil then
					byProp = {}
					records[inst] = byProp
				end
				local rec = (byProp :: any)[prop]
				if rec == nil then
					rec = { base = value, written = value, alphas = {} };
					(byProp :: any)[prop] = rec
				end
				table.insert(entries, { inst = inst, prop = prop, rec = rec })
			end
		end
	end

	local function begin()
		active = true
		track(root)
		for _, inst in root:GetDescendants() do
			track(inst)
		end
		added = root.DescendantAdded:Connect(track)
	end

	local function finish()
		for _, e in entries do
			local rec = e.rec
			rec.alphas[id] = nil
			local ok, current = pcall(function()
				return (e.inst :: any)[e.prop]
			end)
			if ok then
				if math.abs(current - rec.written) > TOLERANCE then
					rec.base = current
				end
				local value = if next(rec.alphas) == nil then rec.base else faded(rec);
				(e.inst :: any)[e.prop] = value
				rec.written = value
			end
			if next(rec.alphas) == nil then
				local byProp = records[e.inst]
				if byProp then
					byProp[e.prop] = nil
				end
			end
		end
		table.clear(entries)
		table.clear(tracked)
		if added then
			added:Disconnect()
			added = nil
		end
		active = false
	end

	local function apply(a: number)
		-- Drop anything destroyed since the last tick, in place.
		local count = #entries
		local keep = 0
		for i = 1, count do
			local e = entries[i]
			if e.inst.Parent ~= nil or e.inst == root then
				keep += 1
				entries[keep] = e
			end
		end
		for i = count, keep + 1, -1 do
			entries[i] = nil
		end

		for _, e in entries do
			local rec = e.rec
			local current = (e.inst :: any)[e.prop] :: number
			if math.abs(current - rec.written) > TOLERANCE then
				rec.base = current -- changed by someone else (hover, pulse…)
			end
			rec.alphas[id] = a
			local value = faded(rec);
			(e.inst :: any)[e.prop] = value
			rec.written = value
		end
	end

	local function update()
		local a = math.clamp(peek(alpha) :: number, 0, 1)
		if a >= SETTLED then
			if active then
				finish()
			end
			return
		end
		if not active then
			begin()
		end
		apply(a)
	end

	table.insert(scope, scope:Observer(alpha):onChange(update))
	-- Start hidden from the first frame (after the children exist), not on the first change.
	if (peek(alpha) :: number) < SETTLED then
		task.defer(update)
	end
	table.insert(scope, function()
		if added then
			added:Disconnect()
			added = nil
		end
	end)
end

return GroupFade
