class_name BattleTheme
extends RefCounted

## Paleta de cores para a UI de batalha (sem bordas/linhas).
## Usada para manter a identidade visual consistente.

# Paleta ------------------------------------------------------------------
const WOOD_DARK := Color("2a1c10")
const WOOD_MID := Color("4a3018")
const WOOD_LIGHT := Color("6b4a24")
const PARCHMENT := Color("2b2318")
const PARCHMENT_SOFT := Color("3a2f20")
const BORDER_METAL := Color("8a6a35")
const BORDER_METAL_DIM := Color("5a4626")
const GOLD := Color("e0b64a")
const TEXT_MAIN := Color("e8dcc0")
const TEXT_DIM := Color("a8977a")
const HP_RED := Color("c0392b")
const MP_BLUE := Color("2f7fbf")
const STAMINA_PURPLE := Color("8e44ad")
const GREEN_SORCERY := Color("4f9d4a")
const GREEN_PANEL := Color("33502c")
const FIRE := Color("e07b26")
const DANGER := Color("a03024")

## Barra de status - fundo simples sem borda.
static func bar_background() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("171208")
	sb.set_corner_radius_all(3)
	return sb

static func bar_fill(color: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(3)
	return sb

## Botão simples sem bordas.
static func apply_button(button: BaseButton, bg: Color = WOOD_MID, accent: Color = GOLD) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = bg
	normal.set_corner_radius_all(4)
	
	var hover := StyleBoxFlat.new()
	hover.bg_color = bg.lightened(0.12)
	hover.set_corner_radius_all(4)
	
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = bg.darkened(0.2)
	pressed.set_corner_radius_all(4)
	
	var disabled := StyleBoxFlat.new()
	disabled.bg_color = bg.darkened(0.45)
	disabled.set_corner_radius_all(4)
	
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_stylebox_override("focus", normal)
	button.add_theme_color_override("font_color", TEXT_MAIN)
	button.add_theme_color_override("font_hover_color", accent)
	button.add_theme_color_override("font_pressed_color", accent)
	button.add_theme_color_override("font_disabled_color", TEXT_DIM.darkened(0.3))
	button.add_theme_font_size_override("font_size", 20)

## Painel simples sem bordas.
static func clean_panel(bg: Color = PARCHMENT_SOFT) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(4)
	return sb

## Números e ícones do log de combate.
static func log_color(kind: String) -> Color:
	match kind:
		"damage":
			return Color("e2604a")
		"heal":
			return Color("6fbf5f")
		"buff":
			return Color("7fc7e8")
		"debuff":
			return Color("c58ad6")
		"turn":
			return GOLD
		"system":
			return TEXT_DIM
		_:
			return TEXT_MAIN
