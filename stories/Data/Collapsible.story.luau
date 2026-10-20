--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:Collapsible({
		Title = "Advanced",
		Children = {
			scope:Text({ Text = "Hidden until expanded.", Variant = "Body" }),
		},
	})
end)
