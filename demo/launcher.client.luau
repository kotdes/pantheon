--!strict
--[[
	Demo launcher. A "Demos" icon in the Roblox top bar opens a menu. Choose a demo to start
	it, and choose another to stop it and start that one instead. "Close demo" stops it.

	Each demo in `Demos` returns `{ Name, Description, Icon, start }`. `start` builds the demo
	and returns a function that removes it again.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Pantheon = require(Packages.Pantheon)
local TopbarIcon = require(ReplicatedStorage:WaitForChild("DevPackages").TopbarPlus)
local Fusion = Pantheon.Fusion
local Children = Fusion.Children

type Demo = {
	Name: string,
	Description: string,
	Icon: string,
	start: () -> () -> (),
}

local folder = script.Parent:WaitForChild("Demos")
local demos: { Demo } = {
	require(folder:WaitForChild("Storyboard")) :: any,
	require(folder:WaitForChild("StoryboardPantheon")) :: any,
	require(folder:WaitForChild("Tasks")) :: any,
	require(folder:WaitForChild("Admin")) :: any,
	require(folder:WaitForChild("Tilly")) :: any,
}

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local rootScope = Pantheon.scoped() :: any

local running = rootScope:Value("")
local stopCurrent: (() -> ())? = nil

local function stop()
	local current = stopCurrent
	stopCurrent = nil
	running:set("")
	if current then
		local ok, err = xpcall(current :: any, debug.traceback)
		if not ok then
			warn(`[launcher] could not stop the demo cleanly: {err}`)
		end
	end
end

local function launch(demo: Demo)
	stop()
	local ok, result = xpcall(demo.start, debug.traceback)
	if ok then
		stopCurrent = result :: () -> ()
		running:set(demo.Name)
	else
		warn(`[launcher] could not start {demo.Name}: {result}`)
	end
end

local panelOpen = rootScope:Value(false)
local icon = TopbarIcon.new():setName("Demos"):setLabel("Demos"):setOrder(0):setLeft()
icon:bindEvent("selected", function()
	panelOpen:set(true)
end)
icon:bindEvent("deselected", function()
	panelOpen:set(false)
end)

-- The launcher has its own theme, so it looks the same whichever demo is running.
Pantheon.Theme.Provide(Pantheon.Theme.create("Dark"), function()
	local items: { any } = {}
	for _, demo in demos do
		table.insert(items, {
			Text = demo.Name,
			Leading = demo.Icon,
			Selected = rootScope:Computed(function(use: any)
				return use(running) == demo.Name
			end),
			OnClick = function()
				launch(demo)
			end,
		})
	end

	local sections: { any } = {
		{ Title = "Demos", Icon = "layout-grid", Items = items },
		{ Items = { { Text = "Close demo", Leading = "x", Color = "error", OnClick = stop } } },
	}

	local menu = rootScope:Menu({
		Embedded = true,
		Open = panelOpen,
		Size = UDim2.fromOffset(240, 0),
		Sections = sections,
		-- Runs after a row is pressed, so the menu closes once you have chosen.
		OnClose = function()
			icon:deselect()
		end,
	})

	rootScope:New("ScreenGui")({
		Name = "PantheonLauncher",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 2000,
		Parent = playerGui,
		[Children] = {
			rootScope:Apply(menu)({
				Position = UDim2.fromOffset(8, 52),
			}),
		},
	})
end)

-- Open the menu at the start, so you can choose a demo.
icon:select()

print(`pantheon demo launcher: {#demos} demos`)
