--!strict
--[[
	The router: every list is a route, and the list a route stands for.

	Shared state and helpers are on `app`. Each module adds what the ones after it need.
]]
local Common = require(script.Parent.Common)
local Pantheon, Router, peek = Common.Pantheon, Common.Router, Common.peek

return function(app: any)
	local drawerOpen, scope, tags, targetFor, themeSource, titleFor, viewIdOf =
		app.drawerOpen,
		app.scope,
		app.tags,
		app.targetFor,
		app.themeSource,
		app.titleFor,
		app.viewIdOf
	-- Every list is a route. Each id gets its own view, so moving between lists slides one
	-- view out and the next in. The search is one view whose query changes in place.
	local function renderList(listScope: any, context: any): Instance
		-- The list is built when the route changes, outside this theme, so provide it again.
		local made: Instance
		Pantheon.Theme.Provide(themeSource, function()
			made = app.buildList(listScope, context, viewIdOf(context.Initial))
		end)
		return made
	end
	local function byId(route: any): any
		return route.Params.id
	end
	-- Set once the card exists. It stops a navigation that would lose what is in the card.
	app.beforeNavigate = function()
		return true
	end
	local router = Router.new(scope, {
		BeforeEach = function(to: any)
			return app.beforeNavigate(to)
		end,
		Routes = {
			["/list/:id"] = { Name = "list", Render = renderList, Key = byId },
			["/project/:id"] = { Name = "project", Render = renderList, Key = byId },
			["/tag/:id"] = { Name = "tag", Render = renderList, Key = byId },
			["/search"] = { Name = "search", Render = renderList },
		},
		Initial = "/list/today",
	})
	-- The list the route stands for, as an id the sidebar and the title can use.
	app.view = scope:Computed(function(use: any)
		return viewIdOf(use(router.Route))
	end)

	-- True while the sidebar is docked beside the list, so the menu button is not needed.
	local docked = scope:Value(false)

	local function goTo(viewId: string)
		router:Push(targetFor(viewId))
		drawerOpen:set(false)
	end

	local viewTitle = scope:Computed(function(use: any)
		return titleFor(use(app.view), use(tags))
	end)

	-- The project being shown, or nil.
	local function currentProject(): string?
		return string.match(peek(app.view), "^project:(.+)$")
	end

	app.currentProject = currentProject
	app.docked = docked
	app.goTo = goTo
	app.router = router
	app.viewTitle = viewTitle
end
