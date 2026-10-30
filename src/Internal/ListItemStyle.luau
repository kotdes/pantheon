--!strict
local Types = require(script.Parent.Parent.Types)
local A = require(script.Parent.Accessibility)

export type ListItemStyle = {
	TitleFont: Font,
	TitleSize: number,
	SubtitleFont: Font,
	SubtitleSize: number,
	PaddingY: number,
	--- Padding above and below a row that is as tall as its content, because it has a control
	--- under the text or its text wraps. A row with a fixed height gets its space from the height.
	PaddingYTall: number,
	PaddingX: number,
	Gap: number,
	Radius: number,
	IconSize: number,
	Height: number,
	HeightWithSubtitle: number,
}

return function(theme: Types.Theme, flat: boolean?): ListItemStyle
	if flat == true then
		-- Borderless rows with a round leading image: bold name, muted line under it.
		return {
			TitleFont = theme.Typography.BoldBody.Font,
			TitleSize = theme.Typography.BoldBody.Size,
			SubtitleFont = theme.Typography.Body.Font,
			SubtitleSize = theme.Typography.Label.Size,
			PaddingY = theme.Metrics.SpaceXs,
			PaddingYTall = theme.Metrics.SpaceSm,
			PaddingX = theme.Metrics.SpaceSm,
			Gap = theme.Metrics.SpaceMd,
			Radius = theme.Metrics.RadiusMd,
			IconSize = 44,
			Height = 64,
			HeightWithSubtitle = 72,
		}
	end
	return {
		TitleFont = theme.Typography.Title.Font,
		TitleSize = A.size(theme, 15),
		SubtitleFont = theme.Typography.Body.Font,
		SubtitleSize = A.size(theme, 12),
		PaddingY = theme.Metrics.SpaceXs,
		PaddingYTall = theme.Metrics.SpaceSm,
		PaddingX = theme.Metrics.SpaceMd,
		Gap = theme.Metrics.SpaceSm,
		Radius = theme.Metrics.RadiusSm,
		IconSize = 20,
		Height = 48,
		HeightWithSubtitle = 56,
	}
end
