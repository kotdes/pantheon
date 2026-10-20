--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

-- A made-up tree. Filter, click, Shift and Ctrl click, F2 to rename, arrow keys, drag to reparent.
return StoryUtil.story(function(scope)
	local Children = StoryUtil.Fusion.Children
	local root = Instance.new("Model")
	root.Name = "Workspace"
	local function make(class: string, name: string, parent: Instance): Instance
		local instance = Instance.new(class)
		instance.Name = name
		instance.Parent = parent
		return instance
	end
	local world = make("Folder", "World", root)
	for index = 1, 6 do
		make("Part", `Tile{index}`, world)
	end
	local npc = make("Model", "Guide", root)
	make("Humanoid", "Humanoid", npc)
	make("Part", "Head", npc)
	make("Script", "Brain", npc)
	make("Sound", "Greeting", npc)
	table.insert(scope, function()
		root:Destroy()
	end)

	local filter = scope:Value("")
	local picked = scope:Value({} :: { Instance })
	return scope:Frame({
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 360),
		Layout = { Kind = "List", Padding = 8 },
		[Children] = {
			scope:TextField({
				Placeholder = "Filter",
				Text = filter,
				LeadingIcon = "search",
				LayoutOrder = 1,
			}),
			scope:Frame({
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, -48),
				LayoutOrder = 2,
				[Children] = scope:Explorer({
					Roots = { root },
					Filter = filter,
					Selected = picked,
					AllowReparent = true,
				}),
			}),
		},
	})
end)
