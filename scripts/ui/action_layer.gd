class_name ActionLayer
extends HBoxContainer

## Action Layer: menu de ações (ataque, habilidades, itens, navegação)
##
## Arquitetura Dumb Terminal:
## - Não implementa lógica de jogo
## - Apenas emite sinais quando o usuário interage (skill §3)
## - Rótulos e ícones chegam por injeção de dados (§2.4)
##
## Os botões podem ser autorados na cena e exportados (§17). Botões sem
## dados injetados permanecem ocultos — a camada nunca inventa conteúdo.

signal action_requested(action_id: String)
signal enabled_changed(value: bool)

const ICON_SIZE := Vector2(44, 44)
const BUTTON_HEIGHT := 40

@export_group("Authored Actions")
@export var attack_button: Button
@export var attack_icon: TextureRect
@export var attack_frame: TextureRect
@export var skills_button: Button
@export var skills_icon: TextureRect
@export var skills_frame: TextureRect
@export var items_button: Button
@export var items_icon: TextureRect
@export var items_frame: TextureRect
@export var navigate_button: Button
@export var navigate_icon: TextureRect
@export var navigate_frame: TextureRect

# Referências diretas dos nós da cena (para atribuição via inspector)
@export var _attack_button_node: Button
@export var _skills_button_node: Button
@export var _items_button_node: Button
@export var _navigate_button_node: Button

## Ações iniciais. Vazio por padrão: sem conteúdo de jogo hardcoded.
@export var default_actions: Array[Dictionary] = []

# action_id -> { "button": Button, "icon": TextureRect }
var _authored: Dictionary = {}
var _dynamic_buttons: Array[Button] = []
var _actions_enabled: bool = true


func _init() -> void:
	add_theme_constant_override("separation", 12)
	alignment = BoxContainer.ALIGNMENT_CENTER


func _ready() -> void:
	_resolve_references()
	_register_authored(attack_button, attack_icon, "attack", attack_frame)
	_register_authored(skills_button, skills_icon, "skills", skills_frame)
	_register_authored(items_button, items_icon, "items", items_frame)
	_register_authored(navigate_button, navigate_icon, "navigate", navigate_frame)

	if not default_actions.is_empty():
		inject_actions(default_actions)


## Resolve referências diretas dos nós da cena.
func _resolve_references() -> void:
	if attack_button == null:
		attack_button = _attack_button_node if _attack_button_node != null else find_child("BtnAttack", true, false) as Button
	if skills_button == null:
		skills_button = _skills_button_node if _skills_button_node != null else find_child("BtnSkills", true, false) as Button
	if items_button == null:
		items_button = _items_button_node if _items_button_node != null else find_child("BtnItems", true, false) as Button
	if navigate_button == null:
		navigate_button = _navigate_button_node if _navigate_button_node != null else find_child("BtnNavigate", true, false) as Button

	# Encontra o Frame (TextureRect) irmão de cada botão dentro do Control pai
	if attack_frame == null and attack_button != null:
		attack_frame = _find_frame(attack_button)
	if skills_frame == null and skills_button != null:
		skills_frame = _find_frame(skills_button)
	if items_frame == null and items_button != null:
		items_frame = _find_frame(items_button)
	if navigate_frame == null and navigate_button != null:
		navigate_frame = _find_frame(navigate_button)

	# Encontra o Icon (TextureRect) dentro do mesmo Control pai do botão
	if attack_icon == null and attack_button != null:
		attack_icon = _find_icon(attack_button)
	if skills_icon == null and skills_button != null:
		skills_icon = _find_icon(skills_button)
	if items_icon == null and items_button != null:
		items_icon = _find_icon(items_button)
	if navigate_icon == null and navigate_button != null:
		navigate_icon = _find_icon(navigate_button)


## Procura o TextureRect chamado "Frame" dentro do Control pai do botão.
func _find_frame(button: Button) -> TextureRect:
	var parent: Node = button.get_parent()
	if parent == null:
		return null
	return parent.get_node_or_null("Frame") as TextureRect


## Procura o TextureRect chamado "Icon" dentro do Control pai do botão.
func _find_icon(button: Button) -> TextureRect:
	var parent: Node = button.get_parent()
	if parent == null:
		return null
	return parent.get_node_or_null("Icon") as TextureRect


## Registra um botão autorado pela cena e o oculta até receber dados.
func _register_authored(button: Button, icon: TextureRect, action_id: String, frame: TextureRect = null) -> void:
	if button == null:
		return

	_authored[action_id] = {"button": button, "icon": icon, "frame": frame}

	if not button.pressed.is_connected(_on_authored_pressed.bind(action_id)):
		button.pressed.connect(_on_authored_pressed.bind(action_id))

	_hide_item(button)
	if icon != null:
		icon.texture = null
	if frame != null:
		frame.texture = null


## Fica oculto o contêiner visual da opção (Frame + Icon + Button).
## Se o botão estiver direto no ActionLayer, oculta apenas o botão.
func _hide_item(button: Button) -> void:
	var parent: Node = button.get_parent()
	if parent != null and parent != self:
		if parent is Control:
			(parent as Control).visible = false
			return
	button.visible = false


## Fica visível o contêiner visual da opção (Frame + Icon + Button).
func _show_item(button: Button) -> void:
	var parent: Node = button.get_parent()
	if parent != null and parent != self:
		if parent is Control:
			(parent as Control).visible = true
			return
	button.visible = true


func _on_authored_pressed(action_id: String) -> void:
	if not _actions_enabled:
		return
	action_requested.emit(action_id)


## Injeta ações dinamicamente.
## Espera um array de dicionários:
##   label, action_id, accent_color, icon_path, frame_path
func inject_actions(actions_data: Array) -> void:
	_clear_dynamic_actions()
	_reset_authored_items()

	for entry in actions_data:
		if not entry is Dictionary:
			continue

		var action_id: String = str(entry.get("action_id", ""))
		if action_id.is_empty():
			continue

		var label: String = str(entry.get("label", ""))
		var has_accent: bool = entry.has("accent_color")
		var accent: Color = entry.get("accent_color", Color(0.878, 0.714, 0.29, 1))
		var icon_path: String = str(entry.get("icon_path", ""))
		var frame_path: String = str(entry.get("frame_path", ""))

		if _authored.has(action_id):
			_apply_authored(_authored[action_id], label, has_accent, accent, icon_path, frame_path)
		else:
			_add_dynamic_action(label, accent, icon_path, action_id, frame_path)


func _apply_authored(
		entry: Dictionary,
		label: String,
		has_accent: bool,
		accent: Color,
		icon_path: String,
		frame_path: String
) -> void:
	var button: Button = entry["button"]
	var icon: TextureRect = entry.get("icon", null)
	var frame: TextureRect = entry.get("frame", null)

	button.text = label
	button.tooltip_text = label
	button.visible = true
	_show_item(button)

	if has_accent:
		_apply_button_style(button, accent)

	_apply_icon(icon, icon_path)
	_apply_icon(frame, frame_path)


## Simple button styling without borders
func _apply_button_style(button: BaseButton, accent: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.169, 0.137, 0.094, 1)
	normal.set_corner_radius_all(4)
	
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.169, 0.137, 0.094, 1).lightened(0.12)
	hover.set_corner_radius_all(4)
	
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(0.169, 0.137, 0.094, 1).darkened(0.2)
	pressed.set_corner_radius_all(4)
	
	var disabled := StyleBoxFlat.new()
	disabled.bg_color = Color(0.169, 0.137, 0.094, 1).darkened(0.45)
	disabled.set_corner_radius_all(4)
	
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_stylebox_override("focus", normal)
	button.add_theme_color_override("font_color", Color(0.91, 0.863, 0.753, 1))
	button.add_theme_color_override("font_hover_color", Color(0.878, 0.714, 0.29, 1))
	button.add_theme_color_override("font_pressed_color", Color(0.878, 0.714, 0.29, 1))
	button.add_theme_color_override("font_disabled_color", Color(0.66, 0.59, 0.48, 1))
	button.add_theme_font_size_override("font_size", 20)


## Carrega a textura do caminho fornecido (§23: nunca assumir sucesso).
func _apply_icon(icon: TextureRect, icon_path: String) -> void:
	if icon == null:
		return

	icon.texture = null
	if icon_path.is_empty():
		return

	if not ResourceLoader.exists(icon_path):
		push_warning("ActionLayer: recurso de imagem não encontrado: %s" % icon_path)
		return

	var resource: Resource = ResourceLoader.load(icon_path)
	var texture: Texture2D = resource as Texture2D
	if texture == null:
		push_warning("ActionLayer: recurso não é Texture2D: %s" % icon_path)
		return

	icon.texture = texture


## Constrói um botão para action_ids sem botão autorado.
func _add_dynamic_action(
		label: String,
		accent: Color,
		icon_path: String,
		action_id: String,
		frame_path: String = ""
) -> void:
	var item := VBoxContainer.new()
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	item.add_theme_constant_override("separation", 4)
	add_child(item)

	# Frame: imagem de fundo da opção (moldura). Sem bordas.
	var frame := TextureRect.new()
	frame.custom_minimum_size = ICON_SIZE
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_icon(frame, frame_path)
	item.add_child(frame)

	if not icon_path.is_empty():
		var icon := TextureRect.new()
		icon.custom_minimum_size = ICON_SIZE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_apply_icon(icon, icon_path)
		item.add_child(icon)

	var button := Button.new()
	button.custom_minimum_size = Vector2(0, BUTTON_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.text = label
	button.tooltip_text = label
	button.disabled = not _actions_enabled
	_apply_button_style(button, accent)
	button.pressed.connect(_on_dynamic_pressed.bind(action_id))

	item.add_child(button)
	_dynamic_buttons.append(button)


func _on_dynamic_pressed(action_id: String) -> void:
	if not _actions_enabled:
		return
	action_requested.emit(action_id)


func _reset_authored_items() -> void:
	for action_id in _authored:
		var entry: Dictionary = _authored[action_id]
		var button: Button = entry["button"]
		_hide_item(button)
		button.text = ""
		button.tooltip_text = ""
		var icon: TextureRect = entry.get("icon", null)
		if icon != null:
			icon.texture = null
		var frame: TextureRect = entry.get("frame", null)
		if frame != null:
			frame.texture = null


func _clear_dynamic_actions() -> void:
	for button in _dynamic_buttons:
		var parent: Node = button.get_parent()
		if parent != null:
			parent.queue_free()
	_dynamic_buttons.clear()


## Habilita ou desabilita todas as ações.
func set_actions_enabled(value: bool) -> void:
	_actions_enabled = value

	for action_id in _authored:
		var button: Button = _authored[action_id]["button"]
		button.disabled = not value

	for button in _dynamic_buttons:
		button.disabled = not value

	enabled_changed.emit(value)


## Retorna se as ações estão habilitadas
func are_actions_enabled() -> bool:
	return _actions_enabled