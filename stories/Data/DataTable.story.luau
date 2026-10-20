--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope)
	local rows = {}
	for i = 1, 50 do
		table.insert(rows, {
			id = i,
			name = "Row " .. i,
			role = if i % 2 == 0 then "Mod" else "User",
		})
	end
	local tableRows = scope:Value(rows)
	return StoryUtil.panel(
		scope,
		260,
		scope:DataTable({
			Columns = {
				{ Id = "id", Title = "Id", Width = 60 },
				{ Id = "name", Title = "Name", Width = 140 },
				{ Id = "role", Title = "Role", Width = 100 },
			},
			Rows = tableRows,
			Size = UDim2.fromScale(1, 1),
		})
	)
end)
