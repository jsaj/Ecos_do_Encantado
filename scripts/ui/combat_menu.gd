class_name CombatMenu
extends HBoxContainer

## Menu de Combate: [Fugir] [Passar Turno] [Pausa].
## Cada item empilha o ícone acima do rótulo, como na imagem de referência.
## Os ícones aceitam arte final via texture_path; sem arquivo, fica o marcador.

signal flee_requested
signal pass_turn_requested
signal pause_requested

const ICON_SIZE := Vector2(34, 34)
const BUTTON_HEIGHT := 40

var _buttons: Array[Button] = []

func _init() -> void:
	add_theme_constant_override("separation", 12)
	alignment = BoxContainer.ALIGNMENT_CENTER

func _ready() -> void:
	_add_item("Fugir", Color("c98a3c"), "res://assets/icons/boot.png", "flee_requested")
	_add_item("Passar Turno", Color("8fb06a"), "res://assets/icons/arrow_right.png", "pass_turn_requested")
	_add_item("Pausa", Color("9a7fb8"), "res://assets/icons/gear.png", "pause_requested")

func _add_item(label: String, accent: Color, icon_path: String, signal_name: String) -> void:
	var item := VBoxContainer.new()
	item.custom_minimum_size = Vector2(0, ICON_SIZE.y + BUTTON_HEIGHT + 4)
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	item.add_theme_constant_override("separation", 4)
	add_child(item)

	var frame := PanelContainer.new()
	frame.custom_minimum_size = Vector2(ICON_SIZE.x, ICON_SIZE.y)
	frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	frame.add_theme_stylebox_override("panel", BattleTheme.slot_box(BattleTheme.PARCHMENT_SOFT, accent, 2))
	item.add_child(frame)

	var icon := TextureRect.new()
	icon.custom_minimum_size = ICON_SIZE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
		var res := ResourceLoader.load(icon_path)
		if res is Texture2D:
			icon.texture = res
	frame.add_child(icon)

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(0, BUTTON_HEIGHT)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.text = label
	btn.tooltip_text = label
	BattleTheme.apply_button(btn, BattleTheme.WOOD_MID, accent)
	btn.add_theme_font_size_override("font_size", 18)
	btn.pressed.connect(func() -> void: emit_signal(signal_name))
	item.add_child(btn)
	_buttons.append(btn)

func set_actions_enabled(value: bool) -> void:
	for b in _buttons:
		b.disabled = not value
