--!nocheck
local Path = require(script.Parent.Parent.src.Path)

return function()
	describe("normalise", function()
		it("gives the root for an empty path", function()
			expect(Path.normalise("")).to.equal("/")
		end)

		it("removes repeated and trailing slashes", function()
			expect(Path.normalise("a//b/")).to.equal("/a/b")
		end)

		it("keeps a path that is already normal", function()
			expect(Path.normalise("/a/b")).to.equal("/a/b")
		end)
	end)

	describe("join", function()
		it("joins a parent and a child", function()
			expect(Path.join("/settings", "appearance")).to.equal("/settings/appearance")
		end)

		it("does not double the slash", function()
			expect(Path.join("/", "/a")).to.equal("/a")
		end)
	end)

	describe("compile", function()
		it("rejects a splat that is not last", function()
			local ok = pcall(Path.compile, "/a/*/b")
			expect(ok).to.equal(false)
		end)

		it("rejects a parameter with no name", function()
			local ok = pcall(Path.compile, "/a/:")
			expect(ok).to.equal(false)
		end)

		it("rejects a parameter name with a hyphen", function()
			local ok = pcall(Path.compile, "/a/:b-c")
			expect(ok).to.equal(false)
		end)
	end)

	describe("match", function()
		it("matches a static path", function()
			expect(Path.match(Path.compile("/today"), "/today")).to.be.ok()
			expect(Path.match(Path.compile("/today"), "/tomorrow")).to.equal(nil)
			expect(Path.match(Path.compile("/today"), "/today/x")).to.equal(nil)
		end)

		it("matches the root", function()
			expect(Path.match(Path.compile("/"), "/")).to.be.ok()
		end)

		it("matches a parameter", function()
			expect(Path.match(Path.compile("/project/:id"), "/project/Work").id).to.equal("Work")
			expect(Path.match(Path.compile("/project/:id"), "/project")).to.equal(nil)
		end)

		it("matches a splat", function()
			expect(Path.match(Path.compile("/files/*"), "/files/a/b/c")["*"]).to.equal("a/b/c")
			expect(Path.match(Path.compile("/files/*"), "/files")["*"]).to.equal("")
		end)

		it("decodes values", function()
			expect(Path.match(Path.compile("/tag/:name"), "/tag/deep%20work").name).to.equal(
				"deep work"
			)
		end)
	end)

	describe("build", function()
		it("fills parameters", function()
			expect(Path.build(Path.compile("/project/:id"), { id = "Work" })).to.equal(
				"/project/Work"
			)
		end)

		it("encodes values", function()
			expect(Path.build(Path.compile("/tag/:name"), { name = "deep work" })).to.equal(
				"/tag/deep%20work"
			)
		end)

		it("gives a message when a parameter is missing", function()
			local built, message = Path.build(Path.compile("/project/:id"), {})
			expect(built).to.equal(nil)
			expect(message).to.be.ok()
		end)
	end)

	describe("query strings", function()
		it("parses a path and its query", function()
			local path, query = Path.parse("/a/b/?tab=open&q=a+b%21#top")
			expect(path).to.equal("/a/b")
			expect(query.tab).to.equal("open")
			expect(query.q).to.equal("a b!")
		end)

		it("formats a query with sorted keys", function()
			expect(Path.format("/a", { b = "2", a = "1" })).to.equal("/a?a=1&b=2")
		end)

		it("leaves out an empty query", function()
			expect(Path.format("/a", {})).to.equal("/a")
		end)
	end)

	describe("score", function()
		it("ranks static above parameter above splat", function()
			local static = Path.compile("/a/b").Score
			local param = Path.compile("/a/:b").Score
			local splat = Path.compile("/a/*").Score
			expect(static > param).to.equal(true)
			expect(param > splat).to.equal(true)
		end)
	end)
end
