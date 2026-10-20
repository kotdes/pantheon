--!strict
--[[
	Adding a to-do, a tag or a project, and the actions of a project.

	Shared state and helpers are on `app`. Each module adds what the ones after it need.
]]
local Common = require(script.Parent.Common)
local peek = Common.peek
local Types = require(script.Parent.Types)
type Todo = Types.Todo
type Project = Types.Project
type Tag = Types.Tag

return function(app: any)
	local INBOX, currentProject, dateOffset, defaultList, projects, router, tags, tasks, toasts, updateProject =
		app.INBOX,
		app.currentProject,
		app.dateOffset,
		app.defaultList,
		app.projects,
		app.router,
		app.tags,
		app.tasks,
		app.toasts,
		app.updateProject
	----------------------------------------------------------------------------
	-- Adding things: a to-do, a tag or a project
	----------------------------------------------------------------------------

	local function addTask(title: string)
		local viewId = peek(app.view)
		local project, taskTags, due = "", {}, ""
		local kind, name = string.match(viewId, "^(%a+):(.+)$")
		if kind == "project" then
			project = name :: string
		elseif kind == "tag" then
			taskTags = { name :: string }
		elseif viewId == "today" then
			due = dateOffset(0)
		end
		if kind ~= "project" and peek(defaultList) ~= INBOX then
			project = peek(defaultList)
		end
		app.nextId += 1
		local list = table.clone(peek(tasks))
		table.insert(
			list,
			{
				id = app.nextId,
				title = title,
				notes = "",
				done = false,
				project = project,
				due = due,
				tags = taskTags,
			} :: Todo
		)
		tasks:set(list)
	end

	local function addProject(name: string)
		for _, project in peek(projects) :: { Project } do
			if string.lower(project.Id) == string.lower(name) then
				toasts.Show(`There is already a project called {project.Id}`)
				return
			end
		end
		local list = table.clone(peek(projects))
		table.insert(list, { Id = name, Icon = "folder" })
		projects:set(list)
		router:Push({ Name = "project", Params = { id = name } })
	end

	local function addTag(label: string)
		local id = string.gsub(string.lower(label), "[^%w]+", "-")
		id = string.gsub(id, "^%-+", "")
		id = string.gsub(id, "%-+$", "")
		if id == "" then
			toasts.Show("Use letters or numbers in a tag")
			return
		end
		for _, tag in peek(tags) :: { Tag } do
			if tag.Id == id then
				toasts.Show(`There is already a tag called {tag.Label}`)
				return
			end
		end
		local list = table.clone(peek(tags))
		table.insert(list, { Id = id, Label = label })
		tags:set(list)
		router:Push({ Name = "tag", Params = { id = id } })
	end

	local function completeProject(name: string)
		updateProject(name, function(todo)
			todo.done = true
		end)
		toasts.Show(`{name} completed`, nil, nil, { Icon = "check" })
	end

	local function setProjectDue(name: string, due: string)
		updateProject(name, function(todo)
			if not todo.done then
				todo.due = due
			end
		end)
	end

	local function tagProject(name: string, tagId: string)
		updateProject(name, function(todo)
			if table.find(todo.tags, tagId) == nil then
				local copy = table.clone(todo.tags)
				table.insert(copy, tagId)
				todo.tags = copy
			end
		end)
		toasts.Show(`Tag added to the to-dos in {name}`, nil, nil, { Icon = "tag" })
	end

	local function duplicateProject(name: string)
		local copyName = name .. " copy"
		local number = 1
		local function taken(candidate: string): boolean
			for _, project in peek(projects) :: { Project } do
				if project.Id == candidate then
					return true
				end
			end
			return false
		end
		while taken(copyName) do
			number += 1
			copyName = `{name} copy {number}`
		end
		local source: Project? = nil
		for _, project in peek(projects) :: { Project } do
			if project.Id == name then
				source = project
			end
		end
		local list = table.clone(peek(projects))
		table.insert(list, { Id = copyName, Icon = if source then source.Icon else "folder" })
		projects:set(list)
		local copies = table.clone(peek(tasks))
		for _, todo in peek(tasks) :: { Todo } do
			if todo.project == name then
				app.nextId += 1
				local copy = table.clone(todo)
				copy.id = app.nextId
				copy.project = copyName
				copy.done = false
				table.insert(copies, copy)
			end
		end
		tasks:set(copies)
		router:Push({ Name = "project", Params = { id = copyName } })
	end

	local function deleteProject(name: string)
		local list = {}
		for _, project in peek(projects) :: { Project } do
			if project.Id ~= name then
				table.insert(list, project)
			end
		end
		local remaining = {}
		for _, todo in peek(tasks) :: { Todo } do
			if todo.project ~= name then
				table.insert(remaining, todo)
			end
		end
		if currentProject() == name then
			router:Replace("/list/today")
		end
		projects:set(list)
		tasks:set(remaining)
		toasts.Show(`{name} deleted`, nil, nil, { Icon = "trash-2" })
	end

	app.addProject = addProject
	app.addTag = addTag
	app.addTask = addTask
	app.completeProject = completeProject
	app.deleteProject = deleteProject
	app.duplicateProject = duplicateProject
	app.setProjectDue = setProjectDue
	app.tagProject = tagProject
end
