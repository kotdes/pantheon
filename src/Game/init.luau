--!strict
--[[
	In-game HUD components: translucent, scene-facing, and independent of the app theme.
	Same call shape as the main kit: Game.X(scope, props).
]]

return {
	Style = require(script.Style),
	Hotbar = require(script.Hotbar),
	--- Feed a Hotbar from the player's Roblox Backpack: `Game.Backpack(scope)`.
	Backpack = require(script.Backpack).new,
	Fuzzy = require(script.Fuzzy),
}
