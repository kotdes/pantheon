--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	return scope:TreeView({
		Nodes = {
			{
				Id = "src",
				Label = "src",
				Icon = "folder",
				Children = {
					{ Id = "btn", Label = "Button.luau", Icon = "file" },
					{
						Id = "theme",
						Label = "Theme",
						Icon = "folder",
						Children = {
							{ Id = "init", Label = "init.luau", Icon = "file" },
						},
					},
				},
			},
		},
	})
end)
