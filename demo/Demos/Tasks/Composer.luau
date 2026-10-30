--!strict
--[[
	The inline to-do card, the discard guard and the delete dialogs.

	Shared state and helpers are on `app`. Each module adds what the ones after it need.
]]
local Common = require(script.Parent.Common)
local Pantheon, Children, peek = Common.Pantheon, Common.Children, Common.peek

return function(app: any)
	local confirmDelete, confirmOpen, deleteDraft, draftNotes, draftTitle, editingId, editorOpen, isDirty, moveButton, overlayLayer, router, saveDraft, scope, tagsButton, theme, whenButton =
		app.confirmDelete,
		app.confirmOpen,
		app.deleteDraft,
		app.draftNotes,
		app.draftTitle,
		app.editingId,
		app.editorOpen,
		app.isDirty,
		app.moveButton,
		app.overlayLayer,
		app.router,
		app.saveDraft,
		app.scope,
		app.tagsButton,
		app.theme,
		app.whenButton
	----------------------------------------------------------------------------
	-- The to-do card. It is small: a title, notes and three icons. When, tags and the
	-- project open popovers.
	----------------------------------------------------------------------------

	local isEditing = scope:Computed(function(use: any)
		return use(editingId) ~= 0
	end)

	-- Opens and closes a block with a fade and a change of height, so what is under it moves
	-- smoothly. The block keeps its own height, and the wrapper follows it.
	local function reveal(content: GuiObject, open: any, order: number): Instance
		local natural = scope:Value(0)
		table.insert(
			scope,
			content:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				natural:set(content.AbsoluteSize.Y)
			end)
		)
		local progress = scope:Spring(
			scope:Computed(function(use: any)
				return if use(open) then 1 else 0
			end),
			theme.Motion.SpringSpeed,
			theme.Motion.SpringDamping
		)
		Pantheon.GroupFade.bind(scope, content, progress)
		return scope:Frame({
			Name = "Reveal",
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			LayoutOrder = order,
			Size = scope:Computed(function(use: any)
				return UDim2.new(1, 0, 0, math.floor(use(progress) * use(natural) + 0.5))
			end),
			Visible = scope:Computed(function(use: any)
				return use(progress) > 0.01
			end),
			[Children] = { content },
		})
	end

	local composerCard = scope:Frame({
		Name = "Composer",
		BackgroundColor3 = theme.Colors.SurfaceContainer,
		CornerRadius = theme.Metrics.RadiusMd,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Padding = { theme.Metrics.SpaceSm, theme.Metrics.SpaceSm },
		Layout = {
			Kind = "List",
			Padding = theme.Metrics.SpaceXs,
			SortOrder = Enum.SortOrder.LayoutOrder,
		},
		[Children] = {
			scope:TextField({
				Placeholder = "New To-Do",
				Text = draftTitle,
				LayoutOrder = 1,
			}),
			scope:TextField({
				Placeholder = "Notes",
				Text = draftNotes,
				Multiline = true,
				MinLines = 2,
				MaxLines = 5,
				LayoutOrder = 2,
			}),
			scope:Frame({
				Name = "Footer",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 3,
				Layout = {
					Kind = "List",
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = theme.Metrics.Space2xs,
					SortOrder = Enum.SortOrder.LayoutOrder,
				},
				[Children] = {
					-- What is set, then the choices, then what to do with the card.
					scope:Frame({
						Name = "Spacer",
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 0, 0, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						LayoutOrder = 1,
						Flex = { FlexMode = Enum.UIFlexMode.Fill },
					}),
					whenButton,
					tagsButton,
					moveButton,
					scope:IconButton({
						Name = "trash-2",
						LayoutOrder = 5,
						Visible = isEditing,
						OnClick = function()
							if peek(confirmDelete) then
								confirmOpen:set(true)
							else
								deleteDraft()
							end
						end,
					}),
					scope:IconButton({
						Name = "x",
						LayoutOrder = 6,
						OnClick = function()
							editorOpen:set(false)
						end,
					}),
					scope:IconButton({
						Name = "check",
						Variant = "Filled",
						LayoutOrder = 7,
						OnClick = saveDraft,
					}),
				},
			}),
		},
	})

	local composer = reveal(composerCard, editorOpen, 2)

	-- Going to another page closes the card. If something has been entered, ask first.
	local discardOpen = scope:Value(false)
	local pendingUrl = ""
	app.beforeNavigate = function(to: any): boolean
		if not peek(editorOpen) then
			return true
		end
		if not isDirty() then
			editorOpen:set(false)
			return true
		end
		pendingUrl = to.Url
		discardOpen:set(true)
		return false
	end
	scope:Prompt({
		Destructive = true,
		Layer = overlayLayer,
		Open = discardOpen,
		Title = "Discard your changes?",
		Body = "The to-do in the card has changes that are not saved.",
		Icon = "circle-alert",
		ConfirmText = "Discard",
		OnConfirm = function()
			discardOpen:set(false)
			editorOpen:set(false)
			router:Push(pendingUrl)
		end,
		OnClose = function()
			discardOpen:set(false)
		end,
	})

	scope:Prompt({
		Destructive = true,
		Layer = overlayLayer,
		Open = confirmOpen,
		Title = "Delete this to-do?",
		Body = "You cannot undo this.",
		Icon = "trash-2",
		ConfirmText = "Delete",
		OnConfirm = deleteDraft,
		OnClose = function()
			confirmOpen:set(false)
		end,
	})

	app.composer = composer
	app.reveal = reveal
end
