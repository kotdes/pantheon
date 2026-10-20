--!strict
--[[
	Tasks: a to-do app in the style of Things, built only from Pantheon components.

	This file builds the theme, the scope and the layer, then runs the parts in order. They
	share state and helpers through `app`, and each adds what the ones after it need:

	- Data: state, and the pure helpers that say what each list holds.
	- Navigation: the router. Every list is a route, and they slide as you move between them.
	- Draft: the state of the to-do card, and saving, deleting and completing.
	- Actions: adding a to-do, a tag or a project, and the actions of a project.
	- Controls: buttons that popovers point at.
	- Overlays: the sidebar and the popovers. They are built again when a project or a tag is
	  added.
	- Search: the search field, which goes to a search route.
	- List: the to-dos of a page.
	- Composer: the inline to-do card, the discard guard and the delete dialog.
	- Chrome: the strips, the title, the field at the bottom, the scroll area and the window.

	A TopbarPlus icon shows and hides the window. TopbarPlus is a dev dependency.
]]
local Common = require(script.Common)
local Pantheon, Fusion = Common.Pantheon, Common.Fusion

local parts = {
	require(script.Data),
	require(script.Navigation),
	require(script.Draft),
	require(script.Actions),
	require(script.Controls),
	require(script.Overlays),
	require(script.Search),
	require(script.List),
	require(script.Composer),
	require(script.Chrome),
}

local function start(): () -> ()
	-- The theme is a state, so a change of mode recolours the interface in place.
	local previousReactive = Pantheon.Flags.ReactiveTheme
	Pantheon.Flags.ReactiveTheme = true

	local rootScope = Pantheon.scoped()
	local mode = rootScope:Value("Light" :: "Light" | "Dark")
	local themeSource = Pantheon.Theme.createAnimated(rootScope, mode, { Animate = true })
	local scope = Fusion.innerScope(rootScope) :: any
	local theme = Pantheon.Theme.reactive(themeSource) :: any

	local app: any = {
		rootScope = rootScope,
		mode = mode,
		themeSource = themeSource,
		scope = scope,
		theme = theme,
	}

	Pantheon.Theme.Provide(themeSource, function()
		-- Everything that floats lives on this layer, inside the window.
		app.overlayLayer = scope:Frame({
			Name = "OverlayLayer",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 50,
		})
		app.toasts = scope:SnackbarHost({ Layer = app.overlayLayer })

		for _, part in parts do
			part(app)
		end
	end)

	return function()
		if app.topbarIcon then
			app.topbarIcon:destroy()
		end
		Fusion.doCleanup(scope)
		Fusion.doCleanup(rootScope)
		Pantheon.Flags.ReactiveTheme = previousReactive
	end
end

return {
	Name = "Tasks",
	Description = "A to-do app in the style of Things",
	Icon = "list-checks",
	start = start,
}
