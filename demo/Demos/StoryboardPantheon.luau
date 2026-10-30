--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Pantheon = require(Packages.Pantheon)
local Storyboard = require(script.Parent:WaitForChild("Storyboard")) :: any

-- The same storyboard as `Storyboard`, with the Pantheon blueprint for its theme.
return {
	Name = "Storyboard (Pantheon)",
	Description = "Every component, with the Pantheon blueprint",
	Icon = "layout-grid",
	start = function()
		return Storyboard.startWith(Pantheon.Theme.Blueprints.Pantheon)
	end,
}
