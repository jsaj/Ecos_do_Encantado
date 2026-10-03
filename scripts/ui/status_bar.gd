class_name StatusBar
extends VBoxContainer

## Conjunto de barras de status (Vida / Mana / Estamina) com ícone e
## leitura "atual/máximo", no formato do HUD de iniciativa.

const BAR_HEIGHT := 16

@export var title: String = ""
@export var hp_max: int = 150:
	set(v):
		hp_max = v
		_update()
@export var hp_current: int = 150:
	set(v):
		hp_current = v
		_update()
@export var mp_max: int = 77:
	set(v):
		mp_max = v
		_update()
@export var mp_current: int = 78:
	set(v):
		mp_current = v
		_update()
@export var stamina_max: int = 0:
	set(v):
		stamina_max = v
		_update()
@export var stamina_current: int = 0:
	set(v):
		stamina_current = v
		_update()
@export var show_stamina: bool = true

var _hp_fill: StyleBoxFlat
var _mp_fill: StyleBoxFlat
var _stam_fill: StyleBoxFlat
var _hp_label: Label
var _mp_label: Label
var _stam_label: Label
var _hp_bar: ProgressBar
var _mp_bar: ProgressBar
var _stam_bar: ProgressBar
var _stam_row: HBoxContainer
var _last_label: Label

func _init() -> void:
	add_theme_constant_override("separation", 4)

func _ready() -> void:
	if not title.is_empty():
		var name_label := Label.new()
		name_label.text = title
		name_label.add_theme_font_size_override("font_size", 18)
		name_label.add_theme_color_override("font_color", BattleTheme.TEXT_MAIN)
		add_child(name_label)

	_hp_fill = BattleTheme.bar_fill(BattleTheme.HP_RED)
	_hp_bar = _add_row("♥", _hp_fill, BattleTheme.HP_RED).get_child(1)
	_hp_label = _last_label
	_mp_fill = BattleTheme.bar_fill(BattleTheme.MP_BLUE)
	_mp_bar = _add_row("✦", _mp_fill, BattleTheme.MP_BLUE).get_child(1)
	_mp_label = _last_label
	_stam_fill = BattleTheme.bar_fill(BattleTheme.STAMINA_PURPLE)
	_stam_row = _add_row("⚡", _stam_fill, BattleTheme.STAMINA_PURPLE)
	_stam_bar = _stam_row.get_child(1)
	_stam_label = _last_label
	_update()

func _add_row(icon: String, fill: StyleBoxFlat, color: Color) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	add_child(row)

	var glyph := Label.new()
	glyph.text = icon
	glyph.custom_minimum_size = Vector2(18, BAR_HEIGHT)
	glyph.add_theme_font_size_override("font_size", 14)
	glyph.add_theme_color_override("font_color", color)
	glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(glyph)

	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(90, BAR_HEIGHT)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.max_value = 1.0
	bar.step = 0.001
	bar.add_theme_stylebox_override("background", BattleTheme.bar_background())
	bar.add_theme_stylebox_override("fill", fill)
	row.add_child(bar)

	var label := Label.new()
	label.custom_minimum_size = Vector2(74, BAR_HEIGHT)
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", BattleTheme.TEXT_MAIN)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(label)

	if icon == "⚡":
		_stam_row = row
	_last_label = label
	return row

func _update() -> void:
	if _hp_bar == null:
		return
	_hp_label.text = "%d/%d" % [hp_current, hp_max]
	_set_bar(_hp_bar, hp_current, hp_max)
	_mp_label.text = "%d/%d" % [mp_current, mp_max]
	_set_bar(_mp_bar, mp_current, mp_max)
	_stam_label.text = "%d/%d" % [stamina_current, stamina_max]
	_set_bar(_stam_bar, stamina_current, stamina_max)
	if _stam_row != null:
		_stam_row.visible = show_stamina and stamina_max > 0

func _set_bar(bar: ProgressBar, current: int, maximum: int) -> void:
	if bar == null:
		return
	bar.max_value = maxi(maximum, 1)
	bar.value = clampi(current, 0, maxi(maximum, 1))

func apply_combatant(c: BattleCombatant) -> void:
	hp_max = c.max_hp
	hp_current = c.hp
	mp_max = c.max_mp
	mp_current = c.mp
	stamina_max = c.max_stamina
	stamina_current = c.stamina
	show_stamina = c.has_stamina_bar()
