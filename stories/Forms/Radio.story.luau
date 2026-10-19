--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	local checked = scope:Value(true)
	return scope:Radio({
		Label = "Option",
		Checked = checked,
		OnActivated = function()
			checked:set(not StoryUtil.Fusion.peek(checked))
		end,
	})
end)
