class_name CombatLog
extends ScrollContainer

## Combat Log: caixa de texto com fundo escuro semi-transparente,
## no estilo terminal/RPG da imagem de referência.

signal entry_activated(entry: Dictionary)

const MAX_ENTRIES := 60

@export var title: String = "Combat Log"

var _list: VBoxContainer
var _title_label: Label

func _init() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

func _ready() -> void:
	# Clean panel without borders
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.04, 0.03, 0.88)
	add_theme_stylebox_override("panel", panel_style)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 4)
	add_child(box)

	_title_label = Label.new()
	_title_label.text = title
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 20)
	_title_label.add_theme_color_override("font_color", BattleTheme.GOLD)
	box.add_child(_title_label)

	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 4)
	box.add_child(_list)

func push_entry(text: String, kind: String = "system") -> void:
	_push({"text": text, "kind": kind})

func push_entries(entries: Array[Dictionary]) -> void:
	for e in entries:
		_push(e)

func _push(entry: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var marker := Label.new()
	marker.text = "[X]"
	marker.add_theme_font_size_override("font_size", 15)
	marker.add_theme_color_override("font_color", BattleTheme.DANGER)
	row.add_child(marker)

	var label := Label.new()
	label.text = str(entry.get("text", ""))
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", BattleTheme.log_color(str(entry.get("kind", "system"))))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size = Vector2(0, 20)
	row.add_child(label)

	_list.add_child(row)

	# Mantém o histórico limitado
	while _list.get_child_count() > MAX_ENTRIES:
		_list.get_child(0).free()

	# Rola para o final
	await get_tree().process_frame
	if is_inside_tree():
		scroll_vertical = int(get_v_scroll_bar().max_value)

func clear_log() -> void:
	if _list == null:
		return
	for c in _list.get_children():
		c.queue_free()
