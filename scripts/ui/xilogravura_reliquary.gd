extends Control
class_name XilogravuraReliquary

## Relicário visual de xilogravuras. Os caminhos iniciais vêm da cena e podem
## ser substituídos pela função inject_data() sem acoplar regras de jogo.
signal action_requested(action_id: String, payload: Dictionary)

@export var initial_data: Dictionary = {
	"book_path": "res://assets/ui/book_open.png",
	"wood_path": "res://assets/ui/madeira_object_clear.png",
	"used_sheet_path": "res://assets/ui/folha_xilografia_used.png",
	"closed_sheet_path": "res://assets/ui/folha_xilografia_closed.png",
	"menu_button_path": "res://assets/ui/botao_menu.png",
	"confirm_button_path": "res://assets/ui/botao_confirma_menu.png",
	"link_container_path": "res://assets/ui/container_vinculo.png",
	"title_frame_path": "res://assets/ui/moldura_menu_name.png",
	"arrow_path": "res://assets/ui/seta_menu.png",
	"character_path": "res://assets/characters/luana.png",
	"print_path": "res://assets/ui/xilogravura_saci.png",
	"title": "RELÍQUÁRIO DE XILOGRAVURAS",
	"character_name": "Luana, a Observadora das Estrelas",
	"talents_title": "TALENTOS BASE",
	"links_title": "XILOGRAVURAS VINCULADAS",
	"description": "Vincule suas xilogravuras aos talentos base para sobrepô-las com a essência do mito. O uso gera nanquim; a vinculação o amplifica.",
	"inventory_prints": ["res://assets/ui/xilogravura_saci.png", "res://assets/ui/xilogravura_saci.png", "res://assets/ui/xilogravura_saci.png", "res://assets/ui/xilogravura_saci.png"],
	"linked_prints": ["res://assets/ui/xilogravura_saci.png", "res://assets/ui/xilogravura_saci.png", "res://assets/ui/xilogravura_saci.png", ""]
}

const INK := Color("211a15")
const TEXT := Color("241c15")
const PAPER_TEXT := Color("3b2a1d")
const TALENT_NAMES: Array[String] = ["GOLPE DE CAJADO", "ESQUIVA FLUIDA", "POSTURA DE GUARDA", "ARRANQUE RÁPIDO"]
const LINK_NAMES: Array[String] = ["SACI-PERERÊ", "CUCA", "BOITATÁ", "[VAZIO]", "", "", "", ""]

var _book: TextureRect
var _wood: TextureRect
var _title_frame: TextureRect
var _title_label: Label
var _character: TextureRect
var _character_name: Label
var _description: Label
var _left_arrow: TextureRect
var _right_arrow: TextureRect
var _used_sheet: TextureRect
var _closed_sheets: Array[TextureRect] = []
var _linked_cards: Array[Control] = []
var _talent_fields: Array[LineEdit] = []
var _link_fields: Array[LineEdit] = []
var _buttons: Dictionary = {}
var _data: Dictionary = {}
var _selected_inventory_index := -1
var _selected_slot_index := -1


func _ready() -> void:
	set_process_unhandled_input(true)
	_build_interface()
	inject_data(initial_data)
	get_viewport().size_changed.connect(_layout_for_viewport)
	_layout_for_viewport()


func inject_data(data: Dictionary) -> void:
	_data = data.duplicate(true)
	_set_texture(_book, str(data.get("book_path", "")))
	_set_texture(_wood, str(data.get("wood_path", "")))
	_set_texture(_used_sheet, str(data.get("used_sheet_path", "")))
	_set_texture(_title_frame, str(data.get("title_frame_path", "")))
	_set_texture(_left_arrow, str(data.get("arrow_path", "")))
	_set_texture(_right_arrow, str(data.get("arrow_path", "")))
	_set_texture(_character, str(data.get("character_path", "")))
	_title_label.text = str(data.get("title", ""))
	_character_name.text = str(data.get("character_name", ""))
	_description.text = str(data.get("description", ""))
	for sheet: TextureRect in _closed_sheets:
		_set_texture(sheet, str(data.get("closed_sheet_path", "")))
	for card: Control in _linked_cards:
		_set_texture(card.get_node("Frame"), str(data.get("link_container_path", "")))
		_set_texture(card.get_node("Print"), str(data.get("print_path", "")))
	for i in _talent_fields.size():
		_talent_fields[i].placeholder_text = TALENT_NAMES[i]
	for i in _link_fields.size():
		_link_fields[i].placeholder_text = LINK_NAMES[i]
	_buttons["Voltar"].text = str(data.get("back_label", "VOLTAR"))
	_buttons["LimparSelecao"].text = str(data.get("clear_label", "LIMPAR\nSELEÇÃO"))
	_buttons["Confirmar"].text = str(data.get("confirm_label", "CONFIRMAR\nPREPARAÇÃO"))
	var inventory_prints: Array = data.get("inventory_prints", [])
	for i in _closed_sheets.size():
		var path := str(inventory_prints[i]) if i < inventory_prints.size() else ""
		_set_texture(get_node("InventoryPrint%d" % i), path)
	var linked_prints: Array = data.get("linked_prints", [])
	for i in _linked_cards.size():
		var path := str(linked_prints[i]) if i < linked_prints.size() else ""
		_set_texture(_linked_cards[i].get_node("Print"), path)
	get_node("Content/TalentsHeading").text = str(data.get("talents_title", "TALENTOS BASE"))
	get_node("Content/LinksHeading").text = str(data.get("links_title", "XILOGRAVURAS VINCULADAS"))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		if not SceneManager.is_loading:
			_return_to_exploration()
			get_viewport().set_input_as_handled()


func _build_interface() -> void:
	_book = _texture_rect("Book", self, 0.025, 0.025, 0.95, 0.95, TextureRect.STRETCH_SCALE)
	_wood = _texture_rect("WoodPanel", self, 0.085, 0.80, 0.83, 0.965, TextureRect.STRETCH_SCALE)
	_title_frame = _texture_rect("TitleFrame", self, 0.31, 0.012, 0.69, 0.105, TextureRect.STRETCH_SCALE)
	_title_label = _label("Title", self, "", 28, Color("f3e3c5"), HORIZONTAL_ALIGNMENT_CENTER)
	_title_label.anchor_left = 0.32
	_title_label.anchor_top = 0.02
	_title_label.anchor_right = 0.68
	_title_label.anchor_bottom = 0.09
	_title_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	_title_label.add_theme_constant_override("shadow_offset_x", 2)
	_title_label.add_theme_constant_override("shadow_offset_y", 2)

	_character = _texture_rect("Character", self, 0.105, 0.19, 0.31, 0.69, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_character_name = _label("CharacterName", self, "", 22, TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	_character_name.anchor_left = 0.10
	_character_name.anchor_top = 0.68
	_character_name.anchor_right = 0.33
	_character_name.anchor_bottom = 0.73
	_description = _label("Description", self, "", 15, TEXT)
	_description.anchor_left = 0.285
	_description.anchor_top = 0.70
	_description.anchor_right = 0.49
	_description.anchor_bottom = 0.79
	_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	_left_arrow = _texture_rect("LeftArrow", self, 0.065, 0.45, 0.10, 0.55, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_left_arrow.flip_h = true
	_right_arrow = _texture_rect("RightArrow", self, 0.89, 0.45, 0.925, 0.55, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_add_button_hitbox("LeftArrowButton", self, 0.055, 0.43, 0.105, 0.57, "previous_page")
	_add_button_hitbox("RightArrowButton", self, 0.885, 0.43, 0.935, 0.57, "next_page")

	# Base talent labels and editable text fields on the left page.
	var content := Control.new()
	content.name = "Content"
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content)
	_add_heading(content, "TalentsHeading", "", 0.49, 0.16, 0.68, 0.20)
	_add_heading(content, "LinksHeading", "", 0.70, 0.16, 0.89, 0.20)
	for i in 4:
		var row := i / 2
		var col := i % 2
		var x := 0.49 + float(col) * 0.205
		var y := 0.235 + float(row) * 0.125
		var idx := _label("TalentIndex%d" % i, content, "T%d" % (i + 1), 14, TEXT, HORIZONTAL_ALIGNMENT_CENTER)
		idx.anchor_left = x - 0.035
		idx.anchor_top = y + 0.02
		idx.anchor_right = x - 0.006
		idx.anchor_bottom = y + 0.08
		var field := _line_edit("TalentField%d" % i, content, x, y, x + 0.18, y + 0.09)
		_talent_fields.append(field)
		field.placeholder_text = TALENT_NAMES[i]
		field.add_theme_font_size_override("font_size", 14)
		field.text_submitted.connect(_on_field_submitted.bind("talent", i))
		var link_x := 0.70 + float(col) * 0.205
		var link_y := 0.235 + float(row) * 0.125
		var card := _build_link_card(content, i, link_x, link_y)
		_linked_cards.append(card)
		var link_field := _line_edit("LinkField%d" % i, content, link_x + 0.075, link_y + 0.01, link_x + 0.175, link_y + 0.085)
		link_field.add_theme_font_size_override("font_size", 13)
		link_field.text_submitted.connect(_on_field_submitted.bind("link", i))
		_link_fields.append(link_field)
		_add_button_hitbox("LinkSelect%d" % i, content, link_x, link_y, link_x + 0.06, link_y + 0.09, "select_slot", {"index": i})

	# Four parallel inventory leaves along the lower wood panel.
	for i in 4:
		var x := 0.105 + float(i) * 0.105
		var leaf := _texture_rect("InventorySheet%d" % i, self, x, 0.805, x + 0.095, 0.96, TextureRect.STRETCH_SCALE)
		_closed_sheets.append(leaf)
		_texture_rect("InventoryPrint%d" % i, self, x + 0.018, 0.83, x + 0.077, 0.90, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		_add_button_hitbox("InventoryButton%d" % i, self, x, 0.805, x + 0.095, 0.96, "select_inventory", {"index": i})

	# Active print sheet with a nested square print container.
	_used_sheet = _texture_rect("UsedSheet", self, 0.082, 0.805, 0.17, 0.96, TextureRect.STRETCH_SCALE)
	var print_container := Control.new()
	print_container.name = "UsedSheetPrintContainer"
	print_container.anchor_left = 0.101
	print_container.anchor_top = 0.825
	print_container.anchor_right = 0.151
	print_container.anchor_bottom = 0.895
	add_child(print_container)
	var used_print := _texture_rect("Print", print_container, 0, 0, 1, 1, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_set_texture(used_print, str(_data.get("print_path", "")))
	_add_button_hitbox("UsedSheetButton", self, 0.08, 0.80, 0.17, 0.965, "select_inventory", {"index": 0})

	_add_image_button("BackButton", 0.555, 0.82, 0.655, 0.91, "menu_button_path", "Voltar", "back")
	_add_image_button("ClearSelectionButton", 0.555, 0.915, 0.655, 0.975, "menu_button_path", "LimparSelecao", "clear_selection")
	_add_image_button("ConfirmButton", 0.665, 0.815, 0.755, 0.975, "confirm_button_path", "Confirmar", "confirm")


func _build_link_card(parent: Control, index: int, x: float, y: float) -> Control:
	var card := Control.new()
	card.name = "LinkCard%d" % index
	card.anchor_left = x
	card.anchor_top = y
	card.anchor_right = x + 0.18
	card.anchor_bottom = y + 0.09
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(card)
	var frame := _texture_rect("Frame", card, 0, 0, 1, 1, TextureRect.STRETCH_SCALE)
	_set_texture(frame, str(_data.get("link_container_path", "")))
	var print_image := _texture_rect("Print", card, 0.035, 0.12, 0.37, 0.88, TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	_set_texture(print_image, str(_data.get("print_path", "")))
	var number := _label("SlotNumber", card, "X%d" % (index + 1), 13, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	number.anchor_left = 0.0
	number.anchor_top = -0.12
	number.anchor_right = 0.25
	number.anchor_bottom = 0.18
	number.add_theme_color_override("font_shadow_color", Color.BLACK)
	return card


func _add_image_button(node_name: String, left: float, top: float, right: float, bottom: float, texture_key: String, button_key: String, action_id: String) -> void:
	var frame := _texture_rect(node_name + "Frame", self, left, top, right, bottom, TextureRect.STRETCH_SCALE)
	frame.set_meta("texture_key", texture_key)
	var button := Button.new()
	button.name = node_name
	button.anchor_left = left
	button.anchor_top = top
	button.anchor_right = right
	button.anchor_bottom = bottom
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(_on_action_pressed.bind(action_id))
	add_child(button)
	var label: Label = _buttons.get(button_key, null)
	if label == null:
		label = _label(button_key, self, "", 15, Color("f0dfbd"), HORIZONTAL_ALIGNMENT_CENTER)
		label.name = button_key + "Label"
		label.anchor_left = left + 0.005
		label.anchor_top = top + 0.01
		label.anchor_right = right - 0.005
		label.anchor_bottom = bottom - 0.01
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_buttons[button_key] = label
		_buttons[button_key + "Frame"] = frame
	_buttons[button_key + "Action"] = action_id
	_set_texture(frame, str(_data.get(texture_key, "")))
	label.text = str(_data.get("%s_label" % action_id, button_key))


func _add_button_hitbox(node_name: String, parent: Control, left: float, top: float, right: float, bottom: float, action_id: String, payload: Dictionary = {}) -> void:
	var button := Button.new()
	button.name = node_name
	button.anchor_left = left
	button.anchor_top = top
	button.anchor_right = right
	button.anchor_bottom = bottom
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var normal := StyleBoxEmpty.new()
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", normal)
	button.add_theme_stylebox_override("pressed", normal)
	button.add_theme_stylebox_override("focus", normal)
	button.pressed.connect(_on_action_pressed.bind(action_id, payload))
	parent.add_child(button)


func _on_action_pressed(action_id: String, payload: Dictionary = {}) -> void:
	match action_id:
		"back":
			_return_to_exploration()
		"clear_selection":
			_clear_selection()
		"select_inventory":
			_selected_inventory_index = int(payload.get("index", -1))
			action_requested.emit(action_id, {"index": _selected_inventory_index})
		"select_slot":
			_selected_slot_index = int(payload.get("index", -1))
			action_requested.emit(action_id, {"index": _selected_slot_index})
		"select_talent":
			_selected_slot_index = int(payload.get("index", -1))
			action_requested.emit(action_id, {"index": _selected_slot_index})
		"confirm":
			action_requested.emit(action_id, _collect_text_fields())
		_:
			action_requested.emit(action_id, payload)


func _clear_selection() -> void:
	_selected_inventory_index = -1
	_selected_slot_index = -1
	for field: LineEdit in _talent_fields:
		field.text = ""
	for field: LineEdit in _link_fields:
		field.text = ""
	action_requested.emit("clear_selection", {})


func _collect_text_fields() -> Dictionary:
	var talents: Array[String] = []
	var links: Array[String] = []
	for field: LineEdit in _talent_fields:
		talents.append(field.text)
	for field: LineEdit in _link_fields:
		links.append(field.text)
	return {"talents": talents, "links": links}


func _on_field_submitted(value: String, field_type: String, index: int) -> void:
	action_requested.emit("%s_text_changed" % field_type, {"index": index, "text": value})


func _return_to_exploration() -> void:
	SceneManager.return_to_previous_scene(Constants.SCENE_EXPLORATION)


func _set_texture(target: TextureRect, path: String) -> void:
	if target == null:
		return
	if path.is_empty() or not ResourceLoader.exists(path):
		target.texture = null
		return
	target.texture = load(path) as Texture2D


func _texture_rect(node_name: String, parent: Control, left: float, top: float, right: float, bottom: float, stretch: TextureRect.StretchMode) -> TextureRect:
	var rect := TextureRect.new()
	rect.name = node_name
	rect.anchor_left = left
	rect.anchor_top = top
	rect.anchor_right = right
	rect.anchor_bottom = bottom
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = stretch
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect


func _label(node_name: String, parent: Control, value: String, font_size: int, color: Color, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _line_edit(node_name: String, parent: Control, left: float, top: float, right: float, bottom: float) -> LineEdit:
	var field := LineEdit.new()
	field.name = node_name
	field.anchor_left = left
	field.anchor_top = top
	field.anchor_right = right
	field.anchor_bottom = bottom
	field.alignment = HORIZONTAL_ALIGNMENT_CENTER
	field.add_theme_color_override("font_color", PAPER_TEXT)
	field.add_theme_color_override("font_placeholder_color", Color("564332"))
	field.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	field.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	field.add_theme_stylebox_override("read_only", StyleBoxEmpty.new())
	parent.add_child(field)
	return field


func _add_heading(parent: Control, node_name: String, value: String, left: float, top: float, right: float, bottom: float) -> Label:
	var heading := _label(node_name, parent, value, 18, TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	heading.anchor_left = left
	heading.anchor_top = top
	heading.anchor_right = right
	heading.anchor_bottom = bottom
	return heading


func _on_used_sheet_selected() -> void:
	_selected_inventory_index = 0
	action_requested.emit("select_inventory", {"index": _selected_inventory_index})


func _layout_for_viewport() -> void:
	var viewport_size := get_viewport_rect().size
	var aspect := viewport_size.x / maxf(viewport_size.y, 1.0)
	const BOOK_ASPECT := 1.72
	if aspect > BOOK_ASPECT:
		var width := viewport_size.y * BOOK_ASPECT
		var margin := (viewport_size.x - width) * 0.5
		_book.anchor_left = 0.0
		_book.anchor_right = 0.0
		_book.offset_left = margin
		_book.offset_right = margin + width
	else:
		var height := viewport_size.x / BOOK_ASPECT
		var margin := (viewport_size.y - height) * 0.5
		_book.anchor_top = 0.0
		_book.anchor_bottom = 0.0
		_book.offset_top = margin
		_book.offset_bottom = margin + height
