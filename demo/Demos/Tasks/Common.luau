--!strict
--[[
	What every part of the Tasks demo needs: Pantheon, Fusion, the router, TopbarPlus and the
	player's GUI.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Pantheon = require(Packages.Pantheon)
local Fusion = Pantheon.Fusion

return {
	Pantheon = Pantheon,
	Fusion = Fusion,
	Router = require(Packages:WaitForChild("PantheonRouter")),
	TopbarIcon = require(ReplicatedStorage:WaitForChild("DevPackages").TopbarPlus),
	Children = Fusion.Children,
	peek = Fusion.peek,
	playerGui = Players.LocalPlayer:WaitForChild("PlayerGui"),
}
