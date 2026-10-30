--!strict
local StoryUtil = require(script.Parent.Parent.StoryUtil)

return StoryUtil.story(function(scope, _, ctx)
	local sheetOpen = scope:Value(false)
	local popoverOpen = scope:Value(false)
	local picked = scope:Value("None yet")
	local sheetButton = scope:Button({
		Text = "Open as sheet",
		Variant = "Tonal",
		OnClick = function()
			sheetOpen:set(true)
		end,
	})
	local popoverButton = scope:Button({
		Text = "Open as popover",
		Variant = "Tonal",
		OnClick = function()
			popoverOpen:set(true)
		end,
	})
	scope:EmojiPicker({
		Layer = ctx.overlayLayer,
		Open = sheetOpen,
		OnPick = function(emoji: string)
			picked:set(emoji)
		end,
		OnClose = function()
			sheetOpen:set(false)
		end,
	})
	scope:EmojiPicker({
		Layer = ctx.overlayLayer,
		Variant = "Popover",
		Target = popoverButton,
		Open = popoverOpen,
		OnPick = function(emoji: string)
			picked:set(emoji)
		end,
		OnClose = function()
			popoverOpen:set(false)
		end,
	})
	return scope:Frame({
		Name = "EmojiPickerStory",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Layout = {
			Kind = "List",
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = 12,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[scope.Children] = {
			sheetButton,
			popoverButton,
			scope:Text({ Text = picked }),
		},
	})
end)
