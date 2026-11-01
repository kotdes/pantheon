--!strict
local Fusion = require(script.Parent.Parent.Parent.Fusion)
local Types = require(script.Parent.Parent.Types)
local Layer = require(script.Parent.Layer)
local Morph = require(script.Parent.Morph)
local Presence = require(script.Parent.Presence)
local whileActive = require(script.Parent.Follow)

local Children = Fusion.Children

local GAP = 4
local ZINDEX = 200

local Dropdown = {}

local function hasContent(panel: GuiObject): boolean
	for _, child in panel:GetChildren() do
		if child:IsA("GuiObject") then
			return true
		end
	end
	return false
end

function Dropdown.morphs(theme: Types.Theme, props: { Layer: Instance? }): boolean
	return Presence.fromOrigin(theme) and Layer.resolve(props) ~= nil
end

export type Config = {
	Theme: Types.Theme,
	Open: any,
	Trigger: GuiObject,
	Panel: GuiObject,
	MinWidth: number,
	MorphTarget: Instance?,
}

function Dropdown.mount(scope: Types.Scope, props: { Layer: Instance? }, config: Config)
	local layer = Layer.resolve(props)
	if layer == nil then
		return
	end
	local shape = Morph.create(scope, {
		Theme = config.Theme,
		Open = config.Open,
		Content = config.Panel,
		ZIndex = ZINDEX,
	})
	local root = scope:Frame({
		Name = "Dropdown",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = shape.Presence.Mounted,
		ZIndex = ZINDEX,
		[Children] = { shape.Instance },
	})
	Layer.mount(scope, props, root)

	local trigger, panel = config.Trigger, config.Panel
	whileActive(scope, config.Open, function(value)
		return value == true
	end, function()
		local origin = layer.AbsolutePosition
		local at = trigger.AbsolutePosition - origin
		local width = math.max(trigger.AbsoluteSize.X, config.MinWidth)
		panel.Size = UDim2.fromOffset(width, 0)
		local height = panel.AbsoluteSize.Y
		if height < 1 or not hasContent(panel) then
			return
		end
		local bounds = layer.AbsoluteSize
		local below = bounds.Y - (at.Y + trigger.AbsoluteSize.Y + GAP)
		local above = at.Y - GAP
		local flip = height > below and above > below
		local x = math.clamp(at.X, 0, math.max(bounds.X - width, 0))
		local y = if flip then at.Y - GAP - height else at.Y + trigger.AbsoluteSize.Y + GAP
		shape.measure(
			Layer.asGui(config.MorphTarget) or trigger,
			layer,
			Vector2.new(x, y),
			Vector2.new(width, height)
		)
	end)
end

return Dropdown
