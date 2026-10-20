--!strict
--[[
	The sidebar and the popovers. They list projects and tags, so they are built again when either changes.

	Shared state and helpers are on `app`. Each module adds what the ones after it need.
]]
local Common = require(script.Parent.Common)
local Pantheon, Fusion, Children, peek =
	Common.Pantheon, Common.Fusion, Common.Children, Common.peek
local Types = require(script.Parent.Types)
type Project = Types.Project
type Tag = Types.Tag

return function(app: any)
	local INBOX, SMART_LISTS, accentFor, completeProject, confirmDelete, countOf, currentProject, dateOffset, defaultList, deleteProject, docked, draftDate, draftDue, draftProject, draftTags, drawerOpen, drawerPage, duplicateProject, ellipsis, goTo, iconFor, mode, moveButton, moveOpen, overlayLayer, projectMenuOpen, projectMenuPage, projects, router, scope, setProjectDue, showCompleted, sortBy, tagProject, tags, tagsButton, tagsOpen, targetFor, tasks, theme, themeSource, undoToasts, whenButton, whenOpen =
		app.INBOX,
		app.SMART_LISTS,
		app.accentFor,
		app.completeProject,
		app.confirmDelete,
		app.countOf,
		app.currentProject,
		app.dateOffset,
		app.defaultList,
		app.deleteProject,
		app.docked,
		app.draftDate,
		app.draftDue,
		app.draftProject,
		app.draftTags,
		app.drawerOpen,
		app.drawerPage,
		app.duplicateProject,
		app.ellipsis,
		app.goTo,
		app.iconFor,
		app.mode,
		app.moveButton,
		app.moveOpen,
		app.overlayLayer,
		app.projectMenuOpen,
		app.projectMenuPage,
		app.projects,
		app.router,
		app.scope,
		app.setProjectDue,
		app.showCompleted,
		app.sortBy,
		app.tagProject,
		app.tags,
		app.tagsButton,
		app.tagsOpen,
		app.targetFor,
		app.tasks,
		app.theme,
		app.themeSource,
		app.undoToasts,
		app.whenButton,
		app.whenOpen
	local overlayScope: any = nil
	----------------------------------------------------------------------------
	-- Sidebar and popovers. They list projects and tags, so they are built again when
	-- either changes.
	----------------------------------------------------------------------------

	local function buildOverlays()
		if overlayScope then
			Fusion.doCleanup(overlayScope)
		end
		local ds = Fusion.innerScope(scope) :: any
		overlayScope = ds

		Pantheon.Theme.Provide(themeSource, function()
			local projectList = peek(projects) :: { Project }
			local tagList = peek(tags) :: { Tag }

			local function isCurrent(viewId: string): any
				return router:Active(targetFor(viewId), true)
			end

			-- A count at the end of a sidebar row. It only shows on the current list.
			local function countBadge(viewId: string): Instance
				return ds:Text({
					Text = ds:Computed(function(use: any)
						local count = countOf(use(tasks), viewId)
						return if use(app.view) == viewId and count > 0 then tostring(count) else ""
					end),
					Variant = "Label",
					Padding = {
						Right = 4,
					},
					Color = theme.Colors.OnPrimaryContainer,
				})
			end

			local function listIcon(viewId: string): Instance
				return ds:Icon({
					Name = iconFor(viewId),
					IconSize = 20,
					Color = accentFor(viewId),
				})
			end

			local function listRow(title: string, viewId: string): any
				return {
					Text = title,
					Leading = listIcon(viewId),
					Trailing = countBadge(viewId),
					Selected = isCurrent(viewId),
					OnClick = function()
						goTo(viewId)
					end,
				}
			end

			local smartRows: { any } = {}
			for _, list in SMART_LISTS do
				table.insert(smartRows, listRow(list.Title, list.Id))
			end
			local projectRows: { any } = {}
			for _, project in projectList do
				table.insert(projectRows, listRow(project.Id, "project:" .. project.Id))
			end
			local tagRows: { Instance } = {}
			for index, tag in tagList do
				table.insert(
					tagRows,
					ds:MenuButton({
						Layer = overlayLayer,
						Text = tag.Label,
						Leading = listIcon("tag:" .. tag.Id),
						Trailing = countBadge("tag:" .. tag.Id),
						Selected = isCurrent("tag:" .. tag.Id),
						LayoutOrder = index,
						OnClick = function()
							goTo("tag:" .. tag.Id)
						end,
					})
				)
			end

			local function toggleRow(
				text: string,
				icon: string,
				state: any,
				order: number
			): Instance
				return ds:MenuButton({
					Layer = overlayLayer,
					Text = text,
					Leading = icon,
					Trailing = ds:Switch({ Checked = state }),
					LayoutOrder = order,
				})
			end

			local function pageRow(
				text: string,
				icon: string,
				page: string,
				order: number
			): Instance
				return ds:MenuButton({
					Layer = overlayLayer,
					Text = text,
					Leading = icon,
					Trailing = "chevron-right",
					Page = page,
					LayoutOrder = order,
				})
			end

			local newTaskOptions = { { Label = "Inbox", Value = INBOX } }
			for _, project in projectList do
				table.insert(newTaskOptions, { Label = project.Id, Value = project.Id })
			end

			ds:NavigationDrawer({
				Layer = overlayLayer,
				Open = drawerOpen,
				Title = "Pantheon Tasks",
				Subtitle = "Do something already",
				AvatarInitials = "TK",
				Inset = 4,
				-- From this window width the sidebar stays open beside the list.
				DockAt = 640,
				OnDockChanged = function(isDocked: boolean)
					docked:set(isDocked)
				end,
				-- Concentric with the window: its radius less the inset.
				CornerRadius = theme.Metrics.RadiusPanel - 4,
				RootPage = "root",
				Page = drawerPage,
				OnChanged = function(id: string)
					drawerPage:set(id)
				end,
				OnClose = function()
					drawerOpen:set(false)
					drawerPage:set("root")
				end,
				Sections = {
					{ Items = { smartRows[1] } },
					{ Items = { smartRows[2], smartRows[3], smartRows[4] } },
					{ Items = { smartRows[5] } },
					{ Items = projectRows },
					{
						Items = {
							{
								Text = "Tags",
								Leading = "tags",
								Trailing = "chevron-right",
								Page = "tags",
							},
							{
								Text = "Settings",
								Leading = "settings",
								Trailing = "chevron-right",
								Page = "settings",
							},
						},
					},
				},
				Children = {
					ds:MenuPage({ Id = "tags", Title = "Tags", Children = tagRows }),
					ds:MenuPage({
						Id = "settings",
						Title = "Settings",
						Children = {
							toggleRow("Show completed", "list-checks", showCompleted, 1),
							toggleRow("Undo toasts", "undo-2", undoToasts, 2),
							toggleRow("Confirm before deleting", "trash-2", confirmDelete, 3),
							pageRow("Sort by", "arrow-up-down", "sort", 4),
							pageRow("New to-dos go in", "inbox", "newlist", 5),
							pageRow("Appearance", "moon", "appearance", 6),
						},
					}),
					ds:MenuPage({
						Id = "sort",
						Title = "Sort by",
						Children = {
							ds:RadioGroup({
								Value = sortBy,
								Options = {
									{ Label = "Manual", Value = "manual" },
									{ Label = "Due date", Value = "due" },
									{ Label = "Title", Value = "title" },
								},
							}),
						},
					}),
					ds:MenuPage({
						Id = "newlist",
						Title = "New to-dos go in",
						Children = {
							ds:RadioGroup({ Value = defaultList, Options = newTaskOptions }),
						},
					}),
					ds:MenuPage({
						Id = "appearance",
						Title = "Appearance",
						Children = {
							ds:RadioGroup({
								Value = mode,
								Options = {
									{ Label = "Light", Value = "Light" },
									{ Label = "Dark", Value = "Dark" },
								},
							}),
						},
					}),
				},
			})

			------------------------------------------------------------------------
			-- The menu behind the "…" of a project
			------------------------------------------------------------------------

			local function closeProjectMenu()
				projectMenuOpen:set(false)
				projectMenuPage:set("root")
			end
			-- Runs an action on the project being shown, then closes the menu.
			local function onProject(action: (name: string) -> ()): () -> ()
				return function()
					local name = currentProject()
					closeProjectMenu()
					if name then
						action(name)
					end
				end
			end

			local whenRows: { Instance } = {}
			for index, choice in
				{
					{ Text = "Today", Icon = "star", Due = dateOffset(0) },
					{ Text = "Tomorrow", Icon = "sunrise", Due = dateOffset(1) },
					{ Text = "No date", Icon = "archive", Due = "" },
				}
			do
				table.insert(
					whenRows,
					ds:MenuButton({
						Text = choice.Text,
						Leading = choice.Icon,
						LayoutOrder = index,
						OnClick = onProject(function(name: string)
							setProjectDue(name, choice.Due)
						end),
					})
				)
			end
			local projectTagRows: { Instance } = {}
			for index, tag in tagList do
				table.insert(
					projectTagRows,
					ds:MenuButton({
						Text = tag.Label,
						Leading = "tag",
						LayoutOrder = index,
						OnClick = onProject(function(name: string)
							tagProject(name, tag.Id)
						end),
					})
				)
			end

			ds:Popover({
				Layer = overlayLayer,
				Target = ellipsis,
				Open = projectMenuOpen,
				Placement = "Bottom",
				Width = 260,
				RootPage = "root",
				Page = projectMenuPage,
				OnChanged = function(id: string)
					projectMenuPage:set(id)
				end,
				OnClose = closeProjectMenu,
				Sections = {
					{
						Items = {
							{
								Text = "Complete Project",
								Leading = "circle-check",
								OnClick = onProject(completeProject),
							},
							{
								Text = "When",
								Leading = "calendar",
								Trailing = "chevron-right",
								Page = "when",
							},
							{
								Text = "Add Tags",
								Leading = "tag",
								Trailing = "chevron-right",
								Page = "tags",
							},
						} :: { any },
					},
				},
				Children = {
					-- Delete asks again on a page of the same popover, so there is no dialog on
					-- top of it. With "Confirm before deleting" off it deletes at once.
					ds:MenuSection({
						Children = {
							ds:MenuButton({
								Text = "Duplicate Project",
								Leading = "copy",
								LayoutOrder = 1,
								OnClick = onProject(duplicateProject),
							}),
							ds:MenuButton({
								Text = "Delete Project",
								Leading = "trash-2",
								Color = "error",
								LayoutOrder = 2,
								OnClick = function()
									if peek(confirmDelete) then
										projectMenuPage:set("delete")
									else
										onProject(deleteProject)()
									end
								end,
							}),
						},
					}),
					ds:MenuPage({ Id = "when", Title = "When", Children = whenRows }),
					ds:MenuPage({ Id = "tags", Title = "Add Tags", Children = projectTagRows }),
					ds:MenuPage({
						Id = "delete",
						Title = "Delete Project",
						Children = {
							ds:Frame({
								Name = "Warning",
								BackgroundTransparency = 1,
								Size = UDim2.new(1, 0, 0, 0),
								AutomaticSize = Enum.AutomaticSize.Y,
								LayoutOrder = 1,
								Padding = { theme.Metrics.SpaceXs, theme.Metrics.SpaceSm },
								[Children] = {
									ds:TextLabel({
										BackgroundTransparency = 1,
										FontFace = theme.Typography.Body.Font,
										TextSize = 14,
										TextColor3 = theme.Colors.OnSurfaceVariant,
										TextWrapped = true,
										TextXAlignment = Enum.TextXAlignment.Left,
										AutomaticSize = Enum.AutomaticSize.Y,
										Size = UDim2.new(1, 0, 0, 0),
										Text = ds:Computed(function(use: any)
											local name =
												string.match(use(app.view), "^project:(.+)$")
											return `Delete {name or "this project"} and all of its to-dos? You cannot undo this.`
										end),
									}),
								},
							}),
							ds:MenuButton({
								Text = "Delete Project",
								Leading = "trash-2",
								Color = "error",
								LayoutOrder = 2,
								OnClick = onProject(deleteProject),
							}),
							ds:MenuButton({
								Text = "Cancel",
								Leading = "x",
								LayoutOrder = 3,
								OnClick = function()
									projectMenuPage:set("root")
								end,
							}),
						},
					}),
				},
			})

			------------------------------------------------------------------------
			-- The popovers of the to-do card
			------------------------------------------------------------------------

			local function dueChoice(text: string, icon: string, due: string): any
				return {
					Text = text,
					Leading = icon,
					OnClick = function()
						draftDue:set(due)
						if due ~= "" then
							draftDate:set(due)
						end
					end,
				}
			end

			ds:Popover({
				Layer = overlayLayer,
				Target = whenButton,
				Open = whenOpen,
				Placement = "Bottom",
				-- The calendar is 308 px wide, and the menu has 6 px of padding each side.
				Width = 324,
				MaxHeight = 400,
				OnClose = function()
					whenOpen:set(false)
				end,
				Sections = {
					{
						Items = {
							dueChoice("Today", "star", dateOffset(0)),
							dueChoice("Tomorrow", "sunrise", dateOffset(1)),
						},
					},
				},
				Children = {
					ds:Frame({
						Name = "Calendar",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						LayoutOrder = 10,
						[Children] = {
							ds:DatePicker({
								Value = draftDate,
								OnChanged = function(date: string)
									draftDue:set(date)
									whenOpen:set(false)
								end,
							}),
						},
					}),
					ds:MenuButton({
						Text = "No date",
						Leading = "archive",
						LayoutOrder = 11,
						OnClick = function()
							draftDue:set("")
							whenOpen:set(false)
						end,
					}),
				},
			})

			-- The tags stay open as you choose, so you can pick more than one.
			local chooseTags: { Instance } = {}
			for index, tag in tagList do
				table.insert(
					chooseTags,
					ds:MenuButton({
						Text = tag.Label,
						Leading = "tag",
						LayoutOrder = index,
						Selected = ds:Computed(function(use: any)
							return table.find(use(draftTags), tag.Id) ~= nil
						end),
						OnClick = function()
							local chosen = table.clone(peek(draftTags))
							local at = table.find(chosen, tag.Id)
							if at then
								table.remove(chosen, at)
							else
								table.insert(chosen, tag.Id)
							end
							draftTags:set(chosen)
						end,
					})
				)
			end
			ds:Popover({
				Layer = overlayLayer,
				Target = tagsButton,
				Open = tagsOpen,
				Placement = "Bottom",
				OnClose = function()
					tagsOpen:set(false)
				end,
				Children = chooseTags,
			})

			local moveItems: { any } = {}
			for _, option in newTaskOptions do
				table.insert(moveItems, {
					Text = option.Label,
					Leading = if option.Value == INBOX
						then "inbox"
						else iconFor("project:" .. option.Value),
					Selected = ds:Computed(function(use: any)
						return use(draftProject) == option.Value
					end),
					OnClick = function()
						draftProject:set(option.Value)
					end,
				})
			end
			ds:Popover({
				Layer = overlayLayer,
				Target = moveButton,
				Open = moveOpen,
				Placement = "Bottom",
				OnClose = function()
					moveOpen:set(false)
				end,
				Items = moveItems,
			})
		end)
	end

	-- Built again when a project or a tag is added or removed.
	local overlaySignature = scope:Computed(function(use: any)
		return { use(projects), use(tags) }
	end)
	table.insert(
		scope,
		scope:Observer(overlaySignature):onChange(function()
			buildOverlays()
		end)
	)
	table.insert(scope, function()
		if overlayScope then
			Fusion.doCleanup(overlayScope)
			overlayScope = nil
		end
	end)
	buildOverlays()
end
