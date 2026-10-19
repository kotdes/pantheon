--!strict
if true then
	return
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Pantheon = require(Packages.Pantheon)
local Snapdragon = require(Packages.Snapdragon)
local Fusion = Pantheon.Fusion
local Children = Fusion.Children

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local rootScope = Pantheon.scoped()
local peek = Fusion.peek

local mode = rootScope:Value("Light" :: "Light" | "Dark")
local uiScope: any = nil

local function rebuild()
	if uiScope then
		Fusion.doCleanup(uiScope)
		uiScope = nil
	end

	uiScope = Fusion.innerScope(rootScope)
	local scope = uiScope
	local navDrawerOpen = scope:Value(false)
	local pageName = rootScope:Value("Home" :: string)
	local dragController = nil
	local theme = peek(Pantheon.Theme.createAnimated(scope, mode, { Animate = true })) :: any

	Pantheon.Theme.Provide(theme, function()
		local function close()
			navDrawerOpen:set(false)
		end

		local function pushToPage(name: string)
			pageName:set(name)
			navDrawerOpen:set(false)
		end

		local navDrawer = scope:NavigationDrawer({
			Open = navDrawerOpen,
			Inset = 4,
			CornerRadius = theme.Metrics.RadiusPanel - 4,
			OnClose = close,
			InitialPage = "root",
			Sections = {
				{
					Items = {},
					Children = {
						scope:Frame({
							Name = "TitleBar",
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 0),
							AutomaticSize = Enum.AutomaticSize.Y,
							LayoutOrder = 1,
							Layout = {
								Kind = "List",
								Padding = theme.Metrics.Space2xs,
								SortOrder = Enum.SortOrder.LayoutOrder,
							},
							Padding = { 0, 0, theme.Metrics.Space2xs, 0 },
							[Children] = {
								scope:Frame({
									Name = "TitleBarContent",
									BackgroundTransparency = 1,
									Size = UDim2.new(1, 0, 0, 0),
									AutomaticSize = Enum.AutomaticSize.Y,
									LayoutOrder = 0,
									Layout = {
										Kind = "List",
										SortOrder = Enum.SortOrder.LayoutOrder,
										FillDirection = Enum.FillDirection.Vertical,
									},
									Padding = theme.Metrics.SpaceSm,
									[Children] = {
										scope:Text({
											Text = "Pantheon",
											Variant = "BoldBody",
											Size = UDim2.fromScale(1, 0),
											LayoutOrder = 0,
										}),
										scope:Text({
											Text = "Administration Panel",
											Variant = "Caption",
											Color = theme.Colors.OnSurfaceVariant,
											Size = UDim2.fromScale(1, 0),
											LayoutOrder = 1,
										}),
									},
								}),
								scope:Frame({
									Name = "TitleBarDivider",
									BackgroundTransparency = 1,
									Size = UDim2.new(1, 0, 0, 1),
									LayoutOrder = 1,
									ClipsDescendants = false,
									[Children] = {
										scope:Hydrate(scope:Divider({
											Theme = theme,
										}))({
											Size = UDim2.new(1, 2, 0, 1),
										}),
									},
								}),
							},
						}),
					},
				},

				{
					Items = {
						{
							Text = "Home",
							Leading = "home",
							OnClick = function()
								pushToPage("Home")
							end,
						},
						{
							Text = "Commands",
							Leading = "library",
							OnClick = function()
								pushToPage("Commands")
							end,
						},
						{
							Text = "Players",
							Leading = "users",
							OnClick = function()
								pushToPage("Players")
							end,
						},
						{
							Text = "Settings",
							Leading = "settings",
							Trailing = "chevron-right",
							Page = "settings",
						},
					} :: { any },
					Children = {},
				},
			},
			Children = {
				scope:MenuPage({
					Id = "settings",
					Title = "Settings",
					Children = {
						scope:MenuButton({
							Text = "Sounds",
							Leading = "audio-lines",
							Trailing = scope:Switch({}),
							LayoutOrder = 0,
						}),
						scope:MenuButton({
							Text = "Notifications",
							Leading = "bell",
							Trailing = scope:Switch({}),
							LayoutOrder = 1,
						}),
						scope:MenuButton({
							Text = "Appearance",
							Leading = "moon",
							Trailing = "chevron-right",
							Page = "appearance",
							LayoutOrder = 2,
						}),
						scope:MenuButton({
							Text = "Language",
							Leading = "globe",
							Trailing = "chevron-right",
							Page = "language",
							LayoutOrder = 3,
						}),
					},
				}),
				scope:MenuPage({
					Id = "appearance",
					Title = "Appearance",
					Children = {
						scope:RadioGroup({
							Options = {
								{ Label = "Light", Value = "light" },
								{ Label = "Dark", Value = "dark" },
							},
						}),
					},
				}),
				scope:MenuPage({
					Id = "language",
					Title = "Language",
					Children = {
						scope:RadioGroup({
							Options = {
								{ Label = "English", Value = "english" },
								{ Label = "Spanish", Value = "spanish" },
								{ Label = "French", Value = "french" },
								{ Label = "German", Value = "german" },
								{ Label = "Italian", Value = "italian" },
								{ Label = "Portuguese", Value = "portuguese" },
								{ Label = "Russian", Value = "russian" },
								{ Label = "Turkish", Value = "turkish" },
							},
						}),
					},
				}),
			},
		})
		local appBar = scope:AppBar({
			Title = pageName,
			Leading = scope:IconButton({
				Name = "menu",
				OnClick = function()
					navDrawerOpen:set(true)
				end,
			}),
			Actions = {
				scope:IconButton({ Name = "search" }),
				scope:IconButton({ Name = "x" }),
			},
			Radius = { theme.Metrics.RadiusPanel, 0 },
		})
		local rootWindow = scope:Window({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0.55, 0, 0.7, 0),
			AspectRatio = {
				Ratio = 1.42,
			},
			RailOrientation = "Horizontal",
			AppBar = appBar,
			Overlays = { navDrawer },
			Children = {
				scope:Frame({
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Padding = { theme.Metrics.SpaceMd },
					Layout = {
						Kind = "List",
						Padding = theme.Metrics.SpaceSm,
						FillDirection = Enum.FillDirection.Vertical,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
					},
					[Children] = {
						scope:SegmentedControl({
							LayoutOrder = 2,
							Items = {
								{ Id = "day", Label = "Day" },
								{ Id = "week", Label = "Week" },
								{ Id = "month", Label = "Month" },
							},
						}),
					},
				}),
			},
		})
		dragController = Snapdragon.createDragController(appBar, {
			DragGui = rootWindow,
		})
		scope:New("ScreenGui")({
			Name = "PantheonStoryboard",
			ResetOnSpawn = false,
			Parent = playerGui,
			[Children] = {
				rootWindow,
			},
		})

		dragController:Connect()
	end)
end

rebuild()
rootScope:Observer(mode):onChange(rebuild)
