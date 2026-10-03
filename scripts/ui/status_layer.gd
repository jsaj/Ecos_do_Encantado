class_name StatusLayer
extends VBoxContainer

## Status Layer: Exibe HP, MP, Estamina e atributos textuais
##
## Arquitetura Dumb Terminal:
## - Não calcula nada
## - Apenas renderiza dados injetados pelo controller
## - Não possui botões e portanto não interage com o jogador
##
## Os nós visuais podem ser autorados na cena e exportados (§17).
## Se não forem atribuídos, a camada constrói o fallback com BattleTheme,
## preservando o uso programático do nó.

const BAR_HEIGHT := 16

@export_group("Header")
@export var title_label: Label

@export_group("HP")
@export var hp_bar: TextureProgressBar
@export var hp_value_label: Label

@export_group("MP")
@export var mp_bar: TextureProgressBar
@export var mp_value_label: Label

@export_group("Stamina")
@export var stamina_row: HBoxContainer
@export var stamina_bar: TextureProgressBar
@export var stamina_value_label: Label

@export_group("Stats")
@export var stats_panel: RichTextLabel

# Referências diretas dos nós da cena (para atribuição via inspector)
@export var _hp_bar_node: TextureProgressBar
@export var _mp_bar_node: TextureProgressBar
@export var _stats_panel_node: RichTextLabel

@export var title: String = ""
@export var show_stamina: bool = true

# Auxiliares do fallback construido por código.
var _last_label: Label


func _init() -> void:
	add_theme_constant_override("separation", 4)


func _ready() -> void:
	_resolve_references()
	
	if hp_bar != null and mp_bar != null:
		_apply_authored_defaults()
		return

	_build_ui()


## Resolve referências diretas dos nós da cena.
func _resolve_references() -> void:
	if hp_bar == null:
		hp_bar = _hp_bar_node if _hp_bar_node != null else find_child("HPBar", true, false) as TextureProgressBar
	if mp_bar == null:
		mp_bar = _mp_bar_node if _mp_bar_node != null else find_child("MPBar", true, false) as TextureProgressBar
	if stats_panel == null:
		stats_panel = _stats_panel_node if _stats_panel_node != null else find_child("StatsPanel", true, false) as RichTextLabel


## Aplica apenas formatação defensiva nos nós autorados pela cena.
func _apply_authored_defaults() -> void:
	if title_label != null and title_label.text.is_empty():
		title_label.text = title

	for bar: TextureProgressBar in [hp_bar, mp_bar, stamina_bar]:
		if bar == null:
			continue
		bar.step = 0.001

	if stamina_row != null:
		stamina_row.visible = false

	if stats_panel != null:
		stats_panel.bbcode_enabled = false


## Constrói o fallback quando a cena não fornece os nós.
func _build_ui() -> void:
	if not title.is_empty():
		title_label = Label.new()
		title_label.text = title
		title_label.add_theme_font_size_override("font_size", 18)
		title_label.add_theme_color_override("font_color", Color(0.91, 0.863, 0.753, 1))
		add_child(title_label)

	hp_bar = _add_row("♥", Color(0.753, 0.224, 0.169, 1), Color(0.753, 0.224, 0.169, 1)).get_child(1) as TextureProgressBar
	hp_value_label = _last_label

	mp_bar = _add_row("✦", Color(0.184, 0.498, 0.749, 1), Color(0.184, 0.498, 0.749, 1)).get_child(1) as TextureProgressBar
	mp_value_label = _last_label

	stamina_row = _add_row("⚡", Color(0.557, 0.267, 0.678, 1), Color(0.557, 0.267, 0.678, 1))
	stamina_bar = stamina_row.get_child(1) as TextureProgressBar
	stamina_value_label = _last_label

	stamina_row.visible = show_stamina


func _add_row(icon: String, fill_color: Color, label_color: Color) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	add_child(row)

	var glyph := Label.new()
	glyph.text = icon
	glyph.custom_minimum_size = Vector2(18, BAR_HEIGHT)
	glyph.add_theme_font_size_override("font_size", 14)
	glyph.add_theme_color_override("font_color", label_color)
	glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(glyph)

	var bar := TextureProgressBar.new()
	bar.custom_minimum_size = Vector2(90, BAR_HEIGHT)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.max_value = 1.0
	bar.step = 0.001
	
	# Simple background without borders
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.09, 0.07, 0.03, 1)
	bar.add_theme_stylebox_override("background", bg_style)
	
	# Fill color
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	fill_style.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", fill_style)
	row.add_child(bar)

	var label := Label.new()
	label.custom_minimum_size = Vector2(74, BAR_HEIGHT)
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.91, 0.863, 0.753, 1))
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(label)

	_last_label = label
	return row


## Injeta dados de status (skill §10).
## Espera: hp, max_hp, mp, max_mp, stamina, max_stamina, stats_text
func update_status(data: Dictionary) -> void:
	var hp: int = int(data.get("hp", 0))
	var max_hp: int = int(data.get("max_hp", 1))
	var mp: int = int(data.get("mp", 0))
	var max_mp: int = int(data.get("max_mp", 1))
	var stamina: int = int(data.get("stamina", 0))
	var max_stamina: int = int(data.get("max_stamina", 0))

	_set_bar_display(hp_bar, hp_value_label, hp, max_hp)
	_set_bar_display(mp_bar, mp_value_label, mp, max_mp)
	_set_bar_display(stamina_bar, stamina_value_label, stamina, max_stamina)

	if stamina_row != null:
		stamina_row.visible = show_stamina and max_stamina > 0

	if stats_panel != null:
		var stats_text: String = str(data.get("stats_text", ""))
		stats_panel.text = stats_text
		stats_panel.visible = not stats_text.is_empty()


func _set_bar_display(bar: TextureProgressBar, label: Label, current: int, maximum: int) -> void:
	if bar == null:
		return

	var safe_max: int = maxi(maximum, 1)
	bar.max_value = safe_max
	bar.value = clampi(current, 0, safe_max)

	if label != null:
		label.text = "%d/%d" % [current, maximum]


## Injeta dados de um BattleCombatant (compatibilidade legada)
func apply_combatant(combatant: BattleCombatant) -> void:
	update_status({
		"hp": combatant.hp,
		"max_hp": combatant.max_hp,
		"mp": combatant.mp,
		"max_mp": combatant.max_mp,
		"stamina": combatant.stamina,
		"max_stamina": combatant.max_stamina
	})
