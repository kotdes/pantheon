--!strict
--[[
	The to-do list of a page.

	Shared state and helpers are on `app`. Each module adds what the ones after it need.
]]
local Common = require(script.Parent.Common)
local Children, peek = Common.Children, Common.peek
local Types = require(script.Parent.Types)
type Todo = Types.Todo

return function(app: any)
	local dueLabel, editingId, editorOpen, openEditor, setDone, showCompleted, theme, visibleTodos =
		app.dueLabel,
		app.editingId,
		app.editorOpen,
		app.openEditor,
		app.setDone,
		app.showCompleted,
		app.theme,
		app.visibleTodos
	----------------------------------------------------------------------------
	-- To-do list
	----------------------------------------------------------------------------

	app.buildList = function(s: any, context: any, viewId: string): Instance
		-- The search text, from the route's query. It follows the route in place.
		local query = s:Computed(function(use: any)
			return (use(context.Query) :: any).q or ""
		end)
		-- The Logbook is all completed items. Every other list shows the open ones, and the
		-- completed ones apart, under a button.
		local isLogbook = viewId == "logbook"
		-- The to-do being edited is in the card, so it leaves the list while the card is open.
		local function withoutEdited(use: any, list: { Todo }): { Todo }
			local editing = use(editingId)
			if not use(editorOpen) or editing == 0 then
				return list
			end
			local kept: { Todo } = {}
			for _, todo in list do
				if todo.id ~= editing then
					table.insert(kept, todo)
				end
			end
			return kept
		end
		-- Everything the page holds, and then what it lists. The two differ by the to-do in the
		-- card, so a page whose only to-do is being edited is not empty.
		local allOpen = s:Computed(function(use: any)
			return visibleTodos(use, viewId, use(query), isLogbook)
		end)
		local allLogged = s:Computed(function(use: any)
			if isLogbook or viewId == "search" then
				return {}
			end
			return visibleTodos(use, viewId, "", true)
		end)
		local visible = s:Computed(function(use: any)
			return withoutEdited(use, use(allOpen))
		end)
		local logged = s:Computed(function(use: any)
			return withoutEdited(use, use(allLogged))
		end)

		local function makeRow(_use: any, rowScope: any, todo: Todo)
			local bits: { string } = {}
			if todo.project ~= "" then
				table.insert(bits, todo.project)
			end
			local label = dueLabel(todo.due)
			if label ~= "" then
				table.insert(bits, label)
			end
			for _, tagId in todo.tags do
				table.insert(bits, "#" .. tagId)
			end
			-- The grey details go when the row is too narrow, so the title keeps its room.
			local narrow = rowScope:Value(false)
			local row = rowScope:ListItem({
				Title = todo.title,
				Trailing = if #bits > 0
					then rowScope:Text({
						Text = string.lower(table.concat(bits, ", ")),
						Variant = "Caption",
						Color = theme.Colors.OnSurfaceVariant,
						Visible = rowScope:Computed(function(use: any)
							return not use(narrow)
						end),
					})
					else nil,
				LayoutOrder = todo.order or 0,
				Leading = rowScope:Checkbox({
					Checked = todo.done,
					OnChanged = function(on: boolean)
						-- Wait for the check mark to finish before the row moves.
						task.delay(if on then 0.35 else 0, function()
							setDone(todo.id, on)
						end)
					end,
				}),
				OnClick = function()
					openEditor(todo)
				end,
			})
			table.insert(
				rowScope,
				row:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
					narrow:set(row.AbsoluteSize.X < 420)
				end)
			)
			return row
		end
		local rows = s:ForValues(visible, makeRow)
		local loggedRows = s:ForValues(logged, makeRow)

		local isEmpty = s:Computed(function(use: any)
			return #use(allOpen) == 0 and #use(allLogged) == 0
		end)
		local hasLogged = s:Computed(function(use: any)
			return #use(allLogged) > 0
		end)

		local function stack(name: string, order: number, kids: any, visibleState: any): Instance
			return s:Frame({
				Name = name,
				BackgroundTransparency = 1,
				LayoutOrder = order,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Visible = visibleState,
				Layout = {
					Kind = "List",
					Padding = 2,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = kids,
			})
		end

		-- The page scrolls as a whole, with the title and the card, so this is a plain stack that
		-- grows to its content.
		return s:Frame({
			Name = "List",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Layout = {
				Kind = "List",
				Padding = 2,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			[Children] = {
				stack("Todos", 1, rows, true),
				s:Frame({
					Name = "Empty",
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Visible = isEmpty,
					[Children] = {
						s:EmptyState({
							Title = "Nothing here",
							Subtitle = "Add something new with the field below.",
						}),
					},
				}),
				-- Space between the to-dos and the button.
				s:Frame({
					Name = "Gap",
					BackgroundTransparency = 1,
					LayoutOrder = 3,
					Size = UDim2.new(1, 0, 0, theme.Metrics.SpaceMd),
					Visible = hasLogged,
				}),
				-- The button is as wide as the list. The completed items are under it.
				s:Button({
					Text = s:Computed(function(use: any)
						if use(showCompleted) then
							return "Hide logged items"
						end
						local count = #use(logged)
						return if count == 1
							then "Show 1 logged item"
							else `Show {count} logged items`
					end),
					Variant = "Text",
					LayoutOrder = 4,
					Size = UDim2.new(1, 0, 0, 40),
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					Visible = hasLogged,
					OnClick = function()
						showCompleted:set(not peek(showCompleted))
					end,
				}),
				stack(
					"Logged",
					5,
					loggedRows,
					s:Computed(function(use: any)
						return use(showCompleted) and #use(logged) > 0
					end)
				),
			},
		})
	end
end
