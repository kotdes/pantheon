--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Pantheon = require(Packages.Pantheon)
local Fusion = Pantheon.Fusion
local Children = Fusion.Children
local peek = Fusion.peek

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local rootScope = Pantheon.scoped()

-- Dev tools: F8 opens the panel. The pointer button picks an element on screen.
Pantheon.Flags.DevTools = true
Pantheon.DevTools.mount()

local mode = rootScope:Value("Light" :: "Light" | "Dark")

-- The theme as a state, for Flags.ReactiveTheme. Set the flag to false to go back to rebuilding.
Pantheon.Flags.ReactiveTheme = true
local sharedTheme = Pantheon.Theme.createAnimated(rootScope, mode, { Animate = true })
local scrollY = rootScope:Value(0)
local railOrientation = rootScope:Value("Horizontal" :: "Vertical" | "Horizontal")
local animateTheme = rootScope:Value(true)
local sheetOpen = rootScope:Value(false)
local refreshing = rootScope:Value(false)
local uiScope: any = nil
-- Window position lives outside the rebuild so dragging survives theme / layout switches.
local windowPosition = rootScope:Value(UDim2.fromScale(0.5, 0.5))
local windowSize = rootScope:Value(UDim2.new(0.5, 0, 0.88, 0))

-- State that has to survive a rebuild (theme switch, rail layout) lives here, outside the view.
local persisted: { [string]: any } = {}
local function persist(name: string, initial: any): any
	local value = persisted[name]
	if value == nil then
		value = rootScope:Value(initial)
		persisted[name] = value
	end
	return value
end
local generation = 0
-- A made-up tree for the Explorer. Built once, like the other state that outlives a rebuild.
local demoTree = Instance.new("Model")
demoTree.Name = "Workspace"
do
	local function make(class: string, name: string, parent: Instance): Instance
		local instance = Instance.new(class)
		instance.Name = name
		instance.Parent = parent
		return instance
	end
	local world = make("Folder", "World", demoTree)
	for index = 1, 5 do
		make("Part", `Tile{index}`, world)
	end
	local guide = make("Model", "Guide", demoTree)
	make("Humanoid", "Humanoid", guide)
	make("Part", "Head", guide)
	make("Script", "Brain", guide)
end
-- Components keep their own state (selected tab, switches, sliders…) in this store, so a
-- rebuild picks it up again instead of resetting it.
local persistStore = Pantheon.Persist.createStore(rootScope)
local V = Pantheon.Validators

local function appendSection(scope: any, into: { any }, title: string, order: number, kids: { any })
	local children: { Instance } = {
		scope:Text({ Text = title, Variant = "Title", LayoutOrder = 0 }),
	}
	for _, kid in kids do
		if kid ~= nil then
			table.insert(children, kid :: Instance)
		end
	end
	table.insert(
		into,
		scope:Frame({
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = order,
			-- Do not clip: UIStroke / slider thumbs bleed past layout bounds.
			ClipsDescendants = false,
			Layout = {
				Kind = "List",
				Padding = 8,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			[Children] = children,
		})
	)
end

local function rebuild()
	-- Keep the old UI on screen; the new one fades in over it, then the old one goes.
	local previous = uiScope
	generation += 1

	uiScope = Fusion.innerScope(rootScope)
	local scope = uiScope
	-- Apps can use Theme.createAnimated(scope, mode, { Animate = true }) for live color blends.
	-- With Flags.ReactiveTheme the theme is a state: the interface follows it in place, so a
	-- change of mode doesn't rebuild anything.
	local reactive = Pantheon.Flags.ReactiveTheme
	local themeSource: any = if reactive
		then sharedTheme
		elseif peek(animateTheme) then peek(
			Pantheon.Theme.createAnimated(scope, mode, { Animate = true }) :: any
		)
		else Pantheon.Theme.create(peek(mode), { RespectAccessibility = true })
	local theme = if reactive then Pantheon.Theme.reactive(themeSource) else themeSource

	Pantheon.Persist.Provide(persistStore, Pantheon.Theme.Provide, themeSource, function()
		local drawerOpen = persist("drawerOpen", false)
		local promptOpen = persist("promptOpen", false)
		local avatarMenuOpen = persist("avatarMenuOpen", false)
		local popoverOpen = persist("popoverOpen", false)
		local notifyOn = persist("notifyOn", true)
		local rows = {}
		for i = 1, 200 do
			table.insert(rows, {
				id = i,
				name = "Row " .. i,
				role = if i % 2 == 0 then "Mod" else "User",
			})
		end
		local tableRows = scope:Value(rows)
		local sections = {}

		local function close()
			drawerOpen:set(false)
		end

		local overlayLayer = scope:Frame({
			Name = "OverlayLayer",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 50,
		})

		local host = scope:SnackbarHost({ Layer = overlayLayer })
		local avatarBtn
		local popoverBtn
		local themeBtn

		appendSection(scope, sections, "Typography & actions", 1, {
			scope:Text({ Text = "Display", Variant = "Display", LayoutOrder = 1 }),
			scope:Text({
				Text = "Body copy for Cadence/Tithe surfaces.",
				Variant = "Body",
				LayoutOrder = 2,
			}),
			scope:Button({ Text = "Primary", Variant = "Primary", LayoutOrder = 3 }),
			scope:Button({ Text = "Tonal", Variant = "Tonal", LayoutOrder = 4 }),
			scope:Button({ Text = "Outlined", Variant = "Outlined", LayoutOrder = 5 }),
			scope:Button({ Text = "Disabled", Disabled = true, LayoutOrder = 6 }),
			scope:Chip({ Text = "Chip", Selected = true, LayoutOrder = 7 }),
		})
		appendSection(scope, sections, "Cadence controls", 7, {
			scope:SettingsList({
				LayoutOrder = 1,
				Header = "Account",
				Items = {
					{
						Title = "Profile",
						Subtitle = "Name, email, avatar",
						Icon = "user",
						OnClick = function() end,
					},
					{
						Title = "Notifications",
						Subtitle = "Push & email",
						Icon = "bell",
						OnClick = function() end,
					},
					{
						Title = "Animate theme",
						Subtitle = "Use Theme.createAnimated in apps",
						Icon = "sparkles",
						Trailing = scope:Switch({
							Checked = peek(animateTheme),
							OnChanged = function(on)
								animateTheme:set(on)
							end,
						}),
						ShowChevron = false,
					},
					{
						Title = "Dark mode",
						Subtitle = "Appearance",
						Icon = "moon",
						Trailing = scope:Switch({
							Checked = peek(mode) == "Dark",
							OnChanged = function(on)
								mode:set(if on then "Dark" else "Light")
							end,
						}),
						ShowChevron = false,
					},
				} :: { any },
			}),
			scope:SegmentedControl({
				LayoutOrder = 2,
				Items = {
					{ Id = "day", Label = "Day" },
					{ Id = "week", Label = "Week" },
					{ Id = "month", Label = "Month" },
				},
			}),
			scope:StarRating({ LayoutOrder = 3, Value = 4 }),
			scope:MultiSelect({
				LayoutOrder = 4,
				Layer = overlayLayer,
				Label = "Tags",
				Display = "Chips",
				Options = {
					{ Value = "a", Label = "Alpha" },
					{ Value = "b", Label = "Beta" },
					{ Value = "c", Label = "Gamma" },
				},
			}),
			scope:MultiSelect({
				LayoutOrder = 4,
				Layer = overlayLayer,
				Label = "Tags (count)",
				Display = "Count",
				Options = {
					{ Value = "a", Label = "Alpha" },
					{ Value = "b", Label = "Beta" },
					{ Value = "c", Label = "Gamma" },
				},
			}),
			scope:Collapsible({
				LayoutOrder = 5,
				Title = "Advanced",
				Children = {
					scope:Text({ Text = "Hidden until expanded.", Variant = "Body" }),
				},
			}),
			scope:TreeView({
				LayoutOrder = 6,
				Nodes = {
					{
						Id = "src",
						Label = "src",
						Icon = "folder",
						Children = {
							{ Id = "btn", Label = "Button.luau", Icon = "file" },
							{
								Id = "theme",
								Label = "Theme",
								Icon = "folder",
								Children = {
									{ Id = "init", Label = "init.luau", Icon = "file" },
								},
							},
						},
					},
				},
			}),
			scope:Button({
				Text = "Open app sheet",
				LeadingIcon = "panel-bottom",
				LayoutOrder = 7,
				OnClick = function()
					sheetOpen:set(true)
				end,
			}),
			scope:TextField({
				LayoutOrder = 8,
				Label = "Email",
				LeadingIcon = "mail",
				Placeholder = "you@game.com",
				Validators = { V.required(), V.email() },
			}),
			scope:Chip({ Text = "Filter", LeadingIcon = "filter", LayoutOrder = 9 }),
			scope:ChoiceGroup({
				LayoutOrder = 10,
				Label = "Plan",
				Variant = "Segmented",
				Options = {
					{ Value = "free", Label = "Free" },
					{ Value = "pro", Label = "Pro" },
				},
			}),
		})
		appendSection(scope, sections, "Forms", 2, {
			scope:TextField({
				Label = "Name (kept across theme switches)",
				Placeholder = "Type, then switch theme…",
				LayoutOrder = 1,
			}),
			scope:TextField({
				Label = "Notes",
				Placeholder = "Multiline…",
				Multiline = true,
				MinLines = 3,
				MaxLines = 6,
				Resize = "Y",
				LayoutOrder = 1,
			}),
			scope:TextField({
				Label = "Email",
				Placeholder = "you@game.com",
				Error = "Required field",
				LayoutOrder = 1,
			}),
			scope:Checkbox({ Label = "Accept", LayoutOrder = 2 }),
			scope:Checkbox({ Label = "Disabled", Disabled = true, LayoutOrder = 2 }),
			scope:Switch({ Label = "Enabled", LayoutOrder = 3 }),
			scope:Switch({ Label = "Disabled", Disabled = true, Checked = true, LayoutOrder = 3 }),
			scope:RadioGroup({
				LayoutOrder = 4,
				Options = {
					{ Value = "a", Label = "Alpha" },
					{ Value = "b", Label = "Beta" },
				},
			}),
			scope:Select({
				LayoutOrder = 5,
				Label = "Role",
				Layer = overlayLayer,
				Options = {
					{ Value = "mod", Label = "Moderator" },
					{ Value = "admin", Label = "Admin" },
				},
			}),
			scope:Slider({ Label = "Level", Min = 0, Max = 10, Step = 1, LayoutOrder = 6 }),
			scope:RangeSlider({ Min = 0, Max = 100, LayoutOrder = 7 }),
		})
		local demoGradient = scope:New("UIGradient")({}) :: UIGradient
		local counter = persist("counter", 1280)
		local tipOpen = persist("tipOpen", false)
		local tipTarget = scope:Button({ Text = "New feature", Variant = "Tonal", LayoutOrder = 1 })
		scope:Coachmark({
			Layer = overlayLayer,
			Target = tipTarget,
			Open = tipOpen,
			Step = "1 of 1",
			Title = "Meet the new feature",
			Text = "This button does something new. Tap it to try it out.",
			ActionText = "Got it",
		})
		appendSection(scope, sections, "Feedback", 3, {
			scope:Alert({
				Title = "Info",
				Text = "Opaque MD3 alert.",
				Tone = "Info",
				LayoutOrder = 1,
			}),
			scope:Frame({
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = 8,
				},
				[Children] = ({
					scope:NumberSpinner({
						Value = counter,
						Prefix = "$",
						Decimals = 2,
						TextSize = 36,
						Digits = 6,
						LayoutOrder = 1,
					}) :: Instance,
					scope:Button({
						Text = "+",
						LayoutOrder = 2,
						OnClick = function()
							counter:set(peek(counter) + math.random(1, 1500) + math.random())
						end,
					}),
					scope:Button({
						Text = "−",
						LayoutOrder = 3,
						OnClick = function()
							counter:set(
								math.max(0, peek(counter) - math.random(1, 1500) - math.random())
							)
						end,
					}),
					scope:NumberSpinner({
						Value = counter,
						Style = "Roll",
						Decimals = 0,
						TextSize = 22,
						Digits = 5,
						LayoutOrder = 4,
					}),
				} :: any) :: any,
			}),
			scope:Frame({
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = 8,
				},
				[Children] = {
					tipTarget,
					scope:Button({
						Text = "Show tip",
						Variant = "Text",
						LayoutOrder = 2,
						OnClick = function()
							tipOpen:set(true)
						end,
					}),
				},
			}),
			scope:Frame({
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = 8,
				},
				[Children] = {
					scope:Button({
						Text = "Stack toasts",
						Variant = "Tonal",
						LayoutOrder = 1,
						OnClick = function()
							for i = 1, 3 do
								task.delay((i - 1) * 0.25, function()
									host.Show("Toast " .. i, "Undo", nil, { Duration = 3 + i })
								end)
							end
						end,
					}),
					scope:Button({
						Text = "Clear toasts",
						Variant = "Text",
						LayoutOrder = 2,
						OnClick = function()
							host.Clear()
						end,
					}),
				},
			}),
			scope:Frame({
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = 8,
				},
				[Children] = {
					scope:LoadingIndicator({ SizePx = 56, Contained = true, LayoutOrder = 1 }),
					scope:LoadingIndicator({
						SizePx = 40,
						Shapes = { "Triangle", "Diamond", "Gem", "Fan" },
						LayoutOrder = 2,
					}),
				},
			}),
			scope:Progress({ Value = 0.55, Mode = "Determinate", LayoutOrder = 2 }),
			scope:Progress({ Mode = "Indeterminate", LayoutOrder = 2 }),
			scope:Progress({ Value = 0.3, Buffer = 0.65, Mode = "Buffering", LayoutOrder = 2 }),
			scope:LoadingIndicator({ SizePx = 36, LayoutOrder = 2 }),
			scope:LoadingIndicator({ SizePx = 48, Contained = true, LayoutOrder = 2 }),
			scope:LoadingIndicator({ SizePx = 36, Kind = "M2Spinner", LayoutOrder = 2 }),
			scope:LoadingIndicator({
				SizePx = 64,
				Shapes = {
					"Oval",
					"Pill",
					"Triangle",
					"Arrow",
					"Fan",
					"Diamond",
					"Clamshell",
					"Pentagon",
					"Gem",
					"Sunny",
					"VerySunny",
					"SoftBurst",
					"Cookie4",
					"Cookie6",
					"Cookie7",
					"Cookie9",
					"Cookie12",
					"Burst",
				},
				LayoutOrder = 2,
			}),
			scope:Frame({
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = 16,
				},
				[Children] = {
					scope:LoadingIndicator({ Kind = "Beachball", SizePx = 36 }),
					scope:LoadingIndicator({ Kind = "Dots", SizePx = 36 }),
					scope:LoadingIndicator({ Kind = "Bars", SizePx = 36 }),
					scope:LoadingIndicator({ Kind = "Ripple", SizePx = 36 }),
				},
			}),
			scope:Frame({
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = 16,
				},
				[Children] = {
					scope:LoadingIndicator({ Kind = "Orbit", SizePx = 36 }),
					scope:LoadingIndicator({ Kind = "Gnome", SizePx = 36 }),
					scope:LoadingIndicator({
						Kind = "Icon",
						Icon = "hourglass",
						Motion = "Flip",
						SizePx = 28,
					}),
					scope:LoadingIndicator({
						Kind = "Icon",
						Icon = "settings",
						Motion = "Spin",
						SizePx = 28,
					}),
				},
			}),
			scope:Progress({ Variant = "Circular", Value = 0.65, SizePx = 48, LayoutOrder = 2 }),
			scope:Progress({
				Variant = "Circular",
				Style = "Classic",
				Value = 0.65,
				SizePx = 48,
				LayoutOrder = 2,
			}),
			-- Conical-gradient calibration (Studio beta): the ring below should fill from 12 o'clock
			-- round to 3 o'clock. If it's rotated or mirrored, adjust Pantheon.Flags.ConicalRotation /
			-- ConicalClockwise.
			scope:Text({
				Text = "Conical check: 25% should fill 12 → 3 o'clock",
				Variant = "Label",
				LayoutOrder = 2,
			}),
			scope:Progress({ Variant = "Circular", Value = 0.25, SizePx = 48, LayoutOrder = 2 }),
			scope:Frame({
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.XY,
				LayoutOrder = 2,
				Visible = refreshing,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = 8,
				},
				[Children] = {
					scope:LoadingIndicator({ SizePx = 22 }),
					scope:Text({ Text = "Refreshing…", Variant = "Label" }),
				},
			}),
			scope:Icon({ Name = "sparkles", IconSize = 28, LayoutOrder = 2 }),
			scope:Badge({
				LayoutOrder = 3,
				Count = 3,
				Content = scope:IconButton({ Name = "bell" }),
			}),
			scope:Button({
				Text = "Toast",
				LayoutOrder = 4,
				OnClick = function()
					host.Show("Saved successfully")
				end,
			}),
			scope:Button({
				Text = "Open prompt",
				Variant = "Outlined",
				LayoutOrder = 5,
				OnClick = function()
					promptOpen:set(true)
				end,
			}),
			scope:Text({
				Text = "Pull down on the main scroll to refresh.",
				Variant = "Label",
				LayoutOrder = 6,
			}),
		})
		appendSection(scope, sections, "Navigation", 4, {
			scope:Breadcrumbs({
				LayoutOrder = 1,
				Items = {
					{ Label = "Home" },
					{ Label = "Library" },
					{ Label = "Catalog" },
				},
			}),
			scope:Tabs({
				LayoutOrder = 2,
				Items = {
					{ Id = "one", Label = "One" },
					{ Id = "two", Label = "Two" },
				},
			}),
			scope:Pagination({ PageCount = 5, LayoutOrder = 3 }),
			scope:Card({
				Title = "Card",
				Subtitle = "Elevated surface",
				LayoutOrder = 4,
			}),
			scope:Divider({ LayoutOrder = 5 }),
			scope:Button({
				Text = scope:Computed(function(use)
					return if use(railOrientation) == "Vertical"
						then "Rail → Horizontal"
						else "Rail → Vertical"
				end),
				Variant = "Tonal",
				LayoutOrder = 6,
				OnClick = function()
					railOrientation:set(
						if peek(railOrientation) == "Vertical" then "Horizontal" else "Vertical"
					)
					rebuild()
				end,
			}),
			(function()
				popoverBtn = scope:Button({
					Text = "Open popover",
					Variant = "Tonal",
					LayoutOrder = 7,
					OnClick = function()
						popoverOpen:set(true)
					end,
				})
				return popoverBtn
			end)(),
			(function()
				avatarBtn = scope:Button({
					Text = "Avatar menu",
					Variant = "Outlined",
					LayoutOrder = 8,
					OnClick = function()
						avatarMenuOpen:set(true)
					end,
				})
				return avatarBtn
			end)(),
		})
		appendSection(scope, sections, "Pickers", 5, {
			scope:DatePicker({ LayoutOrder = 1 }),
			scope:TimePicker({ LayoutOrder = 2 }),
			scope:ColorPicker({ LayoutOrder = 3 }),
			-- Hue ring (needs conical gradients; otherwise the square), chosen tabs.
			scope:ColorPicker({
				LayoutOrder = 4,
				Area = "Wheel",
				Modes = { "Spectrum", "Sliders", "Grid" },
				Models = { "HSB", "LAB", "Hex" },
			}),
			-- Gradient editor: the result drives a UIGradient live.
			scope:New("Frame")({
				Name = "GradientPreview",
				LayoutOrder = 5,
				BackgroundColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(1, 0, 0, 56),
				[Children] = {
					scope:New("UICorner")({ CornerRadius = UDim.new(0, theme.Metrics.RadiusSm) }),
					demoGradient,
				},
			}),
			scope:GradientPicker({
				LayoutOrder = 6,
				Layer = overlayLayer,
				OnChanged = function(
					colors: ColorSequence,
					transparency: NumberSequence,
					rotation: number,
					offset: Vector2
				)
					demoGradient.Color = colors
					demoGradient.Transparency = transparency
					demoGradient.Rotation = rotation
					demoGradient.Offset = offset
				end,
			}),
		})
		-- Tools for plugins: number fields, toolbars, dock panes, curves and the Explorer tree.
		local studioFilter = persist("studioFilter", "")
		local snapOn = persist("snapOn", true)
		local studioCurve = persist(
			"studioCurve",
			NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.4, 0.8),
				NumberSequenceKeypoint.new(1, 0.2),
			})
		)
		local function pane(text: string): Instance
			return scope:Frame({
				BackgroundTransparency = 1,
				Padding = { 8 },
				[Children] = scope:Text({ Text = text, Variant = "Label" }),
			})
		end
		appendSection(scope, sections, "Studio tools", 9, {
			scope:NumberField({
				Label = "X",
				Value = persist("fieldX", 0),
				Suffix = "px",
				LayoutOrder = 1,
			}),
			scope:NumberField({
				Label = "α",
				Value = persist("fieldAlpha", 0.5),
				Min = 0,
				Max = 1,
				Step = 0.01,
				LayoutOrder = 2,
			}),
			scope:Toolbar({
				Layer = overlayLayer,
				LayoutOrder = 3,
				Items = {
					{
						Id = "select",
						Icon = "mouse-pointer",
						Tooltip = "Select",
						Shortcut = "V",
						Toggle = true,
						Toggled = true,
					},
					{
						Id = "move",
						Icon = "move-3d",
						Tooltip = "Move",
						Shortcut = "W",
						Toggle = true,
					},
					{ Separator = true },
					{
						Id = "snap",
						Icon = "sliders-horizontal",
						Text = "Snap",
						Toggle = true,
						Toggled = snapOn,
					},
					{ Spacer = true },
					{ Id = "play", Icon = "play", Text = "Play" },
				},
			}),
			scope:StatusBar({
				Layer = overlayLayer,
				LayoutOrder = 4,
				Start = { { Icon = "check", Text = "Ready", Tone = "Success" } } :: { any },
				End = {
					{
						Icon = "triangle-alert",
						Text = "2 warnings",
						Tone = "Warning",
						Tooltip = "Open the output",
						OnClick = function() end,
					},
				} :: { any },
			}),
			scope:Frame({
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 200),
				LayoutOrder = 5,
				[Children] = scope:SplitPane({
					Panes = {
						pane("Explorer"),
						scope:SplitPane({
							Orientation = "Vertical",
							Panes = { pane("Output"), pane("Properties") },
						}),
					},
					Ratios = { 1, 2 },
				}),
			}),
			scope:CurveEditor({ Value = studioCurve, LayoutOrder = 6 }),
			scope:TextField({
				Placeholder = "Filter the tree",
				Text = studioFilter,
				LeadingIcon = "search",
				LayoutOrder = 7,
			}),
			scope:Frame({
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 220),
				LayoutOrder = 8,
				[Children] = scope:Explorer({
					Roots = { demoTree },
					Filter = studioFilter,
					AllowReparent = true,
				}),
			}),
		})
		appendSection(scope, sections, "Data", 6, {
			scope:Avatar({ Initials = "EU", LayoutOrder = 1 }),
			scope:Frame({
				Size = UDim2.new(1, 0, 0, 220),
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				[Children] = {
					scope:DataTable({
						Columns = {
							{ Id = "id", Title = "Id", Width = 60 },
							{ Id = "name", Title = "Name", Width = 140 },
							{ Id = "role", Title = "Role", Width = 100 },
						},
						Rows = tableRows,
						Size = UDim2.fromScale(1, 1),
					}),
				},
			}),
			scope:Frame({
				Size = UDim2.new(1, 0, 0, 160),
				BackgroundTransparency = 1,
				LayoutOrder = 3,
				[Children] = {
					scope:VirtualList({
						ItemCount = 1000,
						ItemHeight = 28,
						Size = UDim2.fromScale(1, 1),
						RenderItem = function(rowScope, index)
							return rowScope:TextLabel({
								BackgroundColor3 = theme.Colors.SurfaceContainer,
								Text = "Virtual row " .. index,
								TextColor3 = theme.Colors.OnSurface,
								FontFace = theme.Fonts.Body,
								TextSize = 12,
								TextXAlignment = Enum.TextXAlignment.Left,
								Padding = { 4 },
							})
						end,
					}),
				},
			}),
			scope:EmptyState({
				Title = "Nothing here",
				Subtitle = "Empty state sample",
				LayoutOrder = 4,
				Action = { Text = "Retry", Variant = "Tonal" },
			}),
		})

		scope:Prompt({
			Layer = overlayLayer,
			Title = "Discard changes?",
			Body = "Your edits will be lost. This action cannot be undone.",
			Icon = "triangle-alert",
			Open = promptOpen,
			ConfirmText = "Discard",
			Destructive = true,
			OnClose = function()
				promptOpen:set(false)
			end,
			OnConfirm = function()
				promptOpen:set(false)
				host.Show("Discarded")
			end,
		})
		scope:NavigationDrawer({
			Layer = overlayLayer,
			Open = drawerOpen,
			Title = "Cadence",
			Subtitle = "pantheon catalog",
			AvatarInitials = "EU",
			Inset = 4,
			OnClose = function()
				drawerOpen:set(false)
			end,
			RootPage = "root",
			Sections = {
				{
					Items = {
						{ Text = "Home", Leading = "home", OnClick = close },
						{ Text = "Library", Leading = "library", OnClick = close },
						{ Text = "Search", Leading = "search", OnClick = close },
					},
				},
				{
					Title = "Account",
					Icon = "user",
					Collapsible = true,
					Expanded = true,
					Items = {
						{ Text = "Profile", Leading = "circle-user", OnClick = close },
						{
							Text = "Settings",
							Leading = "settings",
							Trailing = "chevron-right",
							Page = "settings",
						},
						{
							Text = "Sign out",
							Leading = "log-out",
							Color = "error",
							OnClick = close,
						},
					} :: { any },
				},
			},
			Children = {
				scope:MenuPage({
					Id = "settings",
					Title = "Settings",
					Children = {
						scope:MenuButton({
							Text = "Notifications",
							Leading = "bell",
							Trailing = scope:Switch({ Checked = notifyOn }),
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
		scope:Popover({
			Layer = overlayLayer,
			Open = popoverOpen,
			Target = popoverBtn,
			Placement = "Bottom",
			OnClose = function()
				popoverOpen:set(false)
			end,
			Items = {
				{
					Text = "Action A",
					OnClick = function()
						host.Show("Action A")
					end,
				},
				{
					Text = "Action B",
					OnClick = function()
						host.Show("Action B")
					end,
				},
				{ Text = "Disabled", Disabled = true },
			} :: { any },
		})
		scope:AvatarMenu({
			Layer = overlayLayer,
			Open = avatarMenuOpen,
			Target = avatarBtn,
			Initials = "EU",
			Name = "Pantheon User",
			Subtitle = "you@game.com",
			OnClose = function()
				avatarMenuOpen:set(false)
			end,
			Items = {
				{
					Text = "Profile",
					OnClick = function()
						host.Show("Profile")
					end,
				},
				{
					Text = "Settings",
					OnClick = function()
						host.Show("Settings")
					end,
				},
				{
					Text = "Sign out",
					OnClick = function()
						host.Show("Signed out")
					end,
				},
			},
		})
		scope:AppSheet({
			Layer = overlayLayer,
			Open = sheetOpen,
			Title = "Quick sheet",
			OnClose = function()
				sheetOpen:set(false)
			end,
			Children = {
				scope:Text({ Text = "iOS-style app sheet with grabber + scrim.", Variant = "Body" }),
				scope:StarRating({ Value = 5 }),
			},
		})

		themeBtn = scope:IconButton({
			Name = if peek(mode) == "Light" then "moon" else "sun",
			OnClick = function()
				mode:set(if peek(mode) == "Light" then "Dark" else "Light")
			end,
		})
		scope:Tooltip({
			Layer = overlayLayer,
			Target = themeBtn,
			Text = if peek(mode) == "Light" then "Switch to dark" else "Switch to light",
			Placement = "Auto",
		})

		-- With a side rail the menu button lives at the top of the rail; with a bottom bar it
		-- stays in the app bar.
		local verticalRail = peek(railOrientation) == "Vertical"
		local menuButton = scope:IconButton({
			Name = "menu",
			OnClick = function()
				drawerOpen:set(true)
			end,
		})
		local rail = scope:NavigationRail({
			Orientation = peek(railOrientation),
			Leading = if verticalRail then menuButton else nil,
			Layer = overlayLayer,
			Items = {
				{ Id = "home", Icon = "home", Label = "Home" },
				{ Id = "lib", Icon = "library", Label = "Lib" },
				{ Id = "set", Icon = "settings", Label = "Settings" },
			},
		})

		local scrollKids = {}
		for _, section in sections do
			table.insert(scrollKids, section)
		end

		local scroll = scope:ScrollArea({
			Children = scrollKids,
			Smooth = true,
			Inertia = true,
			Keyboard = true,
			AutoCanvas = true,
			Overscroll = true,
			ScrollBarRail = true,
			ScrollBarRailBackground = true,
			ScrollBarThickness = 8,
			ScrollBarRailThickness = 2,
			ScrollBarPadding = 8,
			ScrollButtons = true,
			AutoHideScrollBar = true,
			ScrollOffset = peek(scrollY),
			OnScroll = function(y)
				scrollY:set(y)
			end,
			OnRefresh = function()
				if peek(refreshing) then
					return
				end
				refreshing:set(true)
				task.delay(1.2, function()
					refreshing:set(false)
					host.Show("Feed updated")
				end)
			end,
			Refreshing = refreshing,
			PullHint = "Keep scrolling to refresh",
			ReleaseHint = "Release to refresh",
		})

		local appBar = scope:AppBar({
			Title = "pantheon catalog",
			Leading = if verticalRail then nil else menuButton,
			Actions = { themeBtn },
			-- Softer fill next to the rail.
			RaisedColor = if verticalRail then theme.Colors.SurfaceContainer else nil,
			Radius = { theme.Metrics.RadiusPanel, 0 },
			-- Transparent at the top of the page, solid once scrolled.
			FadeAtTop = true,
			ScrollOffset = scrollY,
		})

		-- The catalog lives in a draggable window (drag it by the app bar), like the admin demo.
		local window = scope:Window({
			AnchorPoint = Vector2.new(0.5, 0.5),
			-- A Value here persists the dragged position across rebuilds.
			Position = windowPosition,
			-- Values, so a resize / drag survives a rebuild.
			Size = windowSize,
			Draggable = true,
			Resizable = true,
			MinSize = Vector2.new(360, 280),
			RailOrientation = peek(railOrientation),
			AppBar = appBar,
			NavigationRail = rail,
			-- Everything that floats (popovers, tooltips, coach mark, sheets, toasts) lives on
			-- this layer, inside the window, so it moves with it and respects its rounded edge.
			Overlays = { overlayLayer },
			Children = {
				scope:Apply(scroll)({ Size = UDim2.fromScale(1, 1) }),
			},
		})

		local gui = scope:New("ScreenGui")({
			Name = "PantheonStoryboard",
			ResetOnSpawn = false,
			DisplayOrder = generation,
			Parent = playerGui,
			[Children] = {
				window,
			},
		}) :: ScreenGui

		if previous then
			-- Crossfade: fade the new UI in over the old one, then dispose of the old one.
			local reveal = scope:Value(0)
			local revealS = scope:Spring(reveal, 14, 1)
			Pantheon.GroupFade.bind(scope, gui, revealS)
			task.defer(function()
				reveal:set(1)
			end)
			task.delay(0.7, function()
				Fusion.doCleanup(previous)
			end)
		end
	end)
end

-- Game HUD
-- The in-game components sit on the screen, above the catalog window.
-- Built once; they don't use the app theme, so a theme switch doesn't rebuild them.
do
	local Game = Pantheon.Game
	local hotbarSelected = rootScope:Value(1)
	local hotbarCooldown = rootScope:Value(0)
	local hotbarItems = rootScope:Value({
		[1] = { Name = "Sword", Description = "Starter blade", Tags = { "weapon", "melee" } },
		[2] = { Name = "Bow", Description = "Ranged", Tags = { "weapon", "ranged" }, Count = 24 },
		[3] = {
			Name = "Heal",
			Description = "Restores health",
			Count = 3,
			Cooldown = hotbarCooldown,
		},
		[4] = { Name = "Block", Count = 64 },
		[11] = { Name = "Torch", Tags = { "tool" }, Count = 8 },
		[14] = { Name = "Map", Description = "Shows the area" },
	} :: { [number]: any })

	-- `=` adds an item, `-` removes the equipped one.
	local names = { "Axe", "Shield", "Potion", "Rope", "Lamp", "Key" }
	game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.Equals then
			local list = table.clone(peek(hotbarItems))
			for slot = 1, 27 do
				if list[slot] == nil then
					list[slot] = { Name = names[math.random(#names)], Count = math.random(1, 12) }
					break
				end
			end
			hotbarItems:set(list)
		elseif input.KeyCode == Enum.KeyCode.Minus then
			local slot = peek(hotbarSelected)
			if slot then
				local list = table.clone(peek(hotbarItems))
				list[slot] = nil
				hotbarItems:set(list)
			end
		end
	end)

	local hudLayer = rootScope:Frame({
		Name = "HudLayer",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 50,
	})
	Pantheon.Theme.Provide(Pantheon.Theme.create("Dark"), function()
		rootScope:RadialMenu({
			Layer = hudLayer,
			Hotkey = Enum.KeyCode.Q,
			Title = "Emote",
			Items = {
				{ Id = "wave", Icon = "hand", Text = "Wave" },
				{ Id = "dance", Icon = "music", Text = "Dance" },
				{ Id = "cheer", Icon = "sparkles", Text = "Cheer" },
				{ Id = "sit", Icon = "armchair", Text = "Sit" },
				{ Id = "laugh", Icon = "smile", Text = "Laugh" },
			},
		})
	end)

	rootScope:New("ScreenGui")({
		Name = "PantheonHud",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1000,
		Parent = playerGui,
		[Children] = {
			hudLayer,
			Game.Hotbar(rootScope, {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -16),
				Selected = hotbarSelected,
				Items = hotbarItems,
				Slots = 9,
				Capacity = 27,
				-- 1-9 equip a slot, ` opens the inventory, drag to move items, Q holds the radial menu, = adds one,
				-- - removes the equipped one. Slot 3 starts a 3 second cooldown.
				OnSelect = function(slot: number?)
					if slot == 3 and peek(hotbarCooldown) == 0 then
						task.spawn(function()
							local started = os.clock()
							while true do
								local left = 1 - (os.clock() - started) / 3
								hotbarCooldown:set(math.max(left, 0))
								if left <= 0 then
									break
								end
								task.wait()
							end
						end)
					end
				end,
			}),
		},
	})
end

rebuild()
rootScope:Observer(mode):onChange(function()
	if not Pantheon.Flags.ReactiveTheme then
		rebuild()
	end
end)

print("pantheon storyboard, full Cadence catalog (light/dark)")
