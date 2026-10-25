--!strict
local Packages = script.Parent.Parent.Parent
local Fusion = require(Packages.Fusion)
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Parent.Internal.Accessibility)
local resolveTheme = require(script.Parent.Parent.Internal.resolveTheme).resolveTheme
local Persist = require(script.Parent.Parent.Internal.Persist)
local Bind = require(script.Parent.Parent.Internal.Bind)
local Button = require(script.Parent.Button)

local Children = Fusion.Children
local peek = Fusion.peek

return function(scope: Types.Scope, props: Types.PaginationProps): Instance
	local theme = resolveTheme(props)
	local page = Persist.value(
		scope,
		Persist.key("Pagination", typeof(props.Page) == "table"),
		"page",
		peek(props.Page) or 1
	)
	Bind.link(scope, props.Page, page)
	local count = math.max(props.PageCount, 1)

	local function setPage(n: number)
		n = math.clamp(n, 1, count)
		page:set(n)
		if props.OnChanged then
			props.OnChanged(n)
		end
	end

	return scope:Frame({
		Name = "Pagination",
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.XY,
		LayoutOrder = props.LayoutOrder or 0,
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = theme.Metrics.SpaceXs,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		},
		[Children] = {
			Button(scope, {
				Text = "Prev",
				Variant = "Tonal" :: Types.ButtonVariant,
				OnClick = function()
					setPage(peek(page) - 1)
				end,
			}),
			scope:TextLabel({
				BackgroundTransparency = 1,
				FontFace = theme.Fonts.Body,
				TextSize = A.size(theme, 14),
				TextColor3 = theme.Colors.OnSurface,
				Text = scope:Computed(function(use)
					return `{use(page)} / {count}`
				end),
				AutomaticSize = Enum.AutomaticSize.XY,
			}),
			Button(scope, {
				Text = "Next",
				Variant = "Tonal" :: Types.ButtonVariant,
				OnClick = function()
					setPage(peek(page) + 1)
				end,
			}),
		},
	}) :: Frame
end
