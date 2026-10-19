--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	local function page(text: string): Instance
		return scope:Frame({
			BackgroundTransparency = 1,
			Padding = { 10 },
			[StoryUtil.Fusion.Children] = scope:Text({ Text = text }),
		})
	end
	return scope:Frame({
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 340),
		Layout = { Kind = "List", Padding = 8 },
		[StoryUtil.Fusion.Children] = {
			scope:DockPanel({
				Tabs = {
					{ Id = "props", Title = "Properties", Content = page("Name: Part") },
					{ Id = "attr", Title = "Attributes", Content = page("No attributes") },
				},
				Size = UDim2.new(1, 0, 0, 140),
				LayoutOrder = 1,
			}),
			scope:DockPanel({
				Title = "Output",
				Collapsible = true,
				Children = { page("Ready.") },
				Size = UDim2.new(1, 0, 0, 140),
				LayoutOrder = 2,
				OnClose = function() end,
			}),
		},
	})
end)
