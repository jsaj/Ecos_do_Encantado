class_name BattleTheme
extends RefCounted

## Fábrica de estilos (skeuomorphic: madeira entalhada + pergaminho escuro)
## Usada pela tela de batalha para manter a identidade visual consistente.

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

## Painel principal: madeira escura com borda metálica envelhecida.
static func panel(bg: Color = PARCHMENT, border: Color = BORDER_METAL, width: int = 3) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(width)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(10)
	sb.shadow_color = Color(0, 0, 0, 0.55)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(2, 4)
	return sb

## Cabeçalho de coluna do Battle Action Panel.
static func header() -> StyleBoxFlat:
	var sb := panel(WOOD_DARK, BORDER_METAL_DIM, 2)
	sb.content_margin_top = 2
	sb.content_margin_bottom = 4
	return sb

## Slot de item / habilidade.
static func slot_box(bg: Color = WOOD_MID, border: Color = BORDER_METAL_DIM, width: int = 2) -> StyleBoxFlat:
	var sb := panel(bg, border, width)
	sb.set_content_margin_all(6)
	return sb

## Botão esculpido com estado normal / hover / pressed.
static func button(bg: Color = WOOD_MID, accent: Color = BORDER_METAL) -> Array[StyleBoxFlat]:
	var normal := panel(bg, accent, 3)
	var hover := panel(bg.lightened(0.12), accent.lightened(0.15), 3)
	var pressed := panel(bg.darkened(0.2), GOLD, 3)
	var disabled := panel(bg.darkened(0.45), BORDER_METAL_DIM, 3)
	return [normal, hover, pressed, disabled] as Array[StyleBoxFlat]

static func apply_button(button: BaseButton, bg: Color = WOOD_MID, accent: Color = BORDER_METAL) -> void:
	var styles := button(bg, accent)
	button.add_theme_stylebox_override("normal", styles[0])
	button.add_theme_stylebox_override("hover", styles[1])
	button.add_theme_stylebox_override("pressed", styles[2])
	button.add_theme_stylebox_override("disabled", styles[3])
	button.add_theme_stylebox_override("focus", styles[0])
	button.add_theme_color_override("font_color", TEXT_MAIN)
	button.add_theme_color_override("font_hover_color", GOLD)
	button.add_theme_color_override("font_pressed_color", GOLD)
	button.add_theme_color_override("font_disabled_color", TEXT_DIM.darkened(0.3))
	button.add_theme_font_size_override("font_size", 20)

## Barra de status (vida / mana / estamina) com fundo chanfrado.
static func bar_background() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("171208")
	sb.border_color = BORDER_METAL_DIM
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(3)
	return sb

static func bar_fill(color: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.set_corner_radius_all(3)
	return sb

## Números e ícones do log de combate (fonte condensada, verde terminal).
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
