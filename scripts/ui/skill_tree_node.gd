class_name SkillTreeNode
extends PanelContainer

## Nó individual da árvore de habilidades: moldura quadrada de madeira limpa,
## ícone (placeholder quando a arte final não existe), nome e os números
## de dano / custo de mana / crítico.

signal skill_pressed(index: int)

const ICON_SIZE := Vector2(36, 36)

var index: int = 0
var _skill: Dictionary = {}
var _icon: TextureRect
var _name_label: Label
var _damage_label: Label
var _mana_label: Label
var _critical_label: Label
var _click: Button
var _affordable: bool = true

func _init() -> void:
	custom_minimum_size = Vector2(240, 62)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS

func _ready() -> void:
	# Clean panel without borders
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = BattleTheme.WOOD_MID
	panel_style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", panel_style)

	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	box.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(box)

	var icon_frame := PanelContainer.new()
	icon_frame.custom_minimum_size = ICON_SIZE
	icon_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	# Clean icon frame without borders
	var icon_frame_style := StyleBoxFlat.new()
	icon_frame_style.bg_color = BattleTheme.PARCHMENT_SOFT
	icon_frame_style.set_corner_radius_all(4)
	icon_frame.add_theme_stylebox_override("panel", icon_frame_style)
	icon_frame.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_child(icon_frame)

	_icon = TextureRect.new()
	_icon.custom_minimum_size = ICON_SIZE
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_frame.add_child(_icon)

	var text_box := VBoxContainer.new()
	text_box.add_theme_constant_override("separation", 2)
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	text_box.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_child(text_box)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 18)
	_name_label.add_theme_color_override("font_color", BattleTheme.TEXT_MAIN)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_box.add_child(_name_label)

	var stats := HBoxContainer.new()
	stats.add_theme_constant_override("separation", 12)
	stats.mouse_filter = Control.MOUSE_FILTER_PASS
	text_box.add_child(stats)

	_damage_label = _make_stat(stats, BattleTheme.HP_RED)
	_mana_label = _make_stat(stats, Color("6f9fd8"))
	_critical_label = _make_stat(stats, BattleTheme.GOLD)

	# Botão transparente por cima para capturar o clique sem cobrir o visual
	_click = Button.new()
	_click.flat = true
	_click.focus_mode = Control.FOCUS_NONE
	_click.set_anchors_preset(Control.PRESET_FULL_RECT)
	_click.pressed.connect(func() -> void: skill_pressed.emit(index))
	add_child(_click)

func _make_stat(parent: Node, color: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", 14)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l

func setup(skill: Dictionary, node_index: int) -> void:
	_skill = skill
	index = node_index
	if not is_node_ready():
		await ready
	_name_label.text = str(skill.get("name", ""))
	var path := str(skill.get("icon_path", ""))
	if not path.is_empty() and ResourceLoader.exists(path):
		var tex := ResourceLoader.load(path)
		if tex is Texture2D:
			_icon.texture = tex
	set_cost_labels(
		int(skill.get("mana_cost", 0)),
		int(skill.get("damage", 0)),
		int(skill.get("critical", 0))
	)

func set_cost_labels(mana: int, damage: int, critical: int) -> void:
	if not is_node_ready():
		return
	_damage_label.text = "%d atk" % damage
	_mana_label.text = "%d mana" % mana
	_critical_label.text = "%d crit" % critical

func set_affordable(value: bool) -> void:
	if _affordable == value:
		return
	_affordable = value
	modulate = Color(1, 1, 1, 1) if value else Color(0.6, 0.55, 0.5, 0.85)

func set_selected(value: bool) -> void:
	# Clean panel without borders
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = BattleTheme.WOOD_LIGHT if value else BattleTheme.WOOD_MID
	panel_style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", panel_style)
