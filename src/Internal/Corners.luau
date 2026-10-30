--!strict
--[[
	Set per-corner radii on a GuiObject's UICorner (creating one if needed). Used by
	containers like Window to round the chrome they host (app bar, rail) to match their
	own corners: ClipsDescendants only clips to a rectangle, not a rounded one.

	Needs individual corner radii (live since June 2026); on older engines it does nothing
	and the child keeps whatever rounding it already had.
]]
local Features = require(script.Parent.Features)

local Corners = {}

function Corners.apply(
	inst: Instance?,
	topLeft: number,
	topRight: number,
	bottomLeft: number,
	bottomRight: number
)
	if inst == nil or not inst:IsA("GuiObject") or not Features.individualCorners() then
		return
	end
	local corner = inst:FindFirstChildOfClass("UICorner")
	if corner == nil then
		corner = Instance.new("UICorner");
		(corner :: UICorner).Parent = inst
	end
	local c = corner :: any
	c.TopLeftRadius = UDim.new(0, topLeft)
	c.TopRightRadius = UDim.new(0, topRight)
	c.BottomLeftRadius = UDim.new(0, bottomLeft)
	c.BottomRightRadius = UDim.new(0, bottomRight)
end

local WINDOW_RADIUS = "PantheonWindowRadius"

--- Corner radius of the nearest enclosing Window (0 if none). Windows publish theirs as an
--- attribute so floating UI that fills the window (scrims, sheets) can match its rounding.
function Corners.windowRadius(inst: Instance?): number
	local current = if inst then inst.Parent else nil
	while current do
		local r = current:GetAttribute(WINDOW_RADIUS)
		if typeof(r) == "number" then
			return r
		end
		current = current.Parent
	end
	return 0
end

Corners.WindowRadiusAttribute = WINDOW_RADIUS

--- Call `apply(radius)` now and whenever `inst` is re-parented (it may be built before the
--- window that will end up containing it). Returns a disconnect function.
function Corners.followWindow(inst: Instance, apply: (radius: number) -> ()): () -> ()
	local last = -1
	local function sync()
		local r = Corners.windowRadius(inst)
		if r ~= last then
			last = r
			apply(r)
		end
	end
	local conn = inst.AncestryChanged:Connect(sync)
	task.defer(sync)
	return function()
		conn:Disconnect()
	end
end

local CONTAINER_RADIUS = "PantheonContainerRadius"

Corners.ContainerRadiusAttribute = CONTAINER_RADIUS

function Corners.concentric(outer: number, inset: number, minimum: number?): number
	return math.max(outer - inset, minimum or 0)
end

function Corners.setContainer(inst: Instance, radius: number)
	inst:SetAttribute(CONTAINER_RADIUS, radius)
end

local STACKED = "PantheonStackedRows"

--- Marks a container whose children are rows stacked edge to edge, such as a card of list items.
--- A row is rounded only at the corners that touch the container's own corners, so a row in the
--- middle has square corners and the first and last rows have the container's radius there.
function Corners.setStacked(inst: Instance)
	inst:SetAttribute(STACKED, true)
end

local function radiusOf(inst: Instance): number?
	local r = inst:GetAttribute(CONTAINER_RADIUS)
	if typeof(r) ~= "number" then
		r = inst:GetAttribute(WINDOW_RADIUS)
	end
	return if typeof(r) == "number" then r else nil
end

function Corners.container(inst: Instance?): (Instance?, number)
	local current = if inst then inst.Parent else nil
	while current do
		local r = radiusOf(current)
		if r ~= nil then
			return current, r
		end
		current = current.Parent
	end
	return nil, 0
end

function Corners.containerRadius(inst: Instance?): number
	local _, r = Corners.container(inst)
	return r
end

export type AutoOptions = {
	Container: boolean?,
	Minimum: number?,
}

local DEFAULT_MINIMUM = 4

function Corners.auto(
	inst: GuiObject,
	explicit: any?,
	fallback: number,
	options: AutoOptions?
): () -> ()
	local opts = options or {} :: AutoOptions
	local minimum = opts.Minimum or DEFAULT_MINIMUM
	local own = if typeof(explicit) == "number" then explicit else fallback
	if opts.Container then
		Corners.setContainer(inst, own)
	end
	if explicit ~= nil then
		return function() end
	end

	local watched: { RBXScriptConnection } = {}
	local watching: Instance? = nil
	local last = { -1, -1, -1, -1 }

	local function clearWatch()
		for _, c in watched do
			c:Disconnect()
		end
		table.clear(watched)
		watching = nil
	end

	local sync: () -> ()

	local function apply(tl: number, tr: number, bl: number, br: number)
		if
			math.abs(tl - last[1]) < 0.25
			and math.abs(tr - last[2]) < 0.25
			and math.abs(bl - last[3]) < 0.25
			and math.abs(br - last[4]) < 0.25
		then
			return
		end
		last = { tl, tr, bl, br }
		if Features.individualCorners() then
			Corners.apply(inst, tl, tr, bl, br)
		else
			local corner = inst:FindFirstChildOfClass("UICorner")
			if corner then
				corner.CornerRadius = UDim.new(0, math.max(tl, tr, bl, br))
			end
		end
		if opts.Container then
			Corners.setContainer(inst, math.max(tl, tr, bl, br))
		end
	end

	local function watch(target: Instance)
		if watching == target then
			return
		end
		clearWatch()
		watching = target
		table.insert(watched, target:GetAttributeChangedSignal(CONTAINER_RADIUS):Connect(sync))
		table.insert(watched, target:GetAttributeChangedSignal(WINDOW_RADIUS):Connect(sync))
		table.insert(watched, target:GetAttributeChangedSignal(STACKED):Connect(sync))
		if target:IsA("GuiObject") then
			table.insert(watched, target:GetPropertyChangedSignal("AbsolutePosition"):Connect(sync))
			table.insert(watched, target:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync))
		end
	end

	local syncing = false
	local again = false
	local function run()
		local target, outer = Corners.container(inst)
		if target == nil then
			clearWatch()
			apply(fallback, fallback, fallback, fallback)
			return
		end
		watch(target)

		local dl, dt, dr, db = 0, 0, 0, 0
		if target:IsA("GuiObject") then
			local tp, ts = target.AbsolutePosition, target.AbsoluteSize
			local ip, is = inst.AbsolutePosition, inst.AbsoluteSize
			dl = math.max(ip.X - tp.X, 0)
			dt = math.max(ip.Y - tp.Y, 0)
			dr = math.max(tp.X + ts.X - (ip.X + is.X), 0)
			db = math.max(tp.Y + ts.Y - (ip.Y + is.Y), 0)
		end
		local stacked = target:GetAttribute(STACKED) == true
		local function corner(gapA: number, gapB: number): number
			if stacked then
				-- A corner is at the container's corner only when it is close to both edges.
				local gap = math.max(gapA, gapB)
				return if gap >= outer then 0 else Corners.concentric(outer, gap)
			end
			local r = Corners.concentric(outer, math.min(gapA, gapB), minimum)
			return math.min(r, math.max(fallback, minimum))
		end
		apply(corner(dl, dt), corner(dr, dt), corner(dl, db), corner(dr, db))
	end

	-- Setting radii can move things on some engines, which calls this again from inside itself. A
	-- call that comes while it runs is done once more afterwards, and not nested, so it cannot
	-- loop.
	sync = function()
		if syncing then
			again = true
			return
		end
		syncing = true
		local rounds = 0
		repeat
			again = false
			rounds += 1
			run()
		until not again or rounds >= 3
		syncing = false
	end

	local own1 = inst.AncestryChanged:Connect(sync)
	local own2 = inst:GetPropertyChangedSignal("AbsolutePosition"):Connect(sync)
	local own3 = inst:GetPropertyChangedSignal("AbsoluteSize"):Connect(sync)
	local function stop()
		own1:Disconnect()
		own2:Disconnect()
		own3:Disconnect()
		clearWatch()
	end
	inst.Destroying:Connect(stop)
	task.defer(sync)
	return stop
end

return Corners
