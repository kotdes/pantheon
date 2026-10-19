--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	local function pane(text: string): Instance
		return scope:Frame({
			BackgroundTransparency = 1,
			[StoryUtil.Fusion.Children] = scope:Text({ Text = text, Variant = "Label" }),
			Padding = { 8 },
		})
	end
	local vertical = scope:SplitPane({
		Orientation = "Vertical",
		Panes = { pane("Output"), pane("Properties") },
		Ratios = { 0.6, 0.4 },
	})
	local split = scope:SplitPane({
		Panes = { pane("Explorer"), vertical, pane("Preview") },
		Ratios = { 1, 2, 1 },
		Size = UDim2.fromScale(1, 1),
	})
	return StoryUtil.panel(scope, 320, split)
end)
