--!strict
--[[
	Public types for pantheon (Cadence/Tithe design system).
]]

export type Scope = any
export type UsedAs<T> = T | any

export type Directive = {
	type: "Directive",
	apply: (self: any, scope: Scope, value: any, target: Instance) -> (),
	around: (
		(self: any, scope: Scope, value: any, build: () -> Instance, kind: string) -> Instance
	)?,
}

export type ThemeMode = "Light" | "Dark"

export type ThemeColors = {
	Primary: Color3,
	OnPrimary: Color3,
	PrimaryContainer: Color3,
	OnPrimaryContainer: Color3,
	Background: Color3,
	Surface: Color3,
	SurfaceDim: Color3,
	SurfaceBright: Color3,
	OnSurface: Color3,
	OnSurfaceVariant: Color3,
	SurfaceContainer: Color3,
	SurfaceContainerHigh: Color3,
	Outline: Color3,
	OutlineVariant: Color3,
	Error: Color3,
	OnError: Color3,
	Success: Color3,
	OnSuccess: Color3,
	Warning: Color3,
	OnWarning: Color3,
	Scrim: Color3,
	--- Contrasting surface for toasts / tips: dark in light mode, light in dark mode.
	InverseSurface: Color3,
	InverseOnSurface: Color3,
	InversePrimary: Color3,
	Info: Color3,
	OnInfo: Color3,
}

export type ThemeFonts = {
	Heading: Font,
	Body: Font,
	Mono: Font,
}

export type ThemeMetrics = {
	Space2xs: number,
	SpaceXs: number,
	SpaceSm: number,
	SpaceMd: number,
	SpaceLg: number,
	SpaceXl: number,
	--- Corner radius scale (px)
	RadiusNone: number,
	Radius2xs: number,
	RadiusXs: number,
	RadiusSm: number,
	RadiusMd: number,
	RadiusLg: number,
	RadiusXl: number,
	Radius2xl: number,
	Radius3xl: number,
	--- Semantic: cards / panels / sheets (typically = RadiusLg)
	RadiusPanel: number,
	--- Fully rounded (pills, avatars, switches)
	RadiusPill: number,
	AppBarHeight: number,
	DrawerWidth: number,
	RailWidth: number,
	ButtonPadX: number,
	ButtonPadY: number,
}

export type TypeScale = {
	Font: Font,
	Size: number,
	LineHeight: number,
}

export type ThemeTypography = {
	Display: TypeScale,
	Headline: TypeScale,
	Title: TypeScale,
	Button: TypeScale,
	Body: TypeScale,
	Label: TypeScale,
	Mono: TypeScale,
	[string]: TypeScale,
}

export type ThemeColorRole = {
	Base: Color3,
	OnBase: Color3,
	Container: Color3,
	OnContainer: Color3,
}

--- Extensible palette; defaults use Material-ish names (primary, secondary, …).
export type ThemePalette = { [string]: ThemeColorRole }

--- Color3 | hex | RGB {r,g,b} | palette name | Material swatch ("Blue 500") | { Blue = 500 } | role
export type ColorInput = Color3 | string | { number } | { [string]: number | string } | ThemeColorRole

export type ThemeMotion = {
	SpringSpeed: number,
	SpringDamping: number,
	PressScale: number,
}

export type PreferredTextSizeName = "Medium" | "Large" | "Larger" | "Largest"

export type AccessibilityPrefs = {
	ReduceMotion: boolean?,
	PreferredTransparency: number?,
	HighContrast: boolean?,
	PreferredTextSize: PreferredTextSizeName?,
}

--- Control chrome defaults (iOS-style switch I/O labels, etc.)
export type ThemeControls = {
	--- Show I / O glyphs on Switch tracks (iOS “Show On/Off Labels”).
	SwitchIcons: boolean?,
}

export type ThemeIcons = { [string]: string }
export type ThemeAudio = { [string]: string }

export type Theme = {
	Mode: ThemeMode,
	Colors: ThemeColors,
	--- Named colors for Color= props (primary, secondary, error, custom, …)
	Palette: ThemePalette,
	Fonts: ThemeFonts,
	Typography: ThemeTypography,
	Metrics: ThemeMetrics,
	Motion: ThemeMotion,
	Icons: ThemeIcons,
	Audio: ThemeAudio,
	Controls: ThemeControls,
	Accessibility: AccessibilityPrefs?,
}

export type ThemeRef = UsedAs<Theme>

--- Style only (Vuetify-like). Legacy names still accepted on Button.
export type ButtonVariant = "Filled" | "Tonal" | "Outlined" | "Text" | "Primary" | "Destructive"

export type TextVariant = string
export type AlertTone = "Info" | "Success" | "Warning" | "Error"
export type ProgressVariant = "Linear" | "Circular"
export type ProgressMode = "Determinate" | "Indeterminate" | "Buffering"
--- Determinate circular look: "Standard" = Material 3 (round caps, track gap); "Classic" = Material 2 (butt caps, full track).
export type ProgressStyle = "Standard" | "Classic"

-- Shared base
export type BaseProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	--- Top-level UI frame for overlays (dialogs, menus, toasts, drawers).
	--- Prefer providing this so overlays do not shift content layout.
	Layer: Instance?,
	[string]: any,
}

export type ButtonProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Text: UsedAs<string>?,
	--- Style: Filled | Tonal | Outlined | Text (legacy Primary/Destructive still work)
	Variant: (ButtonVariant | string)?,
	--- Palette name, Color3, hex, RGB table, or ThemeColorRole
	Color: UsedAs<ColorInput>?,
	OnClick: (() -> ())?,
	Disabled: UsedAs<boolean>?,
	Icon: string?,
	--- Lucide icon before label
	LeadingIcon: string?,
	--- Lucide icon after label
	TrailingIcon: string?,
	HorizontalAlignment: Enum.HorizontalAlignment?,
	CornerRadius: number?,
	Padding: { number }?,
	[string]: any,
}

export type TextFieldResize = "None" | "Y" | "X" | "Both"

export type Validator = (value: any) -> (boolean, string?)

export type TextFieldProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Text: UsedAs<string>?,
	Placeholder: UsedAs<string>?,
	Label: UsedAs<string>?,
	Helper: UsedAs<string>?,
	Error: UsedAs<string>?,
	OnChanged: ((string) -> ())?,
	Multiline: boolean?,
	MinLines: number?,
	MaxLines: number?,
	--- Corner grip resize (Material-style). Default `Y` when Multiline.
	Resize: TextFieldResize?,
	Disabled: UsedAs<boolean>?,
	LeadingIcon: string?,
	TrailingIcon: string?,
	Validators: { Validator }?,
	--- Validate on focus lost (default true when Validators set)
	ValidateOnBlur: boolean?,
	--- Small variant for in-widget fields: 28px tall, tighter padding, 13px text.
	Compact: boolean?,
	--- Fully rounded ends, for a search field.
	Pill: boolean?,
	--- Input height in px (default 40, or 28 when `Compact`).
	Height: number?,
	--- Static text shown inside the left edge, e.g. "#".
	Prefix: string?,
	--- Called when the box loses focus (Enter or click away) with the text and the TextBox,
	--- so the caller can commit the value or restore the old text.
	OnSubmit: ((text: string, box: TextBox) -> ())?,
	[string]: any,
}

export type TextProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Text: UsedAs<string>,
	Variant: TextVariant?,
	Color: UsedAs<Color3>?,
	TextXAlignment: Enum.TextXAlignment?,
	TextWrapped: boolean?,
	[string]: any,
}

export type ListItemProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Title: UsedAs<string>,
	Subtitle: UsedAs<string>?,
	OnClick: (() -> ())?,
	Leading: Instance?,
	Trailing: Instance?,
	Disabled: UsedAs<boolean>?,
	[string]: any,
}

export type ChipProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Text: UsedAs<string>,
	Selected: UsedAs<boolean>?,
	OnClick: (() -> ())?,
	Disabled: UsedAs<boolean>?,
	LeadingIcon: string?,
	TrailingIcon: string?,
	[string]: any,
}

export type DialogAction = {
	Text: string,
	Variant: (ButtonVariant | string)?,
	Color: ColorInput?,
	OnClick: (() -> ())?,
}

export type DialogProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Title: UsedAs<string>,
	Body: UsedAs<string>?,
	Actions: { DialogAction }?,
	OnClose: (() -> ())?,
	Open: UsedAs<boolean>?,
	--- Optional custom body content (forms, etc.)
	Children: any?,
	--- Optional Lucide icon above the title (alerts / confirms).
	Icon: string?,
	IconColor: UsedAs<Color3>?,
	IconSize: number?,
	[string]: any,
}

export type PromptProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Title: UsedAs<string>,
	Body: UsedAs<string>?,
	Actions: { DialogAction }?,
	OnClose: (() -> ())?,
	Open: UsedAs<boolean>?,
	Children: any?,
	Icon: string?,
	IconColor: UsedAs<Color3>?,
	IconSize: number?,
	OnConfirm: (() -> ())?,
	ConfirmText: string?,
	CancelText: string?,
	Destructive: boolean?,
	[string]: any,
}

export type ConfirmDialogProps = PromptProps

export type SurfaceProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Name: string?,
	Elevated: boolean?,
	[string]: any,
}

export type OverlayProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	OnClick: (() -> ())?,
	[string]: any,
}

export type IconProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Name: string?, -- Lucide icon id
	Image: string?,
	Color: UsedAs<Color3>?,
	IconSize: number?,
	AssetSize: number?,
	[string]: any,
}

export type IconButtonProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Name: string?,
	Image: string?,
	OnClick: (() -> ())?,
	Disabled: UsedAs<boolean>?,
	[string]: any,
}

export type CheckboxProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Checked: UsedAs<boolean>?,
	Label: UsedAs<string>?,
	OnChanged: ((boolean) -> ())?,
	Disabled: UsedAs<boolean>?,
	[string]: any,
}

export type SwitchProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Checked: UsedAs<boolean>?,
	Label: UsedAs<string>?,
	--- Fill the width: label on the left, switch on the right.
	Fill: boolean?,
	OnChanged: ((boolean) -> ())?,
	Disabled: UsedAs<boolean>?,
	--- Override Theme.Controls.SwitchIcons for this switch.
	Icons: boolean?,
	[string]: any,
}

export type RadioOption = {
	Value: string,
	Label: string,
}

export type RadioProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Checked: UsedAs<boolean>,
	Label: UsedAs<string>?,
	OnClick: (() -> ())?,
	Disabled: UsedAs<boolean>?,
	[string]: any,
}

export type RadioGroupProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Options: { RadioOption },
	Value: UsedAs<string>?,
	OnChanged: ((string) -> ())?,
	Disabled: UsedAs<boolean>?,
	[string]: any,
}

export type SelectOption = {
	Value: string,
	Label: string,
}

export type SelectProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Options: { SelectOption },
	Value: UsedAs<string>?,
	Placeholder: UsedAs<string>?,
	Label: UsedAs<string>?,
	OnChanged: ((string) -> ())?,
	Disabled: UsedAs<boolean>?,
	Filterable: boolean?,
	Validators: { Validator }?,
	[string]: any,
}

export type MultiSelectProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Options: { SelectOption },
	Value: UsedAs<{ string }>?,
	Placeholder: UsedAs<string>?,
	Label: UsedAs<string>?,
	OnChanged: (({ string }) -> ())?,
	Disabled: UsedAs<boolean>?,
	Validators: { Validator }?,
	--- `Chips` (default) shows a chip per selection; `Count` shows "N selected".
	Display: ("Chips" | "Count")?,
	[string]: any,
}

export type LoadingIndicatorKind =
	"M3Morph"
	| "M2Spinner"
	| "Beachball"
	| "Dots"
	| "Bars"
	| "Ripple"
	| "Orbit"
	| "Gnome"
	| "Icon"
export type LoadingIndicatorMotion = "Spin" | "Pulse" | "Bounce" | "Flip" | "Wiggle"

export type LoadingIndicatorProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	--- Which indicator to draw (default "M3Morph").
	Kind: LoadingIndicatorKind?,
	--- Square size in px (default 48 for M3Morph, 32 for the other kinds).
	SizePx: number?,
	--- M3Morph: draw the shape inside a round PrimaryContainer disc (Material 3 "contained").
	Contained: boolean?,
	--- M3Morph: shape names to cycle through; default is the Material 3 sequence.
	Shapes: { string }?,
	--- M2Spinner: colour the arc "erases" with. Match the surface behind the spinner.
	Background: Color3?,
	--- Static colour for Dots, Bars, Ripple, Orbit, Gnome and Icon (default theme Primary).
	Color: Color3?,
	--- Icon: Lucide icon name (default "loader").
	Icon: string?,
	--- Icon: motion preset (default "Spin").
	Motion: LoadingIndicatorMotion?,
	[string]: any,
}

export type NumberSpinnerProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	--- The number to show; digits roll when it changes.
	Value: UsedAs<number>,
	--- Digits after the decimal point (default 0).
	Decimals: number?,
	--- Thousands separators (default true).
	Grouping: boolean?,
	Prefix: string?,
	Suffix: string?,
	TextSize: number?,
	FontFace: Font?,
	Color: Color3?,
	--- Width of one digit column in px (default ≈ 0.62 × TextSize).
	DigitWidth: number?,
	--- Integer digit slots to reserve so the box never resizes (default: initial digits + 1, min 4).
	Digits: number?,
	--- Fixed box width in px; overrides `Digits`.
	Width: number?,
	--- "Numeric" (default): iOS's numericText: a changed digit goes straight to its new value,
	--- sliding, scaling and blurring in and out, columns cascading left to right. "Roll": an
	--- odometer wheel through every digit in between.
	Style: ("Numeric" | "Roll")?,
	--- "Numeric" only: playback speed, 1 = default (< 1 slower, > 1 faster).
	Speed: number?,
	--- "Numeric" only: how much the landing overshoots, 0 = none to 1 = very bouncy
	--- (default 0.8, about a 25% overshoot; iOS itself is closer to 0.6).
	Bounce: number?,
	--- Padding in px around the digits for their travel and blur (default derived from the
	--- text size). The box clips to it.
	Padding: number?,
	--- "Roll" only: spring speed (default 11) and damping ratio (default 0.6, < 1 overshoots).
	SpringSpeed: number?,
	SpringDamping: number?,
	Align: Enum.HorizontalAlignment?,
	[string]: any,
}

export type CoachmarkProps = {
	Theme: ThemeRef?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	--- The element to point at.
	Target: UsedAs<Instance>,
	--- Shown while true. Pass a Value so the card can close itself.
	Open: UsedAs<boolean>?,
	Title: UsedAs<string>?,
	Text: UsedAs<string>?,
	--- Small caption above the title, e.g. "1 of 3".
	Step: UsedAs<string>?,
	--- Action button label (default "Got it"); it also dismisses.
	ActionText: UsedAs<string>?,
	OnAction: (() -> ())?,
	OnClose: (() -> ())?,
	Placement: TooltipPlacement?,
	--- Dim everything but the target (default true).
	Spotlight: boolean?,
	--- Scrim opacity 0–1 (default 0.55).
	Dim: number?,
	--- Tapping the dimmed area dismisses.
	DismissOnScrim: boolean?,
	--- px of breathing room around the target's cutout (default 6).
	TargetPadding: number?,
	--- px between target and card (default 16).
	Gap: number?,
	Width: number?,
	--- "Primary" (default, solid brand colour) or "Surface".
	Tone: ("Primary" | "Surface")?,
	[string]: any,
}

export type SliderProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Value: UsedAs<number>?,
	Min: number?,
	Max: number?,
	Step: number?,
	OnChanged: ((number) -> ())?,
	Disabled: UsedAs<boolean>?,
	Label: UsedAs<string>?,
	[string]: any,
}

export type RangeSliderProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Value: UsedAs<NumberRange>?,
	Min: number?,
	Max: number?,
	--- Values snap to multiples of this (default 0.01).
	Step: number?,
	OnChanged: ((NumberRange) -> ())?,
	Disabled: UsedAs<boolean>?,
	Label: UsedAs<string>?,
	[string]: any,
}

export type AlertProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Title: UsedAs<string>?,
	Text: UsedAs<string>,
	Tone: AlertTone?,
	[string]: any,
}

export type SnackbarProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Message: UsedAs<string>,
	ActionText: string?,
	OnAction: (() -> ())?,
	--- Element before the message. Wins over `Icon`.
	Leading: Instance?,
	--- Lucide icon before the message.
	Icon: string?,
	--- Element after the action button.
	Trailing: Instance?,
	--- Show a close button at the end.
	Dismissible: boolean?,
	--- Called when the close button is pressed.
	OnClose: (() -> ())?,
	--- Let the message wrap and fill the width, for a fixed-width card (the host does this).
	Fill: boolean?,
	[string]: any,
}

export type SnackbarHostProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	--- Most toasts kept at once; the oldest is dismissed past this (default 5).
	MaxVisible: number?,
	--- Width of the stack in px (default 360).
	Width: number?,
	-- The host is driven by the table it returns; see Components.SnackbarHost
	[string]: any,
}

export type ProgressProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Value: UsedAs<number>?,
	Buffer: UsedAs<number>?,
	Variant: ProgressVariant?,
	Mode: ProgressMode?,
	--- Circular only. Outer diameter in px (default 40).
	SizePx: number?,
	--- Circular only.
	Style: ProgressStyle?,
	--- Circular only. Stroke thickness in px.
	Thickness: number?,
	--- Circular indeterminate only: "Morph" (default) or "Arc".
	Indicator: ("Morph" | "Arc")?,
	--- Circular "Arc" indeterminate only: colour the arc erases with (default Surface).
	Background: Color3?,
	[string]: any,
}

export type BadgeProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Content: Instance,
	Count: UsedAs<number>?,
	Dot: boolean?,
	[string]: any,
}

export type TabItem = {
	Id: string,
	Label: string,
}

export type TabsProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Items: { TabItem },
	Selected: UsedAs<string>?,
	OnChanged: ((string) -> ())?,
	[string]: any,
}

export type DividerProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Vertical: boolean?,
	[string]: any,
}

export type CardProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Title: UsedAs<string>?,
	Subtitle: UsedAs<string>?,
	Children: any?,
	[string]: any,
}

export type AppBarProps = {
	Radius: any?,
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Title: UsedAs<string>?,
	Leading: Instance?,
	Actions: { Instance }?,
	--- At the top of the scroll the fill becomes `FadeTo` and the divider and shadow are hidden.
	--- They come back as content scrolls under the bar.
	FadeAtTop: boolean?,
	--- Scroll offset in px (state or number) that drives FadeAtTop.
	ScrollOffset: UsedAs<number>?,
	--- Scroll distance in px over which the bar goes from flat to raised (default 24).
	FadeRamp: number?,
	--- Fill at the top of the scroll. Match your content or window fill
	--- (default SurfaceContainerHigh, the elevated Window fill).
	FadeTo: Color3?,
	--- Fill once the bar is raised (default Surface).
	RaisedColor: Color3?,
	--- false removes the shadow (default on).
	Shadow: boolean?,
	Variant: ("Solid" | "Gradient")?,
	FadeHeight: number?,
	TitleContent: Instance?,
	[string]: any,
}

export type FooterProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Radius: any?,
	Height: number?,
	Variant: ("Solid" | "Gradient")?,
	FadeHeight: number?,
	FadeTo: Color3?,
	Children: any?,
	[string]: any,
}

export type NavigationDrawerProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Open: UsedAs<boolean>?,
	Title: UsedAs<string>?,
	Subtitle: UsedAs<string>?,
	AvatarImage: string?,
	AvatarInitials: string?,
	--- Flat actions (Menu-style). Prefer `Sections` for categories.
	Items: { any }?,
	Sections: { MenuSectionProps }?,
	OnClose: (() -> ())?,
	Children: any?,
	--- Gap in px from the parent edges. Use `4` inside a Window.
	Inset: number?,
	--- Panel corner radius (px). Window drawers typically use `RadiusPanel + 4`.
	CornerRadius: number?,
	--- First MenuPage id when composing `Children`.
	RootPage: string?,
	Page: UsedAs<string>?,
	OnChanged: ((string) -> ())?,
	--- Cap embedded menu height (px). Omit to fill.
	MaxHeight: number?,
	--- Content above the menu, such as window buttons or a profile. Give it a fixed height.
	Header: Instance?,
	Footer: Instance?,
	HideScrollBar: boolean?,
	--- Width of the drawer's parent, in px, from which the drawer stays open beside the content,
	--- like a sidebar. Below that width it slides in over the content. Omit to never dock.
	DockAt: number?,
	--- Runs with `true` when the drawer docks and `false` when it floats again.
	OnDockChanged: ((boolean) -> ())?,
	[string]: any,
}

export type NavigationRailProps = {
	--- Vertical rails only: a control shown above the items, e.g. a menu button (so it can
	--- live in the rail instead of the app bar).
	Leading: Instance?,
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Items: { { Id: string, Icon: string?, Label: string?, OnClick: (() -> ())? } },
	Selected: UsedAs<string>?,
	OnChanged: ((string) -> ())?,
	--- Default `Vertical` (side rail). `Horizontal` lays items in a row.
	Orientation: ("Vertical" | "Horizontal")?,
	--- false removes the shadow (default on).
	Shadow: boolean?,
	[string]: any,
}

--- App chrome shell: elevated Sheet colors + optional AppBar / NavigationRail / content / overlays.
export type WindowProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Position: UsedAs<UDim2>?,
	AnchorPoint: UsedAs<Vector2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	AppBar: Instance?,
	Footer: Instance?,
	--- What to drag the window by when there is no `AppBar`. It is a part of your content, such
	--- as a strip along the top.
	DragHandle: Instance?,
	NavigationRail: Instance?,
	--- Main content; fills space beside/above the rail.
	Children: any?,
	--- Drawers, menus and dialogs. They are reparented onto the window overlay layer.
	Overlays: { Instance }?,
	--- Layout for the rail slot. Defaults by inferring from `NavigationRail.Size`
	--- (horizontal rails use full-width × ~72px). Prefer setting explicitly when unsure.
	--- Also set `NavigationRail.Orientation` to match.
	RailOrientation: ("Vertical" | "Horizontal")?,
	--- Outer chrome radius (default `RadiusPanel`).
	CornerRadius: number?,
	--- Sheet elevation (default true).
	Elevated: boolean?,
	--- Drag the window by its app bar.
	Draggable: boolean?,
	--- "Titlebar" (default): the window may leave the screen but its handle stays reachable;
	--- "Screen": keep it fully on screen; "Free": no limit.
	DragBounds: ("Titlebar" | "Screen" | "Free")?,
	--- px of the window that must stay on screen horizontally for "Titlebar" (default 120).
	DragKeepVisible: number?,
	--- Show resize handles on the window's edges and corners (default off).
	Resizable: boolean?,
	--- Smallest size in px while resizing (default 240 × 160).
	MinSize: Vector2?,
	--- Largest size in px while resizing (default: the screen).
	MaxSize: Vector2?,
	--- Lock the aspect ratio (width / height) while resizing. Defaults to the window's own
	--- `AspectRatio` constraint if it has one.
	ResizeRatio: number?,
	--- Which handles to show: any of "Left", "Right", "Top", "Bottom", "TopLeft", "TopRight",
	--- "BottomLeft", "BottomRight" (default all).
	ResizeHandles: { string }?,
	--- Width of the edge handles in px (default 6; corners are twice that).
	ResizeHandleSize: number?,
	--- Snap the size to multiples of this many px.
	ResizeSnap: number?,
	--- Called with the new size on every resize step. Pass a Value as `Size` / `Position` to
	--- keep them across rebuilds.
	OnResized: ((Vector2) -> ())?,
	[string]: any,
}

export type BreadcrumbItem = {
	Label: string,
	OnClick: (() -> ())?,
}

export type BreadcrumbsProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Items: { BreadcrumbItem },
	[string]: any,
}

export type PaginationProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Page: UsedAs<number>?,
	PageCount: number,
	OnChanged: ((number) -> ())?,
	[string]: any,
}

export type ContainerProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	MaxWidth: number?,
	Children: any?,
	[string]: any,
}

export type MenuSlot = string | Instance

export type MenuItemProps = {
	Text: UsedAs<string>,
	OnClick: (() -> ())?,
	Disabled: UsedAs<boolean>?,
	--- Lucide icon or custom instance before the label.
	Leading: MenuSlot?,
	--- Lucide icon or custom instance after the label.
	Trailing: MenuSlot?,
	--- Alias for `Leading` when it is a Lucide icon name.
	LeadingIcon: string?,
	--- Alias for `Trailing` when it is a Lucide icon name.
	TrailingIcon: string?,
	--- Palette / Color3 tint for label + icons (e.g. `"error"`).
	Color: UsedAs<ColorInput>?,
	--- Push this MenuPage id (does not close the menu).
	Page: string?,
	Selected: UsedAs<boolean>?,
	[string]: any,
}

export type MenuButtonProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Text: UsedAs<string>,
	OnClick: (() -> ())?,
	Disabled: UsedAs<boolean>?,
	Leading: MenuSlot?,
	Trailing: MenuSlot?,
	LeadingIcon: string?,
	TrailingIcon: string?,
	Color: UsedAs<ColorInput>?,
	Page: string?,
	--- Fill the row with the primary container, as the current choice. Follows a state.
	Selected: UsedAs<boolean>?,
	--- No fill until the row is hovered or pressed, for rows on a surface of their own.
	Flat: boolean?,
	--- Compact row (40px). False uses the taller header-menu row (44px). Default true.
	Compact: boolean?,
	--- Invoked after `OnClick` (Menu wires this when building from Items/Sections).
	OnClose: (() -> ())?,
	Children: any?,
	[string]: any,
}

export type MenuSectionProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	--- Optional category label above this group of items.
	Title: UsedAs<string>?,
	--- Lucide icon before the category title (prepend only).
	Icon: string?,
	--- Data-driven rows (built as MenuButtons). Prefer `Children` when composing.
	Items: { any }?,
	--- Composed MenuButtons (or other content).
	Children: any?,
	--- Category header can collapse/expand its items.
	Collapsible: boolean?,
	--- Whether a collapsible group is open (default true). A plain boolean is the starting
	--- state; pass a Value to control it.
	Expanded: UsedAs<boolean>?,
	OnChanged: ((boolean) -> ())?,
	Compact: boolean?,
	OnClose: (() -> ())?,
	[string]: any,
}

export type MenuPageProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Id: string,
	--- Subpage bar title; also enables the back control.
	Title: UsedAs<string>?,
	Children: any?,
	[string]: any,
}

export type MenuProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	--- Flat item list (used when `Sections` is nil). Prefer composing MenuButton.
	Items: { any }?,
	--- Grouped items with optional category titles. Prefer composing MenuSection.
	Sections: { MenuSectionProps }?,
	Open: UsedAs<boolean>?,
	OnClose: (() -> ())?,
	--- Optional content above the item list (e.g. AvatarMenu profile header).
	Header: any?,
	Footer: any?,
	HideScrollBar: boolean?,
	--- Composed MenuSection / MenuButton / MenuPage (also appended after Items/Sections).
	Children: any?,
	--- Cap list height; scrolls when content exceeds this (px).
	MaxHeight: number?,
	--- Size the menu to its content, up to `MaxHeight`, with a spring (default true). A menu with
	--- pages follows the page that is showing.
	AutoHeight: boolean?,
	--- When true, list fills remaining height and scrolls (fixed `Size` required).
	Fill: boolean?,
	--- Override panel corner radius (default `RadiusPanel`).
	CornerRadius: number?,
	--- Outer padding (default 4).
	Padding: number?,
	--- When true, skip Layer.mount. The parent owns layering (AvatarMenu, Popover).
	Embedded: boolean?,
	--- First MenuPage id (default: first page child).
	RootPage: string?,
	--- Controlled page id; Menu pushes/pops to match.
	Page: UsedAs<string>?,
	OnChanged: ((string) -> ())?,
	[string]: any,
}

export type PopoverProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Open: UsedAs<boolean>?,
	OnClose: (() -> ())?,
	--- Anchor to position relative to (screen space).
	Target: Instance?,
	--- Preferred placement relative to Target.
	Placement: ("Auto" | "Bottom" | "Top" | "Left" | "Right")?,
	Items: { any }?,
	Sections: { MenuSectionProps }?,
	MaxHeight: number?,
	Children: any?,
	Width: number?,
	--- Size the popover to its content, up to `MaxHeight`, with a spring (default true).
	AutoHeight: boolean?,
	--- First MenuPage id when the content has pages.
	RootPage: string?,
	Page: UsedAs<string>?,
	OnChanged: ((string) -> ())?,
	[string]: any,
}

export type AvatarMenuProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Open: UsedAs<boolean>?,
	OnClose: (() -> ())?,
	Target: Instance?,
	Sections: { MenuSectionProps }?,
	Children: any?,
	RootPage: string?,
	MaxHeight: number?,
	Image: string?,
	Initials: string?,
	Name: UsedAs<string>?,
	Subtitle: UsedAs<string>?,
	Items: { any }?,
	[string]: any,
}

export type TooltipPlacement = "Top" | "Bottom" | "Left" | "Right" | "Auto"

export type TooltipProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Text: UsedAs<string>,
	Target: Instance?,
	--- Preferred side of the target. `Auto` picks the side with most room.
	Placement: TooltipPlacement?,
	Gap: number?,
	[string]: any,
}

export type DatePickerProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Value: UsedAs<string>?, -- YYYY-MM-DD
	OnChanged: ((string) -> ())?,
	[string]: any,
}

export type TimePickerProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Value: UsedAs<number>?, -- seconds from midnight
	OnChanged: ((number) -> ())?,
	[string]: any,
}

export type ColorPickerProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Value: UsedAs<Color3>?,
	OnChanged: ((Color3) -> ())?,
	--- Opacity 0–1 (default 1). Pass a Value to keep it controlled.
	Alpha: UsedAs<number>?,
	OnAlphaChanged: ((number) -> ())?,
	--- Show the alpha slider (default true).
	ShowAlpha: boolean?,
	--- Tabs, in order: "Grid" (swatches), "Spectrum" (saturation/value + hue) and "Sliders".
	Modes: { string }?,
	--- Tab shown first (default: the first of `Modes`).
	Mode: string?,
	--- Colour models offered under the "Sliders" tab: "RGB", "HSB" (or "HSV"), "HSL", "LAB",
	--- "Hex". Default: all of them, in that order.
	Models: { string }?,
	--- Model shown first (default: the first of `Models`).
	Model: string?,
	--- "Square" (default) or "Wheel" for the Spectrum tab: a hue ring around the saturation/
	--- value square. The ring needs conical gradients (Studio beta) and falls back to the square.
	Area: ("Square" | "Wheel")?,
	--- Swatches for the Grid tab (default: a grey ramp plus a hue/lightness grid).
	Palette: { Color3 }?,
	--- Show the swatch / hex / alpha footer (default true).
	Footer: boolean?,
	--- Fill colour of the picker (default theme Surface).
	Background: Color3?,
	[string]: any,
}

export type GradientPickerProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	--- Where button tooltips are mounted. Without a layer, or one set with Layer.Provide / Layer.bind, there are no tooltips.
	Layer: Instance?,
	--- Starting gradient, one stop per keypoint, and its transparency (alpha = 1 - transparency).
	Gradient: UsedAs<ColorSequence>?,
	GradientTransparency: UsedAs<NumberSequence>?,
	GradientRotation: number?,
	--- Show the Alpha box (default true).
	ShowAlpha: boolean?,
	--- Called as stops are added, dragged, recoloured or removed. Feed straight into a
	--- UIGradient's Color / Transparency / Rotation / Offset.
	OnChanged: ((ColorSequence, NumberSequence, number, Vector2) -> ())?,
	--- Passed on to the node ColorPicker.
	Modes: { string }?,
	Models: { string }?,
	Mode: string?,
	Model: string?,
	Area: ("Square" | "Wheel")?,
	Palette: { Color3 }?,
	[string]: any,
}

export type VirtualListProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	ItemCount: UsedAs<number>,
	ItemHeight: number,
	RenderItem: (scope: Scope, index: number) -> Instance,
	Padding: number?,
	--- Scroll position in px. A `Value` scrolls the list when it is set.
	ScrollOffset: UsedAs<number>?,
	--- Called with the scroll position in px.
	OnScroll: ((offset: number) -> ())?,
	[string]: any,
}

export type DataTableColumn = {
	Id: string,
	Title: string,
	Width: number?,
	Sortable: boolean?,
}

export type DataTableProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Columns: { DataTableColumn },
	Rows: UsedAs<{ { [string]: any } }>,
	RowHeight: number?,
	SortColumn: UsedAs<string>?,
	SortAscending: UsedAs<boolean>?,
	OnSort: ((columnId: string, ascending: boolean) -> ())?,
	Selected: UsedAs<{ [number]: boolean }>?,
	OnSelect: ((index: number, selected: boolean) -> ())?,
	Filter: UsedAs<string>?,
}

export type AvatarProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Image: string?,
	Initials: string?,
	AvatarSize: number?,
	[string]: any,
}

export type EmptyStateProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Title: UsedAs<string>,
	Subtitle: UsedAs<string>?,
	Action: ButtonProps?,
	[string]: any,
}

export type SettingsListItem = {
	Id: string?,
	Title: UsedAs<string>,
	Subtitle: UsedAs<string>?,
	Icon: string?,
	OnClick: (() -> ())?,
	Trailing: Instance?,
	ShowChevron: boolean?,
	Disabled: boolean?,
	[string]: any,
}

export type SettingsListProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	--- Hub rows (iOS Settings style cards)
	Items: { any }?,
	--- Section title above the card group
	Header: UsedAs<string>?,
	Footer: UsedAs<string>?,
	Children: any?,
	InsetGrouped: boolean?,
	[string]: any,
}

export type AppSheetProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Open: UsedAs<boolean>?,
	Title: UsedAs<string>?,
	OnClose: (() -> ())?,
	Children: any?,
	--- Detent height scale 0–1 of host. Default 0.92
	Detent: number?,
	ShowGrabber: boolean?,
	[string]: any,
}

export type StarRatingProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Value: UsedAs<number>?,
	Max: number?,
	OnChanged: ((number) -> ())?,
	ReadOnly: boolean?,
	IconSize: number?,
	[string]: any,
}

export type SegmentedControlProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Items: { { Id: string, Label: string, Icon: string? } },
	Selected: UsedAs<string>?,
	OnChanged: ((string) -> ())?,
	Disabled: UsedAs<boolean>?,
	[string]: any,
}

export type TreeNode = {
	Id: string,
	Label: string,
	Icon: string?,
	Children: { TreeNode }?,
}

export type TreeViewProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Nodes: { TreeNode },
	Expanded: UsedAs<{ [string]: boolean }>?,
	Selected: UsedAs<string>?,
	OnSelect: ((id: string) -> ())?,
	OnToggle: ((id: string, expanded: boolean) -> ())?,
	[string]: any,
}

export type CollapsibleProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Title: UsedAs<string>,
	Open: UsedAs<boolean>?,
	OnChanged: ((boolean) -> ())?,
	Children: any?,
	[string]: any,
}

export type ChoiceGroupOption = {
	Value: string,
	Label: string,
	Disabled: boolean?,
}

export type ChoiceGroupProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Options: { ChoiceGroupOption },
	Value: UsedAs<string>?,
	OnChanged: ((string) -> ())?,
	Disabled: UsedAs<boolean>?,
	--- "Radio" | "Segmented"
	Variant: ("Radio" | "Segmented")?,
	Validators: { Validator }?,
	Label: UsedAs<string>?,
	[string]: any,
}

export type ScrollAreaProps = {
	Controller: { [string]: any }?,
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Children: any?,
	ClipsDescendants: boolean?,
	Orientation: ("Vertical" | "Horizontal")?,
	CollapseScrollBar: boolean?,
	ScrollBarThickness: number?,
	ScrollBarColor: Color3?,
	ScrollBarActiveColor: Color3?,
	ScrollBarRailThickness: number?,
	ScrollBarRailBackground: boolean?,
	ScrollBarRailColor: Color3?,
	ScrollBarPadding: number?,
	Smooth: boolean?,
	Inertia: boolean?,
	Keyboard: boolean?,
	AutoCanvas: boolean?,
	CanvasSize: UsedAs<UDim2>?,
	ScrollBarRail: boolean?,
	AutoHideScrollBar: boolean?,
	--- Draw the scroll bar over the content, so the content keeps its full width.
	ScrollBarOverlay: boolean?,
	ScrollBarHidden: boolean?,
	AutoHideDelay: number?,
	ScrollButtons: boolean?,
	ScrollButtonStep: number?,
	ScrollOffset: UsedAs<number>?,
	OnScroll: ((offset: number) -> ())?,
	--- Rubber-band overscroll for drag / top-edge wheel pull (when OnRefresh is set).
	--- Mid-list and bottom edges hard-clamp on wheel/trackpad. Default true when Inertia.
	Overscroll: boolean?,
	--- Pull action (fires on release past threshold). Vertical only. Not limited to refresh.
	OnRefresh: (() -> ())?,
	--- Called when pull is cancelled (released below threshold after pulling).
	OnPullCancel: (() -> ())?,
	RefreshThreshold: number?,
	--- Pass a boolean (or state) that is true while refreshing. The content then rests at the
	--- threshold with a spinner until it turns false, like iOS / Android pull-to-refresh.
	Refreshing: UsedAs<boolean>?,
	--- Shown beside the spinner while Refreshing. Default "Refreshing…".
	RefreshingHint: string?,
	--- Show built-in pull hint. Default true when OnRefresh is set.
	PullIndicator: boolean?,
	--- Below threshold while pulling.
	PullHint: string?,
	--- Past the threshold: release to confirm.
	ReleaseHint: string?,
	--- Drag anywhere to scroll (touch/mouse). Default: touch, or mouse when OnRefresh is set.
	DragToScroll: boolean?,
	--- "List" (default) stacks children; "None" for absolute/virtual content.
	ContentLayout: ("List" | "None")?,
	--- Padding around list content. Default theme SpaceMd. Use 0 for virtual lists.
	ContentPadding: number?,
	--- Gap between list children. Default theme SpaceLg.
	ListPadding: number?,
	[string]: any,
}

export type NumberFieldProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	--- The number. A `Value` is followed and set as the user edits.
	Value: UsedAs<number>?,
	Min: number?,
	Max: number?,
	--- Size of one step: the arrow keys and scrubbing move the value in steps of this (default 1).
	Step: number?,
	--- Digits shown after the decimal point (default: as many as `Step` needs).
	Decimals: number?,
	--- Short text at the start of the field. Dragging it sideways changes the value.
	Label: string?,
	--- Fixed text at the end of the field, such as a unit.
	Suffix: string?,
	--- Value change per pixel of scrubbing (default: the range over 300 px, or a step per 4 px).
	ScrubSpeed: number?,
	Disabled: UsedAs<boolean>?,
	OnChanged: ((number) -> ())?,
	[string]: any,
}

export type SplitPaneProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	--- The panes, in order. Each is sized to fill its slot.
	Panes: { Instance },
	--- `"Horizontal"` puts the panes side by side, `"Vertical"` stacks them (default "Horizontal").
	Orientation: ("Horizontal" | "Vertical")?,
	--- Share of the room each pane takes, in order. They are scaled to add up to 1 (default: equal).
	--- A `Value` is followed and set as the user drags.
	Ratios: UsedAs<{ number }>?,
	--- Smallest size in px a pane can be dragged to (default 80).
	MinSize: number?,
	--- Width of the draggable strip between panes in px (default 8).
	DividerSize: number?,
	--- Called with the new ratios while a divider moves.
	OnResized: ((ratios: { number }) -> ())?,
	[string]: any,
}

export type DockTab = {
	Id: string,
	Title: string,
	--- Shown while the tab is selected. It fills the area under the header.
	Content: Instance,
}

export type DockPanelProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	--- Text of the header. Ignored when there are `Tabs`.
	Title: string?,
	--- Tabs in the header, each with the content it shows.
	Tabs: { DockTab }?,
	--- `Id` of the selected tab. A `Value` is followed and set when the user picks a tab.
	Selected: UsedAs<string>?,
	--- Content of a panel without tabs.
	Children: any?,
	--- Let the user collapse the panel to its header by pressing the arrow.
	Collapsible: boolean?,
	--- Whether the content is shown. A `Value` is followed and set (default true).
	Open: UsedAs<boolean>?,
	--- Elements at the end of the header.
	Actions: { Instance }?,
	--- Shows a close button that calls this.
	OnClose: (() -> ())?,
	OnChanged: ((id: string) -> ())?,
	[string]: any,
}

export type ToolbarItem = {
	Id: string?,
	--- Lucide icon.
	Icon: string?,
	--- Label shown next to the icon.
	Text: string?,
	--- Tooltip text. Defaults to `Text`.
	Tooltip: string?,
	--- Shortcut shown in the tooltip, such as "Ctrl+S".
	Shortcut: string?,
	--- Draw the button as pressed in. A state is followed.
	Toggled: UsedAs<boolean>?,
	--- Flip `Toggled` when the button is pressed. A `Value` is set; otherwise the button keeps its own.
	Toggle: boolean?,
	Disabled: UsedAs<boolean>?,
	OnClick: (() -> ())?,
	--- Draw a thin line between groups of buttons.
	Separator: boolean?,
	--- Take the room that is left, pushing the items after it to the end.
	Spacer: boolean?,
	--- Place your own element in the bar.
	Content: Instance?,
}

export type ToolbarProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Items: { ToolbarItem },
	--- Default "Horizontal".
	Orientation: ("Horizontal" | "Vertical")?,
	[string]: any,
}

export type StatusItem = {
	Id: string?,
	Text: UsedAs<string>?,
	--- Lucide icon.
	Icon: string?,
	--- Colour of the text and icon: "Error", "Warning" or "Success". Left out, it is muted.
	Tone: ("Error" | "Warning" | "Success")?,
	--- Show a small spinner instead of the icon.
	Busy: boolean?,
	--- Show a thin progress bar from 0 to 1. A state is followed.
	Progress: UsedAs<number>?,
	Tooltip: string?,
	--- Makes the item a button.
	OnClick: (() -> ())?,
}

export type StatusBarProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	Start: { StatusItem }?,
	Middle: { StatusItem }?,
	End: { StatusItem }?,
	[string]: any,
}

export type CurveEditorProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	--- The curve. A `Value` is followed and set as the user edits. Default: a line from `Min` to `Max`.
	Value: UsedAs<NumberSequence>?,
	--- Lowest and highest value on the plot (default 0 and 1).
	Min: number?,
	Max: number?,
	--- Height of the plot in px (default 180).
	Height: number?,
	--- Show and edit the envelope of each keypoint.
	ShowEnvelope: boolean?,
	Disabled: UsedAs<boolean>?,
	OnChanged: ((sequence: NumberSequence) -> ())?,
	[string]: any,
}

export type ExplorerProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	Size: UsedAs<UDim2>?,
	Visible: UsedAs<boolean>?,
	ZIndex: UsedAs<number>?,
	--- The instances at the top of the tree.
	Roots: { Instance },
	--- Show only matching instances and the branches that lead to them. Matching is on the
	--- name, case does not matter. A state is followed.
	Filter: UsedAs<string>?,
	--- Extra test for the filter: return true to count `instance` as a match for `text` (lower case).
	Match: ((instance: Instance, text: string) -> boolean)?,
	--- Return false to leave an instance, and what is under it, out.
	Include: ((instance: Instance) -> boolean)?,
	--- The selected instances. A `Value` is followed and set when the user selects.
	Selected: UsedAs<{ Instance }>?,
	--- Open the roots at first (default true).
	ExpandRoots: boolean?,
	--- Lucide icon for an instance (default: by class).
	Icon: ((instance: Instance) -> string)?,
	--- Height of a row in px (default 24).
	RowHeight: number?,
	--- Indent per level in px (default 14).
	Indent: number?,
	--- F2 renames the selected instance (default true).
	AllowRename: boolean?,
	--- Dragging an instance onto another makes it the parent (default false).
	AllowReparent: boolean?,
	OnSelect: ((selected: { Instance }) -> ())?,
	--- Set a `Value` to an instance to open the branches above it and scroll to it.
	Reveal: UsedAs<Instance?>?,
	--- Called with the instance under the pointer, and `nil` when it leaves.
	OnHover: ((instance: Instance?) -> ())?,
	--- Called on a double click or Enter.
	OnActivate: ((instance: Instance) -> ())?,
	--- Called with the new name. Without it the instance is renamed.
	OnRename: ((instance: Instance, name: string) -> ())?,
	--- Called with the instance and its new parent. Without it the parent is set.
	OnReparent: ((instance: Instance, parent: Instance) -> ())?,
	[string]: any,
}

export type RadialItem = {
	Id: string,
	--- Lucide icon.
	Icon: string?,
	--- Label shown in the middle while the choice is highlighted. Defaults to `Id`.
	Text: string?,
	Disabled: UsedAs<boolean>?,
	OnSelect: (() -> ())?,
}

export type RadialMenuProps = {
	Theme: ThemeRef?,
	LayoutOrder: UsedAs<number>?,
	ZIndex: UsedAs<number>?,
	Layer: Instance?,
	--- The choices, placed round the ring clockwise from the top.
	Items: { RadialItem },
	--- Whether the ring is shown. A `Value` is followed and set when the ring closes.
	Open: UsedAs<boolean>?,
	--- A key that opens the ring while it is held, and picks the highlighted choice on release.
	Hotkey: Enum.KeyCode?,
	--- Where the ring opens, in the space of the layer (default: at the pointer).
	Origin: Vector2?,
	--- Distance of the choices from the centre in px (default 96).
	Radius: number?,
	--- Diameter of a choice in px (default 52).
	ItemSize: number?,
	--- Text in the middle while no choice is highlighted.
	Title: string?,
	OnSelect: ((id: string) -> ())?,
	OnClose: (() -> ())?,
	[string]: any,
}

return nil
