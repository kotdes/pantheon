--!strict
--[[
	Tilly gives Roblox Tailwind-style utility classes. It is not a dependency of Pantheon. It is not on
	Wally either, so this demo only runs if you have put Tilly's `src` folder in `demo/vendor/Tilly`
	(that folder is ignored by git):

		git clone https://github.com/imavafe/tilly
		cp -R tilly/src <this repository>/demo/vendor/Tilly
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Pantheon = require(Packages.Pantheon)
local Fusion = Pantheon.Fusion
local Children = Fusion.Children

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local ACCENTS = {
	{ Id = "indigo", Label = "Indigo" },
	{ Id = "emerald", Label = "Emerald" },
	{ Id = "rose", Label = "Rose" },
}

local function findTilly(): any?
	local vendor = script.Parent.Parent:FindFirstChild("vendor")
	return if vendor then vendor:FindFirstChild("Tilly") else nil
end

local function themeFrom(tokens: { [string]: any }, accent: string)
	return Pantheon.Theme.create("Dark", {
		Overrides = {
			Colors = {
				Surface = tokens["color-zinc-900"],
				SurfaceContainer = tokens["color-zinc-800"],
				SurfaceContainerHigh = tokens["color-zinc-800"],
				OnSurface = tokens["color-zinc-50"],
				OnSurfaceVariant = tokens["color-zinc-400"],
			},
		},
		Palette = { primary = tokens[`color-{accent}-500`] },
	})
end

local function buildStyledPanel(tilly: any, accent: string): (ScreenGui, () -> (), any, any)
	local gui = Instance.new("ScreenGui")
	gui.Name = "PantheonTillyStyled"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	local sheet = Instance.new("StyleSheet")
	local link = Instance.new("StyleLink")
	sheet.Parent = link
	link.StyleSheet = sheet
	link.Parent = gui
	local tag, destroyTilly = tilly(sheet)

	local function make(
		className: string,
		classes: string,
		props: { [string]: any },
		parent: Instance
	): any
		local instance = Instance.new(className)
		for key, value in props do
			(instance :: any)[key] = value
		end
		tag(instance, classes)
		instance.Parent = parent
		return instance
	end

	local panel =
		make("Frame", "flex-col gap-3 p-5 bg-zinc-900 rounded-2xl border border-zinc-700", {
			Name = "TillyPanel",
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -24, 0.5, 0),
			Size = UDim2.fromOffset(340, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
		}, gui)

	local bold = Font.new("rbxassetid://16658221428", Enum.FontWeight.Bold)
	make(
		"TextLabel",
		"text-white text-xl",
		{ Text = "Styled with Tilly", FontFace = bold, LayoutOrder = 1 },
		panel
	)
	make("TextLabel", "text-zinc-400 text-sm", {
		Text = "Hi David Bazooka if you see this you owe me 5000000 robux",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2,
	}, panel)

	local swatches = make("Frame", "flex gap-2", {
		Size = UDim2.new(1, 0, 0, 40),
		LayoutOrder = 3,
	}, panel)
	for index, swatch in { "indigo", "emerald", "rose" } do
		make(
			"Frame",
			`bg-{swatch}-500 rounded-lg`,
			{ Size = UDim2.fromOffset(40, 40), LayoutOrder = index },
			swatches
		)
	end

	local clicks = 0
	local count = make(
		"TextLabel",
		"text-zinc-300 text-sm",
		{ Text = "Not clicked yet", LayoutOrder = 5 },
		panel
	)
	local button = make(
		"TextButton",
		`bg-{accent}-500 hover:bg-{accent}-400 text-white px-4 py-2 rounded-lg`,
		{ Text = "Click me", FontFace = bold, LayoutOrder = 4 },
		panel
	)
	button.Activated:Connect(function()
		clicks += 1
		count.Text = `Clicked {clicks} time{if clicks == 1 then "" else "s"}`
	end)

	return gui, destroyTilly, tag, panel
end

local function start(): () -> ()
	local rootScope = Pantheon.scoped()
	local tillyModule = findTilly()

	local current: { gui: any, panel: any, scope: any, destroyTilly: (() -> ())? } = {
		gui = nil,
		panel = nil,
		scope = nil,
		destroyTilly = nil,
	}

	local function teardown()
		if current.scope then
			Fusion.doCleanup(current.scope)
			current.scope = nil
		end
		if current.destroyTilly then
			current.destroyTilly()
			current.destroyTilly = nil
		end
		if current.gui then
			current.gui:Destroy()
			current.gui = nil
		end
		if current.panel then
			current.panel:Destroy()
			current.panel = nil
		end
	end

	if tillyModule == nil then
		local theme = Pantheon.Theme.create("Dark")
		Pantheon.Theme.Provide(theme, function()
			local scope = Fusion.innerScope(rootScope) :: any
			current.scope = scope
			current.gui = scope:New("ScreenGui")({
				Name = "PantheonTilly",
				ResetOnSpawn = false,
				Parent = playerGui,
				[Children] = {
					scope:Window({
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromOffset(440, 260),
						Children = {
							scope:EmptyState({
								Title = "Tilly is not installed",
								Subtitle = "This demo only runs if you have put Tilly's `src` folder in `demo/vendor/Tilly`.",
							}),
						},
					}),
				},
			})
		end)
		return function()
			teardown()
			Fusion.doCleanup(rootScope)
		end
	end

	local tilly = require(tillyModule :: ModuleScript) :: any
	local tokens = (require((tillyModule :: any).tokens :: ModuleScript) :: any).all

	local function build(accent: string)
		teardown()
		local theme = themeFrom(tokens, accent)

		local styledGui, destroyTilly, tag, panel = buildStyledPanel(tilly, accent)
		current.panel, current.destroyTilly = styledGui, destroyTilly

		Pantheon.Theme.Provide(theme, function()
			local scope = Fusion.innerScope(rootScope) :: any
			current.scope = scope
			current.gui = scope:New("ScreenGui")({
				Name = "PantheonTilly",
				ResetOnSpawn = false,
				Parent = playerGui,
				[Children] = {
					scope:Window({
						AnchorPoint = Vector2.new(0, 0.5),
						Position = UDim2.new(0, 24, 0.5, 0),
						Size = UDim2.fromOffset(380, 400),
						Children = {
							scope:Frame({
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),
								Padding = { theme.Metrics.SpaceMd },
								Layout = {
									Kind = "List",
									Padding = theme.Metrics.SpaceSm,
									SortOrder = Enum.SortOrder.LayoutOrder,
								},
								[Children] = {
									scope:Text({
										Text = "Tilly demo",
										Variant = "Headline",
										LayoutOrder = 1,
									}),
									scope:SegmentedControl({
										Selected = accent,
										LayoutOrder = 3,
										Items = ACCENTS,
										OnChanged = function(id: string)
											task.defer(build, id)
										end,
									}),
									scope:Switch({
										Label = "Notifications",
										Checked = true,
										Size = UDim2.new(1, 0, 0, 40),
										LayoutOrder = 4,
									}),
									scope:TextField({
										Placeholder = "Type something",
										LayoutOrder = 5,
									}),
									scope:Button({
										Text = "Save",
										Size = UDim2.new(1, 0, 0, 40),
										Variant = "Filled",
										LayoutOrder = 6,
									}),
								},
							}),
						},
					}),
				},
			})

			local tw = Pantheon.Directives.Tag(tag)
			local heading = Instance.new("TextLabel")
			heading.Text = "[tw] on Pantheon components."
			heading.Size = UDim2.new(1, 0, 0, 0)
			heading.AutomaticSize = Enum.AutomaticSize.Y
			heading.LayoutOrder = 6
			tag(heading, "text-zinc-400 text-sm")
			heading.Parent = panel
			local tagged = scope:Button({
				Text = "bg-rose-500 on a Button",
				Variant = "Filled",
				LayoutOrder = 7,
				[tw] = "bg-rose-500",
			})
			tagged.Parent = panel
			local bordered = scope:Text({
				Text = "border border-rose-500 on a Text",
				LayoutOrder = 8,
				[tw] = "border border-rose-500 p-2 rounded-lg",
			})
			bordered.Parent = panel
		end)
	end

	build("indigo")

	return function()
		teardown()
		Fusion.doCleanup(rootScope)
	end
end

return {
	Name = "Tilly",
	Description = "A demo of Pantheon components styled with Tilly",
	Icon = "paintbrush",
	start = start,
}
