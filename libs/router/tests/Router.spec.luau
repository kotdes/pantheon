--!nocheck
local Router = require(script.Parent.Parent.src.Router)
local Helpers = require(script.Parent.Helpers)

local stubScope, read, makeRouter = Helpers.stubScope, Helpers.read, Helpers.makeRouter

return function()
	describe("starting", function()
		it("starts on the initial route", function()
			local router = makeRouter()
			expect(router.Route.value.Name).to.equal("today")
			expect(router.CanGoBack.value).to.equal(false)
		end)

		it("starts on a route that matches nothing when Initial does not match", function()
			local router = makeRouter({ Initial = "/nowhere" })
			expect(#router.Route.value.Matched).to.equal(0)
			expect(router.Route.value.Path).to.equal("/nowhere")
			expect(router:Push("/today")).to.equal(true)
		end)

		it("rejects duplicate route names", function()
			local ok = pcall(Router.new, stubScope(), {
				Routes = { { Name = "a", Path = "/a" }, { Name = "a", Path = "/b" } },
			})
			expect(ok).to.equal(false)
		end)
	end)

	describe("Push", function()
		it("goes to a path", function()
			local router = makeRouter()
			expect(router:Push("/project/Work")).to.equal(true)
			expect(router.Route.value.Params.id).to.equal("Work")
		end)

		it("goes to a name with parameters and a query", function()
			local router = makeRouter()
			expect(
				router:Push({ Name = "project", Params = { id = "Home" }, Query = { tab = "open" } })
			).to.equal(true)
			expect(router.Route.value.Url).to.equal("/project/Home?tab=open")
			expect(router.Route.value.Query.tab).to.equal("open")
		end)

		it("goes to a route name", function()
			local router = makeRouter()
			router:Push("/project/Work")
			expect(router:Push("today")).to.equal(true)
			expect(router.Route.value.Path).to.equal("/today")
		end)

		it("prefers a static route to a parameter route", function()
			local router = makeRouter()
			router:Push("/project/new")
			expect(router.Route.value.Name).to.equal("newProject")
		end)

		it("matches nested routes with their parents", function()
			local router = makeRouter()
			router:Push("/settings/sort")
			expect(#router.Route.value.Matched).to.equal(2)
			expect(router.Route.value.Matched[1].Name).to.equal("settings")
			expect(router.Route.value.Name).to.equal("sort")
		end)

		it("follows redirects", function()
			local router = makeRouter()
			router:Push("/settings")
			expect(router.Route.value.Path).to.equal("/settings/appearance")
			router:Push("/")
			expect(router.Route.value.Path).to.equal("/today")
		end)

		it("fills a splat", function()
			local router = makeRouter()
			router:Push("/files/a/b")
			expect(router.Route.value.Params["*"]).to.equal("a/b")
		end)

		it("adds no history when you push the current URL", function()
			local router = makeRouter()
			expect(router:Push("/today")).to.equal(false)
			expect(router.CanGoBack.value).to.equal(false)
		end)

		it("does nothing for an unknown target", function()
			local router = makeRouter()
			expect(router:Push("/nowhere")).to.equal(false)
			expect(router:Push("no-such-name")).to.equal(false)
			expect(router:Push({ Name = "project" })).to.equal(false)
			expect(router.Route.value.Path).to.equal("/today")
		end)

		it("stops a redirect loop", function()
			local router = Router.new(stubScope(), {
				Routes = {
					{ Path = "/a" },
					{ Path = "/x", Redirect = "/y" },
					{ Path = "/y", Redirect = "/x" },
				},
				Initial = "/a",
			})
			expect(router:Push("/x")).to.equal(false)
			expect(router.Route.value.Path).to.equal("/a")
		end)
	end)

	describe("history", function()
		it("goes back and forward, and updates CanGoBack and CanGoForward", function()
			local router = makeRouter()
			router:Push("/project/Work")
			router:Push("/settings/sort")
			expect(router.CanGoBack.value).to.equal(true)
			expect(router.CanGoForward.value).to.equal(false)
			expect(router:Back()).to.equal(true)
			expect(router.Route.value.Url).to.equal("/project/Work")
			expect(router.CanGoForward.value).to.equal(true)
			expect(router:Forward()).to.equal(true)
			expect(router.Route.value.Url).to.equal("/settings/sort")
			expect(router:Forward()).to.equal(false)
			router:Back()
			router:Back()
			expect(router:Back()).to.equal(false)
			expect(router.CanGoBack.value).to.equal(false)
		end)

		it("does not grow on Replace", function()
			local router = makeRouter()
			router:Replace("/project/Work")
			expect(router.Route.value.Url).to.equal("/project/Work")
			expect(router.CanGoBack.value).to.equal(false)
		end)

		it("reports each change to OnChanged", function()
			local router, log = makeRouter()
			router:Push("/project/Work")
			router:Back()
			expect(table.concat(log, ";")).to.equal(
				"/today -> /project/Work;/project/Work -> /today"
			)
		end)

		it("sets the direction", function()
			local router = makeRouter()
			expect(router.Route.value.Direction).to.equal("Initial")
			router:Push("/project/Work")
			expect(router.Route.value.Direction).to.equal("Forward")
			router:Replace("/project/Home")
			expect(router.Route.value.Direction).to.equal("Replace")
			router:Back()
			expect(router.Route.value.Direction).to.equal("Back")
			router:Forward()
			expect(router.Route.value.Direction).to.equal("Forward")
		end)
	end)

	describe("guards", function()
		it("lets BeforeEach cancel and redirect", function()
			local router = makeRouter({
				BeforeEach = function(to: any)
					if to.Path == "/project/blocked" then
						return false
					elseif to.Path == "/project/old" then
						return { Name = "project", Params = { id = "new-home" } }
					end
					return true
				end,
			})
			expect(router:Push("/project/blocked")).to.equal(false)
			expect(router.Route.value.Path).to.equal("/today")
			expect(router:Push("/project/old")).to.equal(true)
			expect(router.Route.value.Params.id).to.equal("new-home")
		end)

		it("runs BeforeLeave and BeforeEnter for the routes left and entered", function()
			local log = {}
			local router = Router.new(stubScope(), {
				Routes = {
					{
						Path = "/a",
						BeforeLeave = function()
							table.insert(log, "leave a")
							return true
						end,
					},
					{
						Path = "/b",
						BeforeEnter = function()
							table.insert(log, "enter b")
						end,
					},
				},
				Initial = "/a",
			})
			router:Push("/b")
			expect(table.concat(log, ",")).to.equal("leave a,enter b")
		end)

		it("lets BeforeLeave keep you on the route", function()
			local router = Router.new(stubScope(), {
				Routes = {
					{
						Path = "/editor",
						BeforeLeave = function()
							return false
						end,
					},
					{ Path = "/other" },
				},
				Initial = "/editor",
			})
			expect(router:Push("/other")).to.equal(false)
			expect(router.Route.value.Path).to.equal("/editor")
		end)

		it("keeps the history where it was when a guard stops Back", function()
			local allow = true
			local router = Router.new(stubScope(), {
				Routes = { { Path = "/a" }, { Path = "/b" } },
				Initial = "/a",
				BeforeEach = function()
					return allow
				end,
			})
			router:Push("/b")
			allow = false
			expect(router:Back()).to.equal(false)
			expect(router.Route.value.Path).to.equal("/b")
			allow = true
			expect(router:Back()).to.equal(true)
			expect(router.Route.value.Path).to.equal("/a")
		end)

		it("drops a waiting guard when a newer navigation starts", function()
			local yields = true
			local router = Router.new(stubScope(), {
				Routes = { { Path = "/a" }, { Path = "/b" }, { Path = "/c" } },
				Initial = "/a",
				BeforeEach = function()
					if yields then
						coroutine.yield()
					end
					return true
				end,
			})
			local first: boolean? = nil
			local thread = coroutine.create(function()
				first = router:Push("/b")
			end)
			coroutine.resume(thread)
			yields = false
			expect(router:Push("/c")).to.equal(true)
			coroutine.resume(thread)
			expect(first).to.equal(false)
			expect(router.Route.value.Path).to.equal("/c")
		end)
	end)

	describe("Active", function()
		it("follows the route, and exact turns off prefix matching", function()
			local router = makeRouter()
			local project = router:Active("/project/Work")
			local settings = router:Active("/settings")
			local exact = router:Active("/settings", true)
			expect(read(project)).to.equal(false)
			router:Push("/project/Work")
			expect(read(project)).to.equal(true)
			router:Push("/settings/sort")
			expect(read(settings)).to.equal(true)
			expect(read(exact)).to.equal(false)
			expect(read(router:Active("/nowhere"))).to.equal(false)
		end)
	end)

	describe("Href and Link", function()
		it("builds a URL for a target", function()
			local router = makeRouter()
			expect(router:Href({ Name = "project", Params = { id = "Work" } })).to.equal(
				"/project/Work"
			)
			expect(router:Href("/nowhere")).to.equal(nil)
		end)

		it("returns a function that pushes", function()
			local router = makeRouter()
			router:Link("/project/Work")()
			expect(router.Route.value.Url).to.equal("/project/Work")
		end)
	end)

	describe("shorthand routes", function()
		it("accepts functions, records and children", function()
			local function render() end
			local router = Router.new(stubScope(), {
				["/"] = render,
				["/project/:id"] = { Name = "project", Render = render },
				["/settings"] = {
					Render = render,
					Children = {
						["appearance"] = render,
						["sort"] = { Name = "sort", Render = render },
					},
				},
			})
			expect(router.Route.value.Path).to.equal("/")
			router:Push({ Name = "project", Params = { id = "Work" } })
			expect(router.Route.value.Params.id).to.equal("Work")
			router:Push("/settings/sort")
			expect(router.Route.value.Name).to.equal("sort")
			expect(#router.Route.value.Matched).to.equal(2)
		end)

		it("needs a root route or an Initial", function()
			local ok = pcall(Router.new, stubScope(), { ["/a"] = function() end })
			expect(ok).to.equal(false)
			local router =
				Router.new(stubScope(), { Routes = { ["/a"] = function() end }, Initial = "/a" })
			expect(router.Route.value.Path).to.equal("/a")
		end)

		it("rejects a Path that disagrees with the key", function()
			local ok = pcall(Router.new, stubScope(), { ["/a"] = { Path = "/b" } })
			expect(ok).to.equal(false)
		end)
	end)
end
