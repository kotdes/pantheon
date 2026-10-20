--!nocheck
local Helpers = require(script.Parent.Helpers)

local read, instance, harness = Helpers.read, Helpers.instance, Helpers.harness

return function()
	it("shows the matched route and parents it", function()
		local h = harness({
			{
				Path = "/",
				Render = function()
					return instance("home")
				end,
			},
		})
		h.show()
		expect(h.container.Name).to.equal("container")
		expect(h.provided).to.equal(1)
	end)

	describe("updating and rebuilding", function()
		it("updates in place when only the parameters change", function()
			local renders, made, context = 0, nil, nil
			local h = harness({
				{
					Path = "/",
					Render = function()
						return instance("home")
					end,
				},
				{
					Path = "/project/:id",
					Render = function(_, ctx: any)
						renders += 1
						context = ctx
						made = instance("project")
						return made
					end,
				},
			})
			h.show()
			h.router:Push("/project/A")
			h.show()
			expect(read(context.Param("id"))).to.equal("A")
			h.router:Push("/project/B")
			h.show()
			expect(renders).to.equal(1)
			expect(made.Destroyed).to.equal(false)
			expect(read(context.Param("id"))).to.equal("B")
			expect(read(context.Params).id).to.equal("B")
			expect(context.Initial.Params.id).to.equal("A")
		end)

		it("rebuilds when Key changes", function()
			local renders, first = 0, nil
			local h = harness({
				{
					Path = "/p/:id",
					Key = function(route: any)
						return route.Params.id
					end,
					Render = function()
						renders += 1
						local made = instance("p")
						first = first or made
						return made
					end,
				},
			}, nil, "/p/0")
			h.router:Push("/p/A")
			h.show()
			h.router:Push("/p/B")
			h.show()
			expect(renders).to.equal(2)
			expect(first.Destroyed).to.equal(true)
			expect(#h.cleaned).to.equal(1)
		end)

		it("replaces the view when the route changes to another route", function()
			local home
			local h = harness({
				{
					Path = "/",
					Render = function()
						home = instance("home")
						return home
					end,
				},
				{
					Path = "/other",
					Render = function()
						return instance("other")
					end,
				},
			})
			h.show()
			h.router:Push("/other")
			h.show()
			expect(home.Destroyed).to.equal(true)
		end)
	end)

	describe("NotFound", function()
		it("shows NotFound when nothing matches", function()
			local shown = false
			local h = harness({ Routes = { { Path = "/a" } }, Initial = "/nowhere" }, {
				NotFound = function()
					shown = true
					return instance("not found")
				end,
			})
			h.show()
			expect(shown).to.equal(true)
		end)
	end)

	describe("Load", function()
		it("shows Pending, then renders with the data", function()
			local order, data = {}, nil
			local pending
			local h = harness({
				{
					Path = "/",
					Load = function()
						return coroutine.yield()
					end,
					Pending = function()
						table.insert(order, "pending")
						pending = instance("pending")
						return pending
					end,
					Render = function(_, ctx: any)
						table.insert(order, "render")
						data = ctx.Data
						return instance("view")
					end,
				},
			})
			h.show()
			expect(table.concat(order, ",")).to.equal("pending")
			coroutine.resume(h.threads[1], "loaded")
			expect(table.concat(order, ",")).to.equal("pending,render")
			expect(data).to.equal("loaded")
			expect(pending.Destroyed).to.equal(true)
		end)

		it("shows Error when Load fails", function()
			local errorSeen
			local h = harness({
				{
					Path = "/",
					Load = function()
						error("no connection")
					end,
					Error = function(_, _, err: any)
						errorSeen = err
						return instance("error")
					end,
					Render = function()
						error("should not render")
					end,
				},
			})
			h.show()
			expect(string.find(tostring(errorSeen), "no connection", 1, true)).to.be.ok()
		end)

		it("warns when Load fails and there is no Error", function()
			local h = harness({
				{
					Path = "/",
					Load = function()
						error("nope")
					end,
					Render = function() end,
				},
			})
			h.show()
			expect(#h.warnings).to.equal(1)
		end)

		it("drops a load that was left before it finished", function()
			local rendered = false
			local h = harness({
				{
					Path = "/",
					Load = function()
						return coroutine.yield()
					end,
					Render = function()
						rendered = true
						return instance("late")
					end,
				},
				{
					Path = "/other",
					Render = function()
						return instance("other")
					end,
				},
			})
			h.show()
			h.router:Push("/other")
			h.show()
			coroutine.resume(h.threads[1], "late data")
			expect(rendered).to.equal(false)
		end)

		it("rebuilds when the parameters change", function()
			local loads = 0
			local h = harness({
				{
					Path = "/p/:id",
					Load = function()
						loads += 1
						return loads
					end,
					Render = function()
						return instance("p")
					end,
				},
			}, nil, "/p/0")
			h.router:Push("/p/A")
			h.show()
			h.router:Push("/p/B")
			h.show()
			expect(loads).to.equal(2)
		end)

		it("keeps the previous view until the data is here when there is no Pending", function()
			local home
			local h = harness({
				{
					Path = "/",
					Render = function()
						home = instance("home")
						return home
					end,
				},
				{
					Path = "/slow",
					Load = function()
						return coroutine.yield()
					end,
					Render = function()
						return instance("slow")
					end,
				},
			})
			h.show()
			h.router:Push("/slow")
			h.show()
			expect(home.Destroyed).to.equal(false)
			coroutine.resume(h.threads[1], "ok")
			expect(home.Destroyed).to.equal(true)
		end)
	end)

	describe("Transition", function()
		it("hands over to a Transition, and a newer change finishes it", function()
			local infos, home = {}, nil
			local h = harness({
				{
					Path = "/",
					Render = function()
						home = instance("home")
						return home
					end,
				},
				{
					Path = "/a",
					Render = function()
						return instance("a")
					end,
				},
				{
					Path = "/b",
					Render = function()
						return instance("b")
					end,
				},
			}, {
				Transition = function(info: any)
					table.insert(infos, info)
				end,
			})
			h.show()
			h.router:Push("/a")
			h.show()
			expect(#infos).to.equal(1)
			expect(infos[1].Direction).to.equal("Forward")
			expect(infos[1].Leaving).to.equal(home)
			expect(infos[1].To.Path).to.equal("/a")
			expect(infos[1].From.Path).to.equal("/")
			expect(home.Destroyed).to.equal(false)
			h.router:Push("/b")
			h.show()
			expect(home.Destroyed).to.equal(true)
		end)

		it("removes the old view when Finish is called", function()
			local home, finish = nil, nil
			local h = harness({
				{
					Path = "/",
					Render = function()
						home = instance("home")
						return home
					end,
				},
				{
					Path = "/a",
					Render = function()
						return instance("a")
					end,
				},
			}, {
				Transition = function(info: any)
					finish = info.Finish
				end,
			})
			h.show()
			h.router:Push("/a")
			h.show()
			finish()
			expect(home.Destroyed).to.equal(true)
		end)
	end)

	describe("Outlet", function()
		it("shows the child route and keeps the parent while the child changes", function()
			local parent, childA
			local h = harness({
				{
					Path = "/settings",
					Render = function(_, ctx: any)
						parent = instance("settings")
						ctx.Outlet()
						return parent
					end,
					Children = {
						{
							Path = "a",
							Render = function()
								childA = instance("a")
								return childA
							end,
						},
						{
							Path = "b",
							Render = function()
								return instance("b")
							end,
						},
					},
				},
			}, nil, "/settings/a")
			h.show()
			expect(#h.nested).to.equal(1)
			h.router:Push("/settings/b")
			h.show()
			h.nested[1].Show(h.router.Route.value)
			expect(parent.Destroyed).to.equal(false)
			expect(childA.Destroyed).to.equal(true)
		end)
	end)

	describe("failures and cleanup", function()
		it("warns and shows nothing when Render breaks", function()
			local h = harness({
				{
					Path = "/",
					Render = function()
						error("broken")
					end,
				},
			})
			h.show()
			expect(#h.warnings).to.equal(1)
		end)

		it("removes the view when destroyed", function()
			local home
			local h = harness({
				{
					Path = "/",
					Render = function()
						home = instance("home")
						return home
					end,
				},
			})
			h.show()
			h.controller.Destroy()
			expect(home.Destroyed).to.equal(true)
		end)
	end)
end
