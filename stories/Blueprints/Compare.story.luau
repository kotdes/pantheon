--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

local BLUEPRINTS = { "Materia", "Pantheon" }

--[[
	The same controls under each blueprint, side by side. "Open both" opens the two popovers
	at the same moment, so the difference in how they come in can be seen. Turn on
	ReduceMotion in the controls to check that both settle at once.
]]
return StoryUtil.story(function(scope, _, ctx)
	local Pantheon = ctx.Pantheon
	local opens = {}
	local columns = {}

	for index, name in BLUEPRINTS do
		local theme = Pantheon.Theme.create(ctx.theme.Mode, {
			RespectAccessibility = false,
			Blueprint = Pantheon.Theme.Blueprints[name],
		})
		theme = Pantheon.Accessibility.apply(theme, ctx.theme.Accessibility)

		local open = scope:Value(false)
		opens[index] = open
		local trigger = scope:Button({
			Theme = theme,
			Text = "Popover",
			Variant = "Tonal",
			LayoutOrder = 3,
			OnClick = function()
				open:set(not StoryUtil.peek(open))
			end,
		})
		scope:Popover({
			Theme = theme,
			Layer = ctx.overlayLayer,
			Open = open,
			Target = trigger,
			Placement = "Bottom",
			OnClose = function()
				open:set(false)
			end,
			Items = {
				{ Text = "Rename" },
				{ Text = "Duplicate" },
				{ Text = "Delete" },
			} :: { any },
		})
		local column = scope:Frame({
			Name = name,
			BackgroundColor3 = theme.Colors.Surface,
			Size = UDim2.new(0.5, -6, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = index,
			CornerRadius = theme.Metrics.RadiusLg,
			Padding = { theme.Metrics.SpaceLg },
			Layout = {
				Kind = "List",
				Padding = theme.Metrics.SpaceMd,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			[scope.Children] = {
				scope:Text({ Theme = theme, Text = name, Variant = "Title", LayoutOrder = 1 }),
				scope:TextField({
					Theme = theme,
					Label = "Name",
					Placeholder = "Default variant",
					LayoutOrder = 2,
				}),
				trigger,
				scope:Switch({ Theme = theme, Label = "Switch", Fill = true, LayoutOrder = 4 }),
				scope:Checkbox({ Theme = theme, Label = "Checkbox", LayoutOrder = 5 }),
			},
		})
		columns[index] = column
	end

	return scope:Frame({
		Name = "BlueprintCompare",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Layout = { Kind = "List", Padding = 12, SortOrder = Enum.SortOrder.LayoutOrder },
		[scope.Children] = {
			scope:Button({
				Text = "Open both",
				LayoutOrder = 1,
				OnClick = function()
					local next = not StoryUtil.peek(opens[1])
					for _, open in opens do
						open:set(next)
					end
				end,
			}),
			scope:Frame({
				Name = "Columns",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 2,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = 12,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[scope.Children] = columns,
			}),
		},
	})
end)
