--!strict
--[[
	Controls that popovers point at.

	Shared state and helpers are on `app`. Each module adds what the ones after it need.
]]

return function(app: any)
	local drawerOpen, moveOpen, projectMenuOpen, scope, tagsOpen, whenOpen, windowOpen =
		app.drawerOpen,
		app.moveOpen,
		app.projectMenuOpen,
		app.scope,
		app.tagsOpen,
		app.whenOpen,
		app.windowOpen
	----------------------------------------------------------------------------
	-- Controls that the popovers and the sidebar point at
	----------------------------------------------------------------------------

	local function hideWindow()
		drawerOpen:set(false)
		windowOpen:set(false)
	end

	-- The "…" of a project's title. It is made here so its popover can point at it.
	local isProject = scope:Computed(function(use: any)
		return string.sub(use(app.view), 1, 8) == "project:"
	end)
	local ellipsis = scope:IconButton({
		Name = "ellipsis",
		LayoutOrder = 4,
		Visible = isProject,
		OnClick = function()
			projectMenuOpen:set(true)
		end,
	})

	local function cardButton(icon: string, order: number, onClick: () -> ()): Instance
		return scope:IconButton({ Name = icon, LayoutOrder = order, OnClick = onClick })
	end
	local whenButton = cardButton("calendar", 2, function()
		whenOpen:set(true)
	end)
	local tagsButton = cardButton("tag", 3, function()
		tagsOpen:set(true)
	end)
	local moveButton = cardButton("folder", 4, function()
		moveOpen:set(true)
	end)

	app.ellipsis = ellipsis
	app.hideWindow = hideWindow
	app.moveButton = moveButton
	app.tagsButton = tagsButton
	app.whenButton = whenButton
end
