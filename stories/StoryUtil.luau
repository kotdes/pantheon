--!strict
--[[
	Shared UI Labs Fusion story helper for pantheon.
	Rebuilds on control changes (components bake theme colors at mount).
	Emulates theme mode + accessibility prefs via UI Labs controls.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Pantheon = require(ReplicatedStorage.Packages.Pantheon)
local Fusion = Pantheon.Fusion
local Children = Fusion.Children
local peek = Fusion.peek

export type StoryContext = {
	theme: any,
	overlayLayer: Instance,
	Pantheon: typeof(Pantheon),
	controls: any,
}

export type BuildFn = (scope: any, C: typeof(Pantheon.Components), ctx: StoryContext) -> Instance?

local TEXT_SIZES = { "Medium", "Large", "Larger", "Largest" }

local StoryUtil = {}

StoryUtil.Pantheon = Pantheon
StoryUtil.Fusion = Fusion
StoryUtil.peek = peek

local function resolveTextSize(raw: any): string
	local value = tostring(peek(raw) or "Medium")
	for _, name in TEXT_SIZES do
		if name == value then
			return name
		end
	end
	return "Medium"
end

local function prefsFromControls(controls: any): any
	return {
		ReduceMotion = peek(controls.ReduceMotion) == true,
		PreferredTransparency = math.clamp(
			tonumber(peek(controls.PreferredTransparency)) or 0,
			0,
			1
		),
		HighContrast = peek(controls.HighContrast) == true,
		PreferredTextSize = resolveTextSize(controls.PreferredTextSize),
	}
end

function StoryUtil.story(build: BuildFn, extraControls: { [string]: any }?): any
	local controls: { [string]: any } = {
		Dark = false,
		-- Materia | Pantheon (see Theme.Blueprints)
		Blueprint = "Materia",
		ReduceMotion = false,
		HighContrast = false,
		-- 0 = prefer opaque chrome, 1 = transparency ok (matches GuiService.PreferredTransparency)
		PreferredTransparency = 0.2,
		-- Medium | Large | Larger | Largest (matches GuiService.PreferredTextSize)
		PreferredTextSize = "Medium",
	}
	if extraControls then
		for key, value in extraControls do
			controls[key] = value
		end
	end

	return {
		fusion = Fusion,
		controls = controls,
		story = function(props)
			local rootScope = Pantheon.scoped()
			local uiScope: any = nil

			local function rebuild()
				if uiScope then
					Fusion.doCleanup(uiScope)
					uiScope = nil
				end

				uiScope = Fusion.innerScope(rootScope)
				local scope = uiScope
				local mode: "Light" | "Dark" = if peek(props.controls.Dark) then "Dark" else "Light"
				local prefs = prefsFromControls(props.controls)
				-- Components bake colors at mount; rebuild applies mode + a11y prefs explicitly.
				local theme = Pantheon.Theme.create(mode, {
					RespectAccessibility = false,
					Blueprint = Pantheon.Theme.Blueprints[tostring(peek(props.controls.Blueprint))],
				})
				theme = Pantheon.Accessibility.apply(theme, prefs)

				Pantheon.Theme.Provide(theme, function()
					local overlayLayer = scope:Frame({
						Name = "OverlayLayer",
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						ZIndex = 50,
					})

					local content = build(scope, Pantheon.Components, {
						theme = theme,
						overlayLayer = overlayLayer,
						Pantheon = Pantheon,
						controls = props.controls,
					})

					scope:Frame({
						Name = "StoryRoot",
						BackgroundColor3 = theme.Colors.Background,
						Size = UDim2.fromScale(1, 1),
						Parent = props.target,
						ClipsDescendants = false,
						[Children] = {
							scope:Frame({
								Name = "Content",
								BackgroundTransparency = 1,
								Size = UDim2.fromScale(1, 1),
								ClipsDescendants = false,
								Padding = { 16 },
								Layout = {
									Kind = "List",
									Padding = 12,
									SortOrder = Enum.SortOrder.LayoutOrder,
								},
								[Children] = if content then { content :: Instance } else nil,
							}),
							overlayLayer,
						},
					})
				end)
			end

			rebuild()

			-- Components resolve theme colors once at mount, so rebuild like the demo storyboard.
			for _, control in props.controls do
				if typeof(control) == "table" then
					table.insert(
						rootScope,
						rootScope:Observer(control):onChange(function()
							task.defer(rebuild)
						end)
					)
				end
			end

			return function()
				Fusion.doCleanup(rootScope)
			end
		end,
	}
end

--[[
	Sized panel for components that need a fixed viewport (tables, scroll, rails).
]]
function StoryUtil.panel(scope: any, height: number, child: Instance): Frame
	return scope:Frame({
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, height),
		ClipsDescendants = false,
		[Children] = { child :: Instance },
	}) :: Frame
end

return StoryUtil
