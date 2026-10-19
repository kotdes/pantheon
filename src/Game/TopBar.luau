--!strict
--[[
	Round icon buttons docked to the top left and right. See docs/Game/TopBar.md.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Style = require(script.Parent.Style)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

export type TopBarItem = {
	Id: string,
	Image: string?,
	Text: string?,
	Badge: any?, -- number | State<number>
	Active: any?, -- boolean | State<boolean>
	OnClick: (() -> ())?,
}

export type TopBarProps = {
	Left: { TopBarItem }?,
	Right: { TopBarItem }?,
	Center: Instance?,
	Height: number?,
	LayoutOrder: number?,
}

local MARGIN = 12
local GAP = 8

return function(scope: any, props: TopBarProps): Instance
	local height = props.Height or 44

	local function button(item: TopBarItem, order: number): Instance
		local hovered = scope:Value(false)
		local pressed = scope:Value(false)
		local isActive = scope:Computed(function(use)
			return use(item.Active :: any) == true
		end)
		local fade = scope:Spring(
			scope:Computed(function(use)
				return if use(isActive)
					then 0.05
					elseif use(hovered) then 0.18
					else Style.PanelTransparency
			end),
			30,
			1
		)
		local press = scope:Spring(
			scope:Computed(function(use)
				return if use(pressed) then 0.92 else 1
			end),
			40,
			0.8
		)
		local badge = scope:Computed(function(use)
			local n = use(item.Badge :: any)
			return if typeof(n) == "number" then n else 0
		end)

		return scope:New("TextButton")({
			Name = item.Id,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = order,
			Size = UDim2.fromOffset(height, height),
			BackgroundColor3 = Style.Panel,
			BackgroundTransparency = fade,
			BorderSizePixel = 0,
			[OnEvent("Activated")] = function()
				if item.OnClick then
					item.OnClick()
				end
			end,
			[OnEvent("MouseEnter")] = function()
				hovered:set(true)
			end,
			[OnEvent("MouseLeave")] = function()
				hovered:set(false)
				pressed:set(false)
			end,
			[OnEvent("MouseButton1Down")] = function()
				pressed:set(true)
			end,
			[OnEvent("MouseButton1Up")] = function()
				pressed:set(false)
			end,
			[Children] = {
				scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }),
				scope:New("UIScale")({ Scale = press }),
				scope:New("UIStroke")({
					Color = Style.Edge,
					Transparency = Style.EdgeTransparency,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				}),
				if item.Image
					then scope:New("ImageLabel")({
						Name = "Icon",
						BackgroundTransparency = 1,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.5, 0.5),
						Image = item.Image,
						ImageColor3 = Style.Text,
					})
					else scope:New("TextLabel")({
						Name = "Label",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						FontFace = Style.FontBold,
						TextSize = 16,
						TextColor3 = Style.Text,
						Text = item.Text or "",
					}),
				scope:New("TextLabel")({
					Name = "Badge",
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, 2, 0, -2),
					Size = UDim2.fromOffset(18, 18),
					BackgroundColor3 = Color3.fromRGB(224, 67, 67),
					BorderSizePixel = 0,
					FontFace = Style.FontBold,
					TextSize = 11,
					TextColor3 = Color3.new(1, 1, 1),
					ZIndex = 2,
					Visible = scope:Computed(function(use)
						return use(badge) > 0
					end),
					Text = scope:Computed(function(use)
						return tostring(math.min(use(badge), 99))
					end),
					[Children] = { scope:New("UICorner")({ CornerRadius = UDim.new(1, 0) }) },
				}),
			} :: any,
		})
	end

	local function cluster(name: string, items: { TopBarItem }?, right: boolean): Instance
		local children: { any } = {
			scope:New("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = if right
					then Enum.HorizontalAlignment.Right
					else Enum.HorizontalAlignment.Left,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, GAP),
			}),
		}
		local list: { TopBarItem } = items or {}
		for order, item in list do
			table.insert(children, button(item, order))
		end
		return scope:New("Frame")({
			Name = name,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(if right then 1 else 0, 0),
			Position = UDim2.new(if right then 1 else 0, if right then -MARGIN else MARGIN, 0, 0),
			Size = UDim2.new(0.4, 0, 1, 0),
			[Children] = children,
		})
	end

	return scope:New("Frame")({
		Name = "TopBar",
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, MARGIN),
		Size = UDim2.new(1, 0, 0, height),
		LayoutOrder = props.LayoutOrder or 0,
		[Children] = {
			cluster("Left", props.Left, false),
			if props.Center
				then scope:New("Frame")({
					Name = "Center",
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.new(0.2, 0, 1, 0),
					[Children] = { props.Center },
				})
				else nil,
			cluster("Right", props.Right, true),
		},
	})
end
