--!strict
--[[
	The top strip, the title, the field at the bottom, the scroll region and the window.

	Shared state and helpers are on `app`. Each module adds what the ones after it need.
]]
local Common = require(script.Parent.Common)
local Pantheon, Fusion, Router, TopbarIcon, Children, peek, playerGui =
	Common.Pantheon,
	Common.Fusion,
	Common.Router,
	Common.TopbarIcon,
	Common.Children,
	Common.peek,
	Common.playerGui

return function(app: any)
	local accentFor, addProject, addTag, addTask, composer, docked, drawerOpen, ellipsis, hideWindow, iconFor, overlayLayer, reveal, router, scope, searchField, theme, trim, viewTitle, windowOpen =
		app.accentFor,
		app.addProject,
		app.addTag,
		app.addTask,
		app.composer,
		app.docked,
		app.drawerOpen,
		app.ellipsis,
		app.hideWindow,
		app.iconFor,
		app.overlayLayer,
		app.reveal,
		app.router,
		app.scope,
		app.searchField,
		app.theme,
		app.trim,
		app.viewTitle,
		app.windowOpen
	----------------------------------------------------------------------------
	-- The strip along the top, the title and the field at the bottom
	----------------------------------------------------------------------------

	-- The bar along the very top that you drag the window by. It has its own height, so the
	-- window can still be moved when the strip below it is full of controls.
	local dragBar = scope:Frame({
		Name = "DragBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 20),
		LayoutOrder = -1,
		Layout = {
			Kind = "List",
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},
		[Children] = {
			scope:Frame({
				Name = "Grip",
				Size = UDim2.fromOffset(36, 4),
				BackgroundColor3 = theme.Colors.Outline,
				CornerRadius = theme.Metrics.RadiusPill,
			}),
		},
	})
	local topBar = scope:Frame({
		Name = "TopBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36),
		LayoutOrder = 0,
		Padding = { 0, theme.Metrics.SpaceMd },
		[Children] = {
			scope:Frame({
				Name = "Controls",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				ZIndex = 2,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = theme.Metrics.SpaceXs,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = {
					scope:IconButton({
						Name = "menu",
						LayoutOrder = 1,
						Visible = scope:Computed(function(use: any)
							return not use(docked)
						end),
						OnClick = function()
							drawerOpen:set(true)
						end,
					}),
					-- The search takes the width that is left.
					scope:Frame({
						Name = "SearchSlot",
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 1, 0),
						LayoutOrder = 2,
						Flex = { FlexMode = Enum.UIFlexMode.Fill },
						Layout = {
							Kind = "List",
							VerticalAlignment = Enum.VerticalAlignment.Center,
							SortOrder = Enum.SortOrder.LayoutOrder,
						},
						[Children] = { searchField },
					}),
					scope:IconButton({
						Name = "x",
						LayoutOrder = 3,
						-- Without the sidebar there is no other way to hide the window.
						Visible = scope:Computed(function(use: any)
							return not use(docked)
						end),
						OnClick = hideWindow,
					}),
				},
			}),
		},
	})

	-- The title of the list: its icon and its name, and for a project its menu at the far
	-- right. It stays while the list slides.
	local titleRow = scope:Frame({
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 1,
		Padding = { theme.Metrics.SpaceXs, 0, theme.Metrics.SpaceXs, 0 },
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = 10,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			scope:Computed(function(use: any, inner: any)
				local viewId = use(app.view)
				return inner:Icon({
					Name = iconFor(viewId),
					IconSize = 28,
					Color = accentFor(viewId),
					LayoutOrder = 1,
				})
			end),
			scope:Text({ Text = viewTitle, Variant = "Headline", LayoutOrder = 2 }),
			scope:Frame({
				Name = "Spacer",
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 0, 0),
				LayoutOrder = 3,
				Flex = { FlexMode = Enum.UIFlexMode.Fill },
			}),
			ellipsis,
		},
	})

	-- A page slides in the direction you are going and fades as it does. The old page fades
	-- out as the new one fades in.
	local slide = Router.Transitions.Slide()
	local function slideAndFade(info: any)
		local fades = Fusion.innerScope(scope) :: any
		local entering = fades:Value(0)
		local leaving = fades:Value(1)
		local speed, damping = theme.Motion.SpringSpeed, theme.Motion.SpringDamping
		Pantheon.GroupFade.bind(fades, info.Entering, fades:Spring(entering, speed, damping))
		Pantheon.GroupFade.bind(fades, info.Leaving, fades:Spring(leaving, speed, damping))
		entering:set(1)
		leaving:set(0)
		local finish = info.Finish
		info.Finish = function()
			Fusion.doCleanup(fades)
			finish()
		end
		slide(info)
	end

	-- The lists slide in the direction you are going.
	local listView = Router.RouteView(scope, {
		Router = router,
		LayoutOrder = 3,
		Size = UDim2.new(1, 0, 0, 0),
		ClipsDescendants = true,
		Transition = slideAndFade,
	})
	-- It is as tall as the page it shows.
	local listFrame = listView :: GuiObject
	listFrame.AutomaticSize = Enum.AutomaticSize.Y

	-- "Add something new": type, then choose a to-do, a tag or a project. Enter adds a to-do.
	local addText = scope:Value("")
	local function addAs(add: (text: string) -> ()): () -> ()
		return function()
			local text = trim(peek(addText))
			if text ~= "" then
				addText:set("")
				add(text)
			end
		end
	end
	local function choice(icon: string, label: string, add: (text: string) -> (), order: number)
		return scope:MenuButton({
			Layer = overlayLayer,
			Text = scope:Computed(function(use: any)
				return `{label} "{trim(use(addText))}"`
			end),
			Leading = icon,
			LayoutOrder = order,
			Flat = true,
			OnClick = addAs(add),
		})
	end
	local addField = scope:TextField({
		Placeholder = "Add something new",
		LeadingIcon = "plus",
		Text = addText,
		Height = 40,
		Size = UDim2.new(1, 0, 0, 40),
		LayoutOrder = 2,
	})
	local addBox = addField:FindFirstChildWhichIsA("TextBox", true)
	if addBox then
		table.insert(
			scope,
			addBox.FocusLost:Connect(function(enterPressed: boolean)
				if enterPressed then
					addAs(addTask)()
				end
			end)
		)
	end
	local footer = scope:Frame({
		Name = "Footer",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
		Padding = { 0, theme.Metrics.SpaceMd },
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.SpaceXs,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			reveal(
				scope:Frame({
					Name = "Choices",
					BackgroundColor3 = theme.Colors.SurfaceContainer,
					CornerRadius = theme.Metrics.RadiusMd,
					Size = UDim2.new(1, 0, 0, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					Padding = { 4, 4 },
					Layout = {
						Kind = "List",
						Padding = 1,
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					[Children] = {
						choice("circle-plus", "New to-do", addTask, 1),
						choice("tag", "New tag", addTag, 2),
						choice("folder-plus", "New project", addProject, 3),
					},
				}),
				scope:Computed(function(use: any)
					return trim(use(addText)) ~= ""
				end),
				1
			),
			addField,
		},
	})

	-- Everything between the top strip and the field at the bottom scrolls. The edges fade
	-- into the window's own colour, so content goes under the strip and the field softly.
	-- The top edge only shows once the page has scrolled.
	local FADE = 28
	local scrolled = scope:Value(0)
	local function fadeEdge(top: boolean): Instance
		return scope:Frame({
			Name = if top then "FadeTop" else "FadeBottom",
			BackgroundColor3 = theme.Colors.SurfaceContainerHigh,
			BackgroundTransparency = if top
				then scope:Computed(function(use: any)
					return 1 - math.clamp(use(scrolled) / FADE, 0, 1)
				end)
				else 0,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, FADE),
			AnchorPoint = Vector2.new(0, if top then 0 else 1),
			Position = UDim2.fromScale(0, if top then 0 else 1),
			ZIndex = 5,
			[Children] = {
				scope:New("UIGradient")({
					Rotation = if top then 90 else 270,
					Transparency = NumberSequence.new(0, 1),
				}),
			},
		})
	end
	local scrollRegion = scope:Frame({
		Name = "ScrollRegion",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = 1,
		ClipsDescendants = true,
		Flex = { FlexMode = Enum.UIFlexMode.Fill },
		[Children] = {
			scope:ScrollArea({
				Size = UDim2.fromScale(1, 1),
				ContentPadding = 0,
				ListPadding = 0,
				-- The rows keep the full width of the page.
				ScrollBarOverlay = true,
				OnScroll = function(offset: number)
					scrolled:set(offset)
				end,
				ScrollBarPadding = 0,
				Children = {
					-- The page has its own side padding, so the scroll bar can sit on the edge.
					scope:Frame({
						Name = "Page",
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						Padding = { 0, theme.Metrics.SpaceMd },
						Layout = {
							Kind = "List",
							Padding = theme.Metrics.SpaceXs,
							SortOrder = Enum.SortOrder.LayoutOrder,
						},
						[Children] = { titleRow, composer, listView },
					}),
				},
			}),
			fadeEdge(true),
			fadeEdge(false),
		},
	})

	local window = scope:Window({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = scope:Value(UDim2.fromScale(0.5, 0.5)),
		Size = scope:Value(UDim2.new(0.4, 0, 0.82, 0)),
		Visible = windowOpen,
		Draggable = true,
		Resizable = true,
		MinSize = Vector2.new(360, 420),
		DragHandle = dragBar,
		Overlays = { overlayLayer },
		Children = {
			scope:Frame({
				Name = "Content",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				-- Bottom only, and the sides pad themselves: the drag bar is at the very top, and
				-- the strips and the page pad their own sides, so the scroll bar can sit at the right
				-- edge of the window.
				Padding = { 0, 0, theme.Metrics.SpaceMd, 0 },
				Layout = {
					Kind = "List",
					Padding = theme.Metrics.SpaceXs,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = {
					dragBar,
					topBar,
					scrollRegion,
					footer,
				},
			}),
		},
	})

	scope:New("ScreenGui")({
		Name = "PantheonTasks",
		ResetOnSpawn = false,
		Parent = playerGui,
		[Children] = { window },
	})

	-- An icon in the Roblox top bar brings the window back. Closing the window deselects it.
	app.topbarIcon = TopbarIcon.new():setName("Tasks"):setLabel("Tasks"):setOrder(1):setLeft()
	app.topbarIcon:bindEvent("selected", function()
		windowOpen:set(true)
	end)
	app.topbarIcon:bindEvent("deselected", function()
		windowOpen:set(false)
	end)
	scope:Observer(windowOpen):onChange(function()
		if peek(windowOpen) then
			app.topbarIcon:select()
		else
			app.topbarIcon:deselect()
		end
	end)
	app.topbarIcon:select()
end
