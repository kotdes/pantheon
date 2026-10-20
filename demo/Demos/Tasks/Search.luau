--!strict
--[[
	The search field. It goes to a search route.

	Shared state and helpers are on `app`. Each module adds what the ones after it need.
]]
local Common = require(script.Parent.Common)
local peek = Common.peek

return function(app: any)
	local router, scope = app.router, app.scope
	----------------------------------------------------------------------------
	-- Search, in the top strip. It goes to a search route, and the text is the route's
	-- query, so going back leaves the search.
	----------------------------------------------------------------------------

	local searchText = scope:Value("")
	local function onSearch(text: string)
		local searching = peek(router.Route).Name == "search"
		if text ~= "" then
			local target = { Path = "/search", Query = { q = text } }
			if searching then
				router:Replace(target)
			else
				router:Push(target)
			end
		elseif searching then
			if peek(router.CanGoBack) then
				router:Back()
			else
				router:Replace("/list/today")
			end
		end
	end
	-- Leaving the search by any route clears the field.
	table.insert(
		scope,
		scope:Observer(router.Route):onChange(function()
			if peek(router.Route).Name ~= "search" and peek(searchText) ~= "" then
				searchText:set("")
			end
		end)
	)
	local searchField = scope:TextField({
		Placeholder = "Search",
		LeadingIcon = "search",
		Text = searchText,
		Height = 32,
		Size = UDim2.new(1, 0, 0, 32),
		OnChanged = onSearch,
	})

	app.searchField = searchField
end
