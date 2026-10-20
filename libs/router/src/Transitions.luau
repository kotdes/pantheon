--!strict

local TweenService = game:GetService("TweenService")

local Types = require(script.Parent.Types)

export type SlideOptions = {
	Duration: number?,
	EasingStyle: Enum.EasingStyle?,
	EasingDirection: Enum.EasingDirection?,
}

local Transitions = {}

function Transitions.Slide(options: SlideOptions?): Types.Transition
	local settings: SlideOptions = options or {}
	local info = TweenInfo.new(
		settings.Duration or 0.25,
		settings.EasingStyle or Enum.EasingStyle.Quint,
		settings.EasingDirection or Enum.EasingDirection.Out
	)

	return function(transition: Types.TransitionInfo)
		local entering, leaving = transition.Entering, transition.Leaving
		if
			(transition.Direction ~= "Forward" and transition.Direction ~= "Back")
			or not entering:IsA("GuiObject")
			or not leaving:IsA("GuiObject")
		then
			transition.Finish()
			return
		end

		local sign = if transition.Direction == "Back" then -1 else 1
		local rest = entering.Position
		local gone = leaving.Position + UDim2.fromScale(-sign, 0)
		entering.Position = rest + UDim2.fromScale(sign, 0)

		TweenService:Create(entering, info, { Position = rest }):Play()
		local out = TweenService:Create(leaving, info, { Position = gone })
		out.Completed:Once(function()
			transition.Finish()
		end)
		out:Play()
	end
end

return Transitions
