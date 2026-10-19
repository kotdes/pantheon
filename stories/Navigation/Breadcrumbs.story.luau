--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:Breadcrumbs({
		Items = {
			{ Label = "Home" },
			{ Label = "Library" },
			{ Label = "Catalog" },
		},
	})
end)
