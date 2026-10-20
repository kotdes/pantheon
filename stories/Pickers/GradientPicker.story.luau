--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)
local Fusion = StoryUtil.Fusion

local Children = Fusion.Children

return StoryUtil.story(function(scope, _, ctx)
	local preview = scope:New("UIGradient")({})
	return scope:Frame({
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Layout = { Kind = "List", Padding = 12, SortOrder = Enum.SortOrder.LayoutOrder },
		[Children] = {
			scope:New("Frame")({
				LayoutOrder = 1,
				BackgroundColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(1, 0, 0, 56),
				[Children] = {
					scope:New("UICorner")({
						CornerRadius = UDim.new(0, ctx.theme.Metrics.RadiusSm),
					}),
					preview,
				},
			}),
			scope:GradientPicker({
				LayoutOrder = 2,
				Layer = ctx.overlayLayer,
				OnChanged = function(colors, transparency, rotation, offset)
					preview.Color = colors
					preview.Transparency = transparency
					preview.Rotation = rotation
					preview.Offset = offset
				end,
			}),
		},
	})
end)
