--!strict
--[[
	Recursive tree with collapse/expand, chevron rotation, folder/file icons.
	Child branches spring open/closed (height clip + fade + scale).
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Icon = require(script.Parent.Icon)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local function copyExpanded(map: { [string]: boolean }?): { [string]: boolean }
	local out: { [string]: boolean } = {}
	if map then
		for k, v in map do
			out[k] = v
		end
	end
	return out
end

return function(scope: Types.Scope, props: Types.TreeViewProps): Instance
	local theme = resolveTheme(props)
	local persistKey = Persist.key("TreeView", typeof(props.Expanded) == "table")
	local expanded =
		Persist.value(scope, persistKey, "expanded", copyExpanded(peek(props.Expanded)))
	local selected = Persist.value(scope, persistKey, "selected", peek(props.Selected) or "")
	Bind.link(scope, props.Selected, selected)
	Bind.link(scope, props.Expanded, expanded, {
		toInternal = copyExpanded,
		toProp = copyExpanded,
		equals = function(a: { [string]: boolean }, b: { [string]: boolean }): boolean
			for key, value in a do
				if b[key] ~= value then
					return false
				end
			end
			for key, value in b do
				if a[key] ~= value then
					return false
				end
			end
			return true
		end,
	})
	local order = 0

	local function renderNode(node: Types.TreeNode, depth: number): { Instance }
		local nodes: { Instance } = {}
		local hasChildren = node.Children ~= nil and #(node.Children :: { Types.TreeNode }) > 0
		local iconName = node.Icon or (if hasChildren then "folder" else "file")
		order += 1
		local layoutOrder = order

		local isExpanded = scope:Computed(function(use)
			return use(expanded)[node.Id] == true
		end)
		local expandS = scope:Spring(
			scope:Computed(function(use)
				return if use(isExpanded) then 1 else 0
			end),
			theme.Motion.SpringSpeed * 0.95,
			theme.Motion.SpringDamping
		)
		local isSelected = scope:Computed(function(use)
			return use(selected) == node.Id
		end)
		local ix = Interaction.bind(scope, theme, {
			StateColor = theme.Colors.OnSurface,
		})

		local chevron = if hasChildren
			then scope:New("Frame")({
				Name = "ChevronHost",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(16, 16),
				LayoutOrder = 1,
				[Children] = {
					-- Rotate a child of the host: UIListLayout ignores Rotation on its direct children.
					scope:New("Frame")({
						Name = "ChevronRot",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Size = UDim2.fromScale(1, 1),
						Rotation = scope:Computed(function(use)
							return (use(expandS) :: number) * 90
						end),
						[Children] = {
							scope:Apply(Icon(scope, {
								Theme = theme,
								Name = "chevron-right",
								IconSize = 16,
								Color = theme.Colors.OnSurfaceVariant,
							}))({
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
							}),
						},
					}),
				},
			})
			else scope:New("Frame")({
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(16, 16),
				LayoutOrder = 1,
			})

		local row = scope:TextButton(P({
			Name = "Tree_" .. node.Id,
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = scope:Computed(function(use)
				local base = if use(isSelected)
					then use(theme.Colors.PrimaryContainer)
					else use(theme.Colors.Surface)
				return Interaction.lerpColor(base, use(theme.Colors.OnSurface), ix.alpha(use), use)
			end),
			Size = UDim2.new(1, 0, 0, 32),
			LayoutOrder = layoutOrder,
			ClipsDescendants = true,
			CornerRadius = theme.Metrics.RadiusSm,
			Padding = { theme.Metrics.Space2xs, theme.Metrics.SpaceXs },
			Layout = {
				Kind = "List",
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = theme.Metrics.SpaceXs,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			[OnEvent("Activated")] = function()
				selected:set(node.Id)
				if props.OnSelect then
					props.OnSelect(node.Id)
				end
				if hasChildren then
					local map = copyExpanded(peek(expanded))
					local nextOpen = not (map[node.Id] == true)
					map[node.Id] = nextOpen
					expanded:set(map)
					if props.OnToggle then
						props.OnToggle(node.Id, nextOpen)
					end
				end
			end,
			[Children] = {
				scope:Frame({
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(depth * 16, 1),
					LayoutOrder = 0,
				}),
				chevron,
				scope:Apply(Icon(scope, {
					Theme = theme,
					Name = iconName,
					IconSize = 16,
					Color = theme.Colors.OnSurfaceVariant,
				}))({
					LayoutOrder = 2,
				}),
				scope:TextLabel({
					BackgroundTransparency = 1,
					FontFace = theme.Typography.Body.Font,
					TextSize = theme.Typography.Body.Size,
					TextColor3 = theme.Colors.OnSurface,
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = node.Label,
					AutomaticSize = Enum.AutomaticSize.XY,
					LayoutOrder = 3,
				}),
			},
		})) :: TextButton
		ix.wire(row)
		table.insert(nodes, row)

		if hasChildren then
			local childNodes: { Instance } = {}
			for _, child in node.Children :: { Types.TreeNode } do
				for _, inst in renderNode(child, depth + 1) do
					table.insert(childNodes, inst)
				end
			end
			order += 1
			local branchHeight = scope:Value(0)
			local branchInner = scope:Frame({
				Name = "BranchInner",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				[Children] = {
					scope:New("UIScale")({
						Scale = scope:Computed(function(use)
							return 0.97 + 0.03 * use(expandS)
						end),
					}),
					scope:New("UIListLayout")({
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 2),
					}),
					childNodes,
				},
			})
			local function syncBranch()
				local h = branchInner.AbsoluteSize.Y
				if h > 0 and math.abs(h - peek(branchHeight)) > 0.5 then
					branchHeight:set(h)
				end
			end
			table.insert(
				scope,
				branchInner:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncBranch)
			)
			task.defer(syncBranch)

			table.insert(
				nodes,
				scope:Frame({
					Name = "Children_" .. node.Id,
					BackgroundTransparency = 1,
					Size = scope:Computed(function(use)
						return UDim2.new(
							1,
							0,
							0,
							(use(expandS) :: number) * (use(branchHeight) :: number)
						)
					end),
					Visible = scope:Computed(function(use)
						return use(expandS) > 0.01
					end),
					ClipsDescendants = true,
					LayoutOrder = order,
					[Children] = { branchInner },
				})
			)
		end

		return nodes
	end

	local all: { Instance } = {}
	for _, node in props.Nodes do
		for _, inst in renderNode(node, 0) do
			table.insert(all, inst)
		end
	end

	return scope:Frame({
		Name = "TreeView",
		BackgroundTransparency = 1,
		Size = props.Size or UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		Visible = props.Visible,
		ZIndex = props.ZIndex,
		Layout = {
			Kind = "List",
			Padding = 2,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = all,
	}) :: Frame
end
