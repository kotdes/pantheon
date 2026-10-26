--!strict
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Accessibility)

export type ListItemStyle = {
	TitleFont: Font,
	TitleSize: number,
	SubtitleFont: Font,
	SubtitleSize: number,
	PaddingY: number,
	PaddingX: number,
	Gap: number,
	Radius: number,
	IconSize: number,
	Height: number,
	HeightWithSubtitle: number,
}

return function(theme: Types.Theme): ListItemStyle
	return {
		TitleFont = theme.Typography.Title.Font,
		TitleSize = A.size(theme, 15),
		SubtitleFont = theme.Typography.Body.Font,
		SubtitleSize = A.size(theme, 12),
		PaddingY = theme.Metrics.SpaceXs,
		PaddingX = theme.Metrics.SpaceMd,
		Gap = theme.Metrics.SpaceSm,
		Radius = theme.Metrics.RadiusSm,
		IconSize = 20,
		Height = 48,
		HeightWithSubtitle = 56,
	}
end
