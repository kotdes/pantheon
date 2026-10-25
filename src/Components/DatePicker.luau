--!strict
--[[
	Date picker: `<  Aug 2026 >` header; Aug / year are separate hit targets.
	Month & year pickers; day grid animates diagonally on period change.
]]
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Calendar = require(script.Parent.Parent.Internal.Picker.Calendar)
local Interaction = require(script.Parent.Parent.Internal.Interaction)
local Icon = require(script.Parent.Icon)
local P = require(script.Parent.Parent.Internal.props)

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local CELL = 36
local GAP = 4
local COLS = 7
local ROWS = 6
local GRID_W = COLS * CELL + (COLS - 1) * GAP
local BODY_H = ROWS * CELL + (ROWS - 1) * GAP
local WEEK_H = 24 -- the row of weekday letters above the days
local WEEKDAYS = { "S", "M", "T", "W", "T", "F", "S" }
local NAV = 36

type ViewMode = "Days" | "Months" | "Years"

local function monthLabel(month: number): string
	return Calendar.MONTHS_SHORT[month] or "?"
end

return function(scope: Types.Scope, props: Types.DatePickerProps): Instance
	local theme = resolveTheme(props)
	local now = os.date("*t")
	local y0, m0, d0 = Calendar.parseISO(peek(props.Value) or "")
	local persistKey = Persist.key("DatePicker", typeof(props.Value) == "table")
	local year = Persist.value(scope, persistKey, "year", y0 or now.year)
	local month = Persist.value(scope, persistKey, "month", m0 or now.month)
	local day = Persist.value(scope, persistKey, "day", d0 or now.day)
	Bind.linkParts(
		scope,
		props.Value,
		{ year, month, day },
		function(y: number, m: number, d: number)
			return Calendar.formatISO(y, m, d)
		end,
		function(iso: string)
			local y, m, d = Calendar.parseISO(iso)
			if y == nil or m == nil or d == nil then
				return nil
			end
			return { y, m, d }
		end
	)
	local view = scope:Value("Days" :: ViewMode)
	local generation = scope:Value(0)

	-- Mode progress springs so we can animate fades/scale while keeping the
	-- corresponding UI alive briefly instead of toggling Visibility instantly.
	local daysModeS = scope:Spring(
		scope:Computed(function(use)
			return if use(view) == "Days" then 1 else 0
		end),
		theme.Motion.SpringSpeed,
		theme.Motion.SpringDamping
	)
	local monthsModeS = scope:Spring(
		scope:Computed(function(use)
			return if use(view) == "Months" then 1 else 0
		end),
		theme.Motion.SpringSpeed,
		theme.Motion.SpringDamping
	)
	local yearsModeS = scope:Spring(
		scope:Computed(function(use)
			return if use(view) == "Years" then 1 else 0
		end),
		theme.Motion.SpringSpeed,
		theme.Motion.SpringDamping
	)

	local function bumpGeneration()
		generation:set(peek(generation) + 1)
	end

	local function shiftMonth(delta: number)
		local m = peek(month) + delta
		local y = peek(year)
		while m < 1 do
			m += 12
			y -= 1
		end
		while m > 12 do
			m -= 12
			y += 1
		end
		month:set(m)
		year:set(y)
		bumpGeneration()
		view:set("Days")
	end

	local function makeHit(
		name: string,
		label: any,
		activeMode: ViewMode,
		onClick: () -> ()
	): TextButton
		local ix = Interaction.bind(scope, theme, {
			StateColor = theme.Colors.OnSurface,
			HoverOpacity = 0.1,
			PressOpacity = 0.16,
		})
		local activeS = scope:Computed(function(use)
			return use(view) == activeMode
		end)
		local btn = scope:TextButton(P({
			Name = name,
			Text = label,
			FontFace = scope:Computed(function(use)
				return if use(activeS) then theme.Fonts.Heading else theme.Fonts.Body
			end),
			TextSize = A.size(theme, 16),
			TextColor3 = scope:Computed(function(use)
				return if use(activeS)
					then use(theme.Colors.OnPrimary)
					else use(theme.Colors.OnSurface)
			end),
			BackgroundColor3 = scope:Computed(function(use)
				if use(activeS) then
					return use(theme.Colors.Primary)
				end
				return Interaction.lerpColor(
					use(theme.Colors.SurfaceContainer),
					use(theme.Colors.OnSurface),
					ix.alpha(use),
					use
				)
			end),
			BackgroundTransparency = scope:Computed(function(use)
				if use(activeS) then
					return 0
				end
				local alpha = ix.alpha(use)
				return math.clamp(1 - alpha * 4, 0, 1)
			end),
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.XY,
			Padding = { 8, 14 },
			CornerRadius = theme.Metrics.RadiusPill,
			[OnEvent("Activated")] = onClick,
		}))
		ix.wire(btn)
		return btn
	end

	local monthHit = makeHit(
		"MonthHit",
		scope:Computed(function(use)
			return monthLabel(use(month))
		end),
		"Months",
		function()
			view:set(if peek(view) == "Months" then "Days" else "Months")
		end
	)
	monthHit.LayoutOrder = 1

	local yearHit = makeHit(
		"YearHit",
		scope:Computed(function(use)
			return tostring(use(year))
		end),
		"Years",
		function()
			view:set(if peek(view) == "Years" then "Days" else "Years")
		end
	)
	yearHit.LayoutOrder = 2

	local titleRow = scope:Frame({
		Name = "Title",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = 0,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = { monthHit, yearHit },
	})

	local titleMid = scope:Frame({
		Name = "TitleMid",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		LayoutOrder = 2,
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},
		[Children] = { titleRow },
	})
	local titleFlex = Instance.new("UIFlexItem")
	titleFlex.FlexMode = Enum.UIFlexMode.Fill
	titleFlex.Parent = titleMid

	local function navButton(iconName: string, onClick: () -> ()): TextButton
		local ix = Interaction.bind(scope, theme, {
			StateColor = theme.Colors.OnSurface,
			HoverOpacity = 0.1,
			PressOpacity = 0.16,
		})
		local btn = scope:TextButton(P({
			Text = "",
			BackgroundColor3 = scope:Computed(function(use)
				local alpha = ix.alpha(use)
				return Interaction.lerpColor(
					use(theme.Colors.SurfaceContainer),
					use(theme.Colors.OnSurface),
					alpha,
					use
				)
			end),
			BackgroundTransparency = 0,
			Size = UDim2.fromOffset(NAV, NAV),
			AutoButtonColor = false,
			CornerRadius = theme.Metrics.RadiusPill,
			[OnEvent("Activated")] = onClick,
			[Children] = {
				scope:Apply(Icon(scope, {
					Theme = theme,
					Name = iconName,
					IconSize = 18,
					Color = theme.Colors.OnSurface,
				}))({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
				}),
			},
		}))
		ix.wire(btn)
		return btn
	end

	local prevBtn = navButton("chevron-left", function()
		if peek(view) == "Years" then
			year:set(peek(year) - 16)
		elseif peek(view) == "Months" then
			year:set(peek(year) - 1)
		else
			shiftMonth(-1)
		end
	end)
	prevBtn.LayoutOrder = 1

	local nextBtn = navButton("chevron-right", function()
		if peek(view) == "Years" then
			year:set(peek(year) + 16)
		elseif peek(view) == "Months" then
			year:set(peek(year) + 1)
		else
			shiftMonth(1)
		end
	end)
	nextBtn.LayoutOrder = 3

	-- Day slots: key includes generation so ForPairs fully tears down on period change
	local daySlots = scope:Computed(function(use)
		local y = use(year)
		local m = use(month)
		local gen = use(generation)
		local firstWeekday = Calendar.weekday(y, m, 1)
		local dim = Calendar.daysInMonth(y, m)
		local map: { [number]: { day: number, order: number } } = {}
		for d = 1, dim do
			map[gen * 40 + d] = { day = d, order = firstWeekday + d }
		end
		return map
	end)

	local blankSlots = scope:Computed(function(use)
		local gen = use(generation)
		local n = Calendar.weekday(use(year), use(month), 1)
		local map: { [number]: number } = {}
		for i = 1, n do
			map[gen * 40 + i] = i
		end
		return map
	end)

	local blankCells = scope:ForPairs(
		blankSlots,
		function(_use, innerScope, key: number, index: number)
			local cellScope: Types.Scope = innerScope :: any
			return key,
				cellScope:Frame({
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(CELL, CELL),
					LayoutOrder = index,
				})
		end
	)

	-- The pill behind the picked day, sliding to it (and fading with the Days view).
	local selectorTarget = scope:Computed(function(use)
		local order = Calendar.weekday(use(year), use(month), 1) + use(day)
		local col = (order - 1) % COLS
		local row = math.floor((order - 1) / COLS)
		return UDim2.fromOffset(col * (CELL + GAP), WEEK_H + row * (CELL + GAP))
	end)
	local selector = scope:Frame({
		Name = "Selection",
		BackgroundColor3 = theme.Colors.Primary,
		BackgroundTransparency = scope:Computed(function(use)
			return 1 - math.clamp(use(daysModeS) :: number, 0, 1)
		end),
		Position = scope:Spring(
			selectorTarget,
			theme.Motion.SpringSpeed * 1.2,
			theme.Motion.SpringDamping
		),
		Size = UDim2.fromOffset(CELL, CELL),
		CornerRadius = theme.Metrics.RadiusPill,
		ZIndex = 1,
	})
	local weekdayRow = {}
	for index, letter in WEEKDAYS do
		table.insert(
			weekdayRow,
			scope:TextLabel({
				Name = "Weekday",
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset((index - 1) * (CELL + GAP), 0),
				Size = UDim2.fromOffset(CELL, WEEK_H),
				FontFace = theme.Fonts.Body,
				TextSize = A.size(theme, 12),
				TextColor3 = theme.Colors.OnSurfaceVariant,
				Text = letter,
			})
		)
	end

	local dayCells = scope:ForPairs(
		daySlots,
		function(_use, innerScope, key: number, info: { day: number, order: number })
			local cellScope: Types.Scope = innerScope :: any
			local dayNum = info.day
			local order = info.order
			local col = (order - 1) % COLS
			local row = math.floor((order - 1) / COLS)
			local delay = (row + col) * 0.018

			local alive = true
			table.insert(cellScope, function()
				alive = false
			end)

			local appear = cellScope:Value(0)
			local appearS =
				cellScope:Spring(appear, theme.Motion.SpringSpeed, theme.Motion.SpringDamping)
			task.delay(delay, function()
				if alive then
					appear:set(1)
				end
			end)

			local ix = Interaction.bind(cellScope, theme, {
				StateColor = theme.Colors.OnSurface,
				HoverOpacity = 0.1,
				PressOpacity = 0.16,
			})

			local selectedS = cellScope:Computed(function(use)
				return use(day) == dayNum
			end)
			-- The selection pill is a separate frame that slides between days; the cell only
			-- fades its text to match.
			local pickedS = cellScope:Spring(
				cellScope:Computed(function(use)
					return if use(selectedS) then 1 else 0
				end),
				theme.Motion.SpringSpeed * 1.2,
				theme.Motion.SpringDamping
			)
			local isToday = peek(year) == now.year
				and peek(month) == now.month
				and dayNum == now.day

			local btn = cellScope:TextButton(P({
				Name = "Day_" .. dayNum,
				Text = tostring(dayNum),
				FontFace = cellScope:Computed(function(use)
					return if use(selectedS) then theme.Fonts.Heading else theme.Fonts.Body
				end),
				TextSize = A.size(theme, 13),
				TextColor3 = cellScope:Computed(function(use)
					return Interaction.lerpColor(
						use(theme.Colors.OnSurface),
						use(theme.Colors.OnPrimary),
						math.clamp(use(pickedS) :: number, 0, 1),
						use
					)
				end),
				TextTransparency = cellScope:Computed(function(use)
					local t = (use(appearS) :: number) * use(daysModeS) :: number
					return 1 - t
				end),
				BackgroundColor3 = cellScope:Computed(function(use)
					return Interaction.lerpColor(
						use(theme.Colors.SurfaceContainer),
						use(theme.Colors.OnSurface),
						ix.alpha(use),
						use
					)
				end),
				BackgroundTransparency = cellScope:Computed(function(use)
					local t = (use(appearS) :: number) * use(daysModeS) :: number
					local fade = 1 - t
					-- Picked cells are clear so the sliding pill shows through.
					local base = math.clamp(fade * 0.85, 0, 1)
					return base + (1 - base) * math.clamp(use(pickedS) :: number, 0, 1)
				end),
				Size = UDim2.fromOffset(CELL, CELL),
				LayoutOrder = order,
				AutoButtonColor = false,
				CornerRadius = theme.Metrics.RadiusPill,
				[OnEvent("Activated")] = function()
					day:set(dayNum)
					local iso = Calendar.formatISO(peek(year), peek(month), dayNum)
					if props.OnChanged then
						props.OnChanged(iso)
					end
				end,
				[Children] = {
					if isToday
						then cellScope:New("UIStroke")({
							Color = theme.Colors.Primary,
							Thickness = 1.5,
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Transparency = cellScope:Computed(function(use)
								return 1
									- (1 - math.clamp(use(pickedS) :: number, 0, 1))
										* (use(appearS) :: number)
							end),
						})
						else nil,
					cellScope:New("UIScale")({
						Scale = cellScope:Computed(function(use)
							local t = use(appearS)
							local mode = use(daysModeS)
							local base = 1.22 - 0.22 * t
							-- Shrinks a little as the view leaves, to match the cells arriving small.
							local radial = 0.92 + 0.08 * mode
							local pressed = 1 - 0.12 * (use(ix.Press) :: number)
							return base * radial * pressed
						end),
					}),
				},
			}))
			ix.wire(btn)
			return key, btn
		end
	)

	-- Booleans, so building the cells doesn't depend on every frame of the spring.
	local monthsShown = scope:Computed(function(use)
		return use(monthsModeS) > 0.001
	end)
	local yearsShown = scope:Computed(function(use)
		return use(yearsModeS) > 0.001
	end)

	--- Fade and scale for the cell at `index` of a `columns` wide grid as its view comes in:
	--- cells arrive in a diagonal wave and settle from slightly small.
	local function arrival(scopeFor: Types.Scope, modeS: any, index: number, columns: number)
		local col = (index - 1) % columns
		local row = math.floor((index - 1) / columns)
		local lag = (row + col) * 0.07
		return scopeFor:Computed(function(use)
			return math.clamp((use(modeS) :: number) * (1 + lag) - lag, 0, 1)
		end)
	end

	local function arrivalScale(scopeFor: Types.Scope, progress: any): Instance
		return scopeFor:New("UIScale")({
			Scale = scopeFor:Computed(function(use)
				return 0.86 + 0.14 * (use(progress) :: number)
			end),
		})
	end

	local monthCells = scope:Computed(function(use, innerScope)
		local cellScope: Types.Scope = innerScope :: any
		if not use(monthsShown) then
			return {}
		end
		local nodes = {}
		for m = 1, 12 do
			local monthNum = m
			local selected = use(month) == monthNum
			local ix = Interaction.bind(cellScope, theme, {
				StateColor = theme.Colors.OnSurface,
				HoverOpacity = 0.1,
				PressOpacity = 0.16,
			})
			local progress = arrival(cellScope, monthsModeS, monthNum, 3)
			local btn = cellScope:TextButton(P({
				Text = monthLabel(monthNum),
				TextTransparency = cellScope:Computed(function(useT)
					return 1 - (useT(progress) :: number)
				end),
				BackgroundTransparency = cellScope:Computed(function(useT)
					return 1 - (useT(progress) :: number)
				end),
				[Children] = { arrivalScale(cellScope, progress) },
				FontFace = if selected then theme.Fonts.Heading else theme.Fonts.Body,
				TextSize = A.size(theme, 13),
				TextColor3 = if selected
					then use(theme.Colors.OnPrimary)
					else use(theme.Colors.OnSurface),
				AutoButtonColor = false,
				CornerRadius = theme.Metrics.RadiusSm,
				Size = UDim2.new(1 / 3, -4, 0, 40),
				LayoutOrder = monthNum,
				Active = cellScope:Computed(function(useButton)
					return useButton(view) == "Months"
				end),
				BackgroundColor3 = cellScope:Computed(function(useColor)
					if selected then
						return useColor(theme.Colors.Primary)
					end
					return Interaction.lerpColor(
						useColor(theme.Colors.SurfaceContainer),
						useColor(theme.Colors.OnSurface),
						ix.alpha(useColor),
						useColor
					)
				end),
				[OnEvent("Activated")] = function()
					month:set(monthNum)
					bumpGeneration()
					view:set("Days")
				end,
			}))
			ix.wire(btn)
			table.insert(nodes, btn)
		end
		return nodes
	end)

	local yearCells = scope:Computed(function(use, innerScope)
		local cellScope: Types.Scope = innerScope :: any
		if not use(yearsShown) then
			return {}
		end
		local center = use(year) :: number
		local nodes = {}
		local start = center - 7
		for i = 0, 15 do
			local y = start + i
			local selected = use(year) == y
			local ix = Interaction.bind(cellScope, theme, {
				StateColor = theme.Colors.OnSurface,
				HoverOpacity = 0.1,
				PressOpacity = 0.16,
			})
			local progress = arrival(cellScope, yearsModeS, i + 1, 4)
			local btn = cellScope:TextButton(P({
				Text = tostring(y),
				TextTransparency = cellScope:Computed(function(useT)
					return 1 - (useT(progress) :: number)
				end),
				BackgroundTransparency = cellScope:Computed(function(useT)
					return 1 - (useT(progress) :: number)
				end),
				[Children] = { arrivalScale(cellScope, progress) },
				FontFace = if selected then theme.Fonts.Heading else theme.Fonts.Body,
				TextSize = A.size(theme, 13),
				TextColor3 = if selected
					then use(theme.Colors.OnPrimary)
					else use(theme.Colors.OnSurface),
				AutoButtonColor = false,
				CornerRadius = theme.Metrics.RadiusSm,
				Size = UDim2.new(1 / 4, -4, 0, 40),
				LayoutOrder = i + 1,
				Active = cellScope:Computed(function(useButton)
					return useButton(view) == "Years"
				end),
				BackgroundColor3 = cellScope:Computed(function(useColor)
					if selected then
						return useColor(theme.Colors.Primary)
					end
					return Interaction.lerpColor(
						useColor(theme.Colors.SurfaceContainer),
						useColor(theme.Colors.OnSurface),
						ix.alpha(useColor),
						useColor
					)
				end),
				[OnEvent("Activated")] = function()
					year:set(y)
					bumpGeneration()
					view:set("Days")
				end,
			}))

			ix.wire(btn)
			table.insert(nodes, btn)
		end
		return nodes
	end)

	return scope:Frame({
		Name = "DatePicker",
		BackgroundColor3 = theme.Colors.Surface,
		Size = props.Size or UDim2.fromOffset(GRID_W + theme.Metrics.SpaceMd * 2, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = props.LayoutOrder or 0,
		-- Allow overflow (e.g. animated day "bubbles") to escape the container.
		ClipsDescendants = false,
		CornerRadius = theme.Metrics.RadiusPanel,
		Padding = { theme.Metrics.SpaceMd },
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.SpaceSm,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			scope:Frame({
				Name = "Header",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 44),
				LayoutOrder = 1,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = theme.Metrics.SpaceXs,
				},
				[Children] = { prevBtn, titleMid, nextBtn },
			}),
			scope:Frame({
				Name = "Body",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, BODY_H + WEEK_H),
				LayoutOrder = 2,
				ClipsDescendants = false,
				[Children] = {
					scope:Frame({
						Name = "Days",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						Visible = scope:Computed(function(use)
							return use(daysModeS) > 0.001
						end),
						Layout = {
							Kind = "List",
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Top,
						},
						[Children] = {
							scope:Frame({
								Name = "DayArea",
								BackgroundTransparency = 1,
								Size = UDim2.fromOffset(GRID_W, BODY_H + WEEK_H),
								[Children] = {
									weekdayRow,
									selector,
									scope:Frame({
										Name = "DayGrid",
										BackgroundTransparency = 1,
										Position = UDim2.fromOffset(0, WEEK_H),
										Size = UDim2.fromOffset(GRID_W, BODY_H),
										ZIndex = 2,
										Layout = {
											Kind = "Grid",
											CellSize = UDim2.fromOffset(CELL, CELL),
											CellPadding = UDim2.fromOffset(GAP, GAP),
											FillDirectionMaxCells = COLS,
											SortOrder = Enum.SortOrder.LayoutOrder,
										},
										[Children] = { blankCells, dayCells },
									}),
								},
							}),
						},
					}),
					scope:Frame({
						Name = "Months",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						Visible = scope:Computed(function(use)
							return use(monthsModeS) > 0.001
						end),
						Layout = {
							Kind = "Grid",
							CellSize = UDim2.new(1 / 3, -4, 0, 40),
							CellPadding = UDim2.fromOffset(4, 4),
							FillDirectionMaxCells = 3,
							SortOrder = Enum.SortOrder.LayoutOrder,
						},
						[Children] = monthCells,
					}),
					scope:Frame({
						Name = "Years",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						Visible = scope:Computed(function(use)
							return use(yearsModeS) > 0.001
						end),
						Layout = {
							Kind = "Grid",
							CellSize = UDim2.new(1 / 4, -4, 0, 40),
							CellPadding = UDim2.fromOffset(4, 4),
							FillDirectionMaxCells = 4,
							SortOrder = Enum.SortOrder.LayoutOrder,
						},
						[Children] = yearCells,
					}),
				},
			}),
		},
	}) :: Frame
end
