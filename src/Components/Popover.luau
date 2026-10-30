--!strict
--[[
	Anchored popover: Overlay + positioned Menu (Embedded).
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Focus = require(script.Parent.Parent.Internal.Focus)
local Layer = require(script.Parent.Parent.Internal.Layer)
local Follow = require(script.Parent.Parent.Internal.Follow)
local Morph = require(script.Parent.Parent.Internal.Morph)
local Presence = require(script.Parent.Parent.Internal.Presence)
local place = require(script.Parent.Parent.Internal.Placement)
local Overlay = require(script.Parent.Overlay)
local Menu = require(script.Parent.Menu)

local Children = Fusion.Children
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.PopoverProps): Instance
	local theme = resolveTheme(props)
	local openRef = props.Open
	local open = scope:Computed(function(use)
		if openRef == nil then
			return true
		end
		return (if typeof(openRef) == "table" then use(openRef) else openRef) == true
	end)
	local width = props.Width or 240
	local placement = props.Placement or "Bottom"
	local pos = scope:Value(UDim2.fromOffset(0, 0))
	local morph = Presence.fromOrigin(theme)

	local menu = Menu(scope, {
		Theme = theme,
		Embedded = true,
		Open = open,
		OnClose = props.OnClose,
		Items = props.Items,
		Sections = props.Sections,
		MaxHeight = props.MaxHeight,
		AutoHeight = props.AutoHeight,
		Children = props.Children,
		RootPage = props.RootPage,
		Page = props.Page,
		OnChanged = props.OnChanged,
		Size = UDim2.fromOffset(width, 0),
		Padding = 6,
		ZIndex = (props.ZIndex or 90) + 1,
	})

	local shape = if morph
		then Morph.create(scope, {
			Theme = theme,
			Open = open,
			Content = menu :: GuiObject,
			ZIndex = (props.ZIndex or 90) + 1,
		})
		else nil
	local presence = if shape then shape.Presence else Presence.create(scope, open, theme, "Bouncy")
	local openS = presence.Progress

	scope:Apply(menu)({
		Name = "PopoverPanel",
		Position = if morph then UDim2.fromOffset(0, 0) else pos,
	})

	local scale: UIScale? = nil
	if not morph then
		local grow = Instance.new("UIScale")
		grow.Parent = menu
		scale = grow
		table.insert(
			scope,
			scope:Observer(openS):onBind(function()
				grow.Scale = Presence.scaleAt(theme, peek(openS))
			end)
		)
	end

	-- Placed with the menu's real size: on the preferred side when it fits, else on the other
	-- side, and always kept inside the layer.
	local function updatePosition()
		local target = Layer.asGui(props.Target)
		local layer = Layer.resolve(props)
		if target == nil or layer == nil then
			return
		end
		local origin = layer.AbsolutePosition
		-- The scale of the panel is part of its measured size, so take it out.
		local size = (menu :: GuiObject).AbsoluteSize
			/ math.max(if scale then scale.Scale else 1, 0.01)
		local at = place(
			placement,
			target.AbsolutePosition - origin,
			target.AbsoluteSize,
			size,
			8,
			layer.AbsoluteSize
		)
		if shape then
			shape.measure(
				Layer.asGui(props.MorphTarget) or target,
				layer,
				Vector2.new(at.X.Offset, at.Y.Offset),
				size
			)
		end
		pos:set(at)
	end

	Follow(scope, open, function(v)
		return v == true
	end, updatePosition)

	local root = scope:Frame({
		Name = "Popover",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = presence.Mounted,
		ZIndex = props.ZIndex or 90,
		[Children] = {
			scope:Apply(Overlay(scope, {
				Theme = theme,
				OnClick = props.OnClose,
				ZIndex = props.ZIndex or 90,
			}))({
				BackgroundTransparency = scope:Computed(function(use)
					-- Light dismiss scrim
					return 1 - math.clamp(use(openS) :: number, 0, 1) * 0.25
				end),
			}),
			if shape then shape.Instance else menu,
		},
	}) :: Frame

	Layer.mount(scope, props, root)
	Focus.trap(scope, root, open)
	Focus.escape(scope, open, Focus.closer(props))
	return root
end
