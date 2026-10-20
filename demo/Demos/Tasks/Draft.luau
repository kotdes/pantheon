--!strict
--[[
	The to-do card's state, and saving, deleting and completing a to-do.

	Shared state and helpers are on `app`. Each module adds what the ones after it need.
]]
local Common = require(script.Parent.Common)
local peek = Common.peek
local Types = require(script.Parent.Types)
type Todo = Types.Todo

return function(app: any)
	local INBOX, currentProject, dateOffset, defaultList, removeTodo, scope, tasks, toasts, trim, undoToasts, updateTodo =
		app.INBOX,
		app.currentProject,
		app.dateOffset,
		app.defaultList,
		app.removeTodo,
		app.scope,
		app.tasks,
		app.toasts,
		app.trim,
		app.undoToasts,
		app.updateTodo
	----------------------------------------------------------------------------
	-- Card state
	----------------------------------------------------------------------------

	local editorOpen = scope:Value(false)
	local editingId = scope:Value(0)
	local draftTitle = scope:Value("")
	local draftNotes = scope:Value("")
	local draftProject = scope:Value(INBOX)
	local draftDue = scope:Value("")
	-- The day the date picker shows. It follows the due date when there is one.
	local draftDate = scope:Value(dateOffset(0))
	local draftTags = scope:Value({} :: { string })

	-- Popovers of the card and the project menu.
	local whenOpen = scope:Value(false)
	local tagsOpen = scope:Value(false)
	local moveOpen = scope:Value(false)
	local projectMenuOpen = scope:Value(false)
	local projectMenuPage = scope:Value("root")

	local confirmOpen = scope:Value(false)

	-- What the card held when it opened, to tell whether anything has been entered since.
	local function tagsKey(list: { string }): string
		local copy = table.clone(list)
		table.sort(copy)
		return table.concat(copy, ",")
	end
	local original = { title = "", notes = "", project = INBOX, due = "", tags = "" }
	local function snapshotDraft()
		original = {
			title = peek(draftTitle),
			notes = peek(draftNotes),
			project = peek(draftProject),
			due = peek(draftDue),
			tags = tagsKey(peek(draftTags)),
		}
	end
	local function isDirty(): boolean
		return peek(draftTitle) ~= original.title
			or peek(draftNotes) ~= original.notes
			or peek(draftProject) ~= original.project
			or peek(draftDue) ~= original.due
			or tagsKey(peek(draftTags)) ~= original.tags
	end

	local function openEditor(todo: Todo?)
		if todo then
			editingId:set(todo.id)
			draftTitle:set(todo.title)
			draftNotes:set(todo.notes)
			draftProject:set(if todo.project == "" then INBOX else todo.project)
			draftTags:set(table.clone(todo.tags))
			draftDue:set(todo.due)
			draftDate:set(if todo.due ~= "" then todo.due else dateOffset(0))
		else
			editingId:set(0)
			draftTitle:set("")
			draftNotes:set("")
			-- A new to-do goes in the project you are looking at, else the default list.
			draftProject:set(currentProject() or peek(defaultList))
			draftTags:set({})
			draftDue:set(if peek(app.view) == "today" then dateOffset(0) else "")
			draftDate:set(dateOffset(0))
		end
		snapshotDraft()
		editorOpen:set(true)
	end

	local function saveDraft()
		local title = trim(peek(draftTitle))
		if title == "" then
			toasts.Show("Add a title first", nil, nil, { Icon = "circle-alert" })
			return
		end
		local project = peek(draftProject)
		local id = peek(editingId)
		local function apply(todo: Todo)
			todo.title = title
			todo.notes = peek(draftNotes)
			todo.project = if project == INBOX then "" else project
			todo.due = peek(draftDue)
			todo.tags = table.clone(peek(draftTags))
		end
		if id == 0 then
			app.nextId += 1
			local todo: Todo = {
				id = app.nextId,
				title = "",
				notes = "",
				done = false,
				project = "",
				due = "",
				tags = {},
			}
			apply(todo)
			local list = table.clone(peek(tasks))
			table.insert(list, todo)
			tasks:set(list)
		else
			updateTodo(id, apply)
		end
		editorOpen:set(false)
	end

	local function deleteDraft()
		removeTodo(peek(editingId))
		confirmOpen:set(false)
		editorOpen:set(false)
		toasts.Show("To-do deleted", nil, nil, { Icon = "trash-2" })
	end

	local function setDone(id: number, done: boolean)
		updateTodo(id, function(todo)
			todo.done = done
		end)
		if done and peek(undoToasts) then
			toasts.Show("To-do completed", "Undo", function()
				setDone(id, false)
			end, { Icon = "check" })
		end
	end

	app.confirmOpen = confirmOpen
	app.deleteDraft = deleteDraft
	app.draftDate = draftDate
	app.draftDue = draftDue
	app.draftNotes = draftNotes
	app.draftProject = draftProject
	app.draftTags = draftTags
	app.draftTitle = draftTitle
	app.editingId = editingId
	app.editorOpen = editorOpen
	app.isDirty = isDirty
	app.moveOpen = moveOpen
	app.openEditor = openEditor
	app.projectMenuOpen = projectMenuOpen
	app.projectMenuPage = projectMenuPage
	app.saveDraft = saveDraft
	app.setDone = setDone
	app.tagsOpen = tagsOpen
	app.whenOpen = whenOpen
end
