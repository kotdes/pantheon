--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, _ctx)
	return scope:Form({
		Title = "Profile",
		Children = {
			scope:TextField({ Label = "Name", Placeholder = "Type…", LayoutOrder = 1 }),
			scope:Checkbox({ Label = "Public profile", LayoutOrder = 2 }),
			scope:Button({ Text = "Save", Variant = "Primary", LayoutOrder = 3 }),
		},
	})
end)
