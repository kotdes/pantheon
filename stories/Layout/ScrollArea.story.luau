--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, _ctx)
	local status = scope:Value("Pull down from the top")
	local kids = {
		scope:Text({
			Text = status,
			Variant = "Label",
			LayoutOrder = 0,
		}),
	}
	for i = 1, 40 do
		table.insert(
			kids,
			scope:Text({
				Text = "Scroll row " .. i,
				Variant = "Body",
				LayoutOrder = i,
			})
		)
	end
	local scroll = scope:ScrollArea({
		Children = kids,
		Smooth = true,
		Inertia = true,
		AutoCanvas = true,
		Overscroll = true,
		ScrollBarRail = true,
		PullHint = "Pull to continue",
		ReleaseHint = "Release to continue",
		CancelHint = "Pull back to cancel",
		OnRefresh = function()
			status:set("Continued ✓")
			task.delay(1.2, function()
				status:set("Pull down from the top")
			end)
		end,
		OnPullCancel = function()
			status:set("Cancelled")
			task.delay(0.9, function()
				status:set("Pull down from the top")
			end)
		end,
	})
	return StoryUtil.panel(
		scope,
		280,
		scope:Hydrate(scroll)({
			Size = UDim2.fromScale(1, 1),
		})
	)
end)
