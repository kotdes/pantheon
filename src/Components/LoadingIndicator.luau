--!strict
--[[
	LoadingIndicator: indeterminate loading indicators behind one `Kind`.

	  M3Morph    (default) Material 3 shape-morphing indicator
	  M2Spinner  Material 2 spinning ring arc (set `Background` to the surface behind it)
	  Beachball  macOS-style spinning rainbow pinwheel
	  Dots       three bouncing dots (typing / "thinking")
	  Bars       equalizer bars
	  Ripple     rings expanding from a centre dot
	  Orbit      dots chasing each other round a circle
	  Gnome      thin ring with a small dot (and fading trail) circling it
	  Icon       any Lucide icon with a motion preset

	For a determinate ring use Progress { Variant = "Circular" }.
]]
local Types = require(script.Parent.Parent.Types)
local LoadingMorph = require(script.Parent.Parent.Internal.LoadingMorph)
local LoadingKinds = require(script.Parent.Parent.Internal.LoadingKinds)
local Progress = require(script.Parent.Progress)

return function(scope: Types.Scope, props: Types.LoadingIndicatorProps): Instance
	local kind = props.Kind or "M3Morph"
	if kind == "M3Morph" then
		return LoadingMorph(scope, props)
	elseif kind == "M2Spinner" then
		return Progress(scope, {
			Theme = props.Theme,
			Variant = "Circular" :: Types.ProgressVariant,
			Mode = "Indeterminate" :: Types.ProgressMode,
			Indicator = "Arc",
			Background = props.Background,
			SizePx = props.SizePx or 32,
			Size = props.Size,
			LayoutOrder = props.LayoutOrder,
			Visible = props.Visible,
			ZIndex = props.ZIndex,
		})
	end
	return LoadingKinds(scope, props)
end
