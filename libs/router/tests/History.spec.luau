--!nocheck
local History = require(script.Parent.Parent.src.History)

return function()
	it("pushes, goes back and goes forward", function()
		local history = History.new("/a")
		history:Push("/b")
		history:Push("/c")
		expect(history:Current()).to.equal("/c")
		expect(history:Go(-1)).to.equal("/b")
		expect(history:CanGo(1)).to.equal(true)
		expect(history:Go(1)).to.equal("/c")
		expect(history:Go(1)).to.equal(nil)
		expect(history:CanGo(-2)).to.equal(true)
		expect(history:CanGo(-3)).to.equal(false)
	end)

	it("drops the entries ahead on a push", function()
		local history = History.new("/a")
		history:Push("/b")
		history:Go(-1)
		history:Push("/c")
		expect(history:CanGo(1)).to.equal(false)
		expect(history:Peek(-1)).to.equal("/a")
	end)

	it("replaces the current entry and keeps to the limit", function()
		local history = History.new("/a", 3)
		history:Replace("/a2")
		expect(history:Current()).to.equal("/a2")
		for _, url in { "/b", "/c", "/d" } do
			history:Push(url)
		end
		expect(history:Peek(-2)).to.equal("/b")
		expect(history:CanGo(-3)).to.equal(false)
	end)
end
