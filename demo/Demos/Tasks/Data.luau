--!strict
--[[
	State and the pure helpers: projects, tags, to-dos, settings, and what each list holds.

	Shared state and helpers are on `app`. Each module adds what the ones after it need.
]]
local Common = require(script.Parent.Common)
local peek = Common.peek
local Types = require(script.Parent.Types)
type Todo = Types.Todo
type Project = Types.Project
type Tag = Types.Tag

return function(app: any)
	local rootScope = app.rootScope
	local INBOX = "inbox" -- value of the project field in the card
	local SMART_LISTS = {
		{ Id = "inbox", Title = "Inbox", Icon = "inbox" },
		{ Id = "today", Title = "Today", Icon = "star" },
		{ Id = "upcoming", Title = "Upcoming", Icon = "calendar" },
		{ Id = "anytime", Title = "Anytime", Icon = "layers" },
		{ Id = "logbook", Title = "Logbook", Icon = "circle-check" },
	}

	-- Projects and tags can be added, so they are state. The sidebar follows them.
	local projects = rootScope:Value({
		{ Id = "Work", Icon = "briefcase" },
		{ Id = "Home", Icon = "home" },
		{ Id = "Trips", Icon = "plane" },
	} :: { Project })
	local tags = rootScope:Value({
		{ Id = "errands", Label = "Errands" },
		{ Id = "calls", Label = "Calls" },
		{ Id = "deep-work", Label = "Deep work" },
	} :: { Tag })

	-- The colour of each list, as in Things.
	local ACCENTS: { [string]: Color3 } = {
		inbox = Color3.fromHex("#3B9BF0"),
		today = Color3.fromHex("#F5C518"),
		upcoming = Color3.fromHex("#F0436E"),
		anytime = Color3.fromHex("#3FB8AF"),
		logbook = Color3.fromHex("#5CC264"),
		project = Color3.fromHex("#7B8CDE"),
		tag = Color3.fromHex("#9A9AA3"),
	}
	local function accentFor(viewId: string): Color3
		local kind = string.match(viewId, "^(%a+):")
		return ACCENTS[kind or viewId] or ACCENTS.tag
	end
	local function iconFor(viewId: string): string
		if viewId == "search" then
			return "search"
		end
		for _, list in SMART_LISTS do
			if list.Id == viewId then
				return list.Icon
			end
		end
		local kind, name = string.match(viewId, "^(%a+):(.+)$")
		if kind == "project" then
			for _, project in peek(projects) :: { Project } do
				if project.Id == name then
					return project.Icon
				end
			end
			return "folder"
		end
		return "tag"
	end
	local function titleFor(viewId: string, tagList: { Tag }): string
		if viewId == "search" then
			return "Search"
		end
		for _, list in SMART_LISTS do
			if list.Id == viewId then
				return list.Title
			end
		end
		local kind, name = string.match(viewId, "^(%a+):(.+)$")
		if kind == "project" then
			return name :: string
		elseif kind == "tag" then
			for _, tag in tagList do
				if tag.Id == name then
					return "#" .. tag.Label
				end
			end
			return "#" .. (name :: string)
		end
		return "Tasks"
	end

	local function dateOffset(days: number): string
		return os.date("!%Y-%m-%d", os.time() + days * 86400) :: string
	end

	local function dueLabel(due: string): string
		if due == "" then
			return ""
		end
		local today = dateOffset(0)
		if due == today then
			return "Today"
		elseif due == dateOffset(1) then
			return "Tomorrow"
		elseif due < today then
			return "Overdue"
		end
		local year, month, day = string.match(due, "^(%d+)-(%d+)-(%d+)$")
		if year == nil then
			return due
		end
		local stamp = os.time({
			year = tonumber(year) :: number,
			month = tonumber(month) :: number,
			day = tonumber(day) :: number,
			hour = 12,
		})
		return os.date("!%d %b", stamp) :: string
	end

	local function trim(text: string): string
		return string.match(text, "^%s*(.-)%s*$") :: string
	end

	app.nextId = 100
	local tasks = rootScope:Value({
		{
			id = 1,
			title = "Book the dentist",
			notes = "",
			done = false,
			project = "",
			due = "",
			tags = { "calls" },
		},
		{
			id = 2,
			title = "Send the quarterly report",
			notes = "Include the new revenue chart.",
			done = false,
			project = "Work",
			due = dateOffset(0),
			tags = {},
		},
		{
			id = 3,
			title = "Review the pull request",
			notes = "",
			done = false,
			project = "Work",
			due = dateOffset(-1),
			tags = { "deep-work" },
		},
		{
			id = 4,
			title = "Plan the design review",
			notes = "Agree the agenda with the team.",
			done = false,
			project = "Work",
			due = dateOffset(3),
			tags = { "deep-work" },
		},
		{
			id = 5,
			title = "Buy milk and bread",
			notes = "",
			done = false,
			project = "Home",
			due = dateOffset(0),
			tags = { "errands" },
		},
		{
			id = 6,
			title = "Fix the bike light",
			notes = "",
			done = false,
			project = "Home",
			due = "",
			tags = { "errands" },
		},
		{
			id = 7,
			title = "Book flights to Lisbon",
			notes = "Check the baggage allowance.",
			done = false,
			project = "Trips",
			due = dateOffset(9),
			tags = {},
		},
		{
			id = 8,
			title = "Renew passport",
			notes = "",
			done = true,
			project = "Trips",
			due = "",
			tags = { "errands" },
		},
	} :: { Todo })

	--------------------------------------------------------------------------------
	-- Settings and view state
	--------------------------------------------------------------------------------

	-- The list being shown, as an id such as "today" or "project:Work". The router decides it,
	-- and it is set once the router exists.
	local showCompleted = rootScope:Value(false)
	local undoToasts = rootScope:Value(true)
	local confirmDelete = rootScope:Value(true)
	local sortBy = rootScope:Value("manual")
	local defaultList = rootScope:Value(INBOX)

	local windowOpen = rootScope:Value(true)
	local drawerOpen = rootScope:Value(false)
	local drawerPage = rootScope:Value("root")

	-- Where each list lives in the router, and the list a route stands for.
	local function targetFor(viewId: string): any
		local kind, name = string.match(viewId, "^(%a+):(.+)$")
		if kind == "project" then
			return { Name = "project", Params = { id = name } }
		elseif kind == "tag" then
			return { Name = "tag", Params = { id = name } }
		end
		return { Name = "list", Params = { id = viewId } }
	end

	local function viewIdOf(route: any): string
		local id = route.Params.id or "today"
		if route.Name == "project" then
			return "project:" .. id
		elseif route.Name == "tag" then
			return "tag:" .. id
		elseif route.Name == "search" then
			return "search"
		end
		return id
	end

	local function belongs(todo: Todo, viewId: string, query: string?): boolean
		local today = dateOffset(0)
		if viewId == "search" then
			local text = string.lower(query or "")
			return text ~= ""
				and (
					string.find(string.lower(todo.title), text, 1, true) ~= nil
					or string.find(string.lower(todo.notes), text, 1, true) ~= nil
				)
		elseif viewId == "logbook" then
			return todo.done
		elseif viewId == "inbox" then
			return todo.project == ""
		elseif viewId == "today" then
			return todo.due ~= "" and todo.due <= today
		elseif viewId == "upcoming" then
			return todo.due > today
		elseif viewId == "anytime" then
			return true
		end
		local kind, name = string.match(viewId, "^(%a+):(.+)$")
		if kind == "project" then
			return todo.project == name
		elseif kind == "tag" then
			return table.find(todo.tags, name :: string) ~= nil
		end
		return false
	end

	local function countOf(list: { Todo }, viewId: string): number
		local count = 0
		for _, todo in list do
			if belongs(todo, viewId) and (not todo.done or viewId == "logbook") then
				count += 1
			end
		end
		return count
	end

	--- The to-dos of a list, filtered and sorted by the current settings. `done` picks the
	--- completed ones, which the list shows apart from the others.
	local function visibleTodos(use: any, viewId: string, query: string, done: boolean): { Todo }
		local order = use(sortBy)
		local out: { Todo } = {}
		for _, todo in use(tasks) do
			if belongs(todo, viewId, query) and todo.done == done then
				table.insert(out, table.clone(todo))
			end
		end
		table.sort(out, function(a, b)
			if order == "due" and a.due ~= b.due then
				if a.due == "" or b.due == "" then
					return a.due ~= ""
				end
				return a.due < b.due
			elseif order == "title" and a.title ~= b.title then
				return string.lower(a.title) < string.lower(b.title)
			end
			return a.id < b.id
		end)
		for index, todo in out do
			todo.order = index
		end
		return out
	end

	local function updateTodo(id: number, change: (Todo) -> ())
		local list = table.clone(peek(tasks) :: { Todo })
		for index, todo in list do
			if todo.id == id then
				local copy = table.clone(todo)
				change(copy)
				list[index] = copy
				break
			end
		end
		tasks:set(list)
	end

	local function removeTodo(id: number)
		local list = {}
		for _, todo in peek(tasks) do
			if todo.id ~= id then
				table.insert(list, todo)
			end
		end
		tasks:set(list)
	end

	--- Changes every to-do of a project.
	local function updateProject(name: string, change: (Todo) -> ())
		local list = table.clone(peek(tasks) :: { Todo })
		for index, todo in list do
			if todo.project == name then
				local copy = table.clone(todo)
				change(copy)
				list[index] = copy
			end
		end
		tasks:set(list)
	end

	app.INBOX = INBOX
	app.SMART_LISTS = SMART_LISTS
	app.accentFor = accentFor
	app.confirmDelete = confirmDelete
	app.countOf = countOf
	app.dateOffset = dateOffset
	app.defaultList = defaultList
	app.drawerOpen = drawerOpen
	app.drawerPage = drawerPage
	app.dueLabel = dueLabel
	app.iconFor = iconFor
	app.projects = projects
	app.removeTodo = removeTodo
	app.showCompleted = showCompleted
	app.sortBy = sortBy
	app.tags = tags
	app.targetFor = targetFor
	app.tasks = tasks
	app.titleFor = titleFor
	app.trim = trim
	app.undoToasts = undoToasts
	app.updateProject = updateProject
	app.updateTodo = updateTodo
	app.viewIdOf = viewIdOf
	app.visibleTodos = visibleTodos
	app.windowOpen = windowOpen
end
