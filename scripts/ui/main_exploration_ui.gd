extends Control
class_name MainExplorationUI

## Tela de exploração: a cena fornece conteúdo e assets por inject_data().
## Esta camada apenas apresenta os dados e encaminha ações da interface.

signal action_requested(action_type: String)
signal tab_selected(tab_name: String)

## Conteúdo inicial opcional, fornecido pela cena ou por um controller.
@export var initial_data: Dictionary = {}

const INK := Color("171c18")
const PANEL := Color("241d17")
const GOLD := Color("c3a574")
const TEXT := Color("e4d7b8")
const MUTED := Color("9d9075")

## Item 1: quanto a arte do personagem transborda do cartão de retrato.
## Valores em pixels, aplicados como offsets ancorados no centro.
const PORTRAIT_OVERFLOW_X := 60.0
const PORTRAIT_OVERFLOW_TOP := 150.0
const PORTRAIT_OVERFLOW_BOTTOM := 70.0

## Identificadores estruturais das ações. Rótulos e imagens chegam por
## injeção (skill §2.4); sem dados, o contêiner fica vazio.
const ACTION_IDS: Array[String] = ["items", "inventory", "look", "navigate"]

## Nomes das abas do painel de informações (estrutura de interface).
const TAB_NAMES: Array[String] = ["Mapa", "Atributos", "Missões", "Dicas"]

## Duração do crossfade entre a arte inativa e a ativa dos menus.
const MENU_FADE_DURATION := 0.22

## Item 5: quanto a aba ativa transborda para baixo, fazendo a seta da arte
## active.png passar para fora do botão. O tamanho do slot não muda.
const MENU_ACTIVE_OVERFLOW := 16.0

## Sangria do fundo do painel. ui_menu.png tem borda transparente
## (medido: 5 px esquerda, 3 px direita, 5 px topo, 11 px base). Sem sangria
## essa faixa translúcida deixa o palco/cinza de limpeza aparecer como uma
## borda ao redor do contêiner. O fundo é estendido para fora do painel
## para que a parte visível da arte seja exatamente a área desejada.
const MENU_BACKGROUND_BLEED := 0.02

## Duração de uma volta completa da engrenagem de configuração.
const SETTINGS_SPIN_DURATION := 0.7

var _left_area: Control
var _artwork: TextureRect
var _dialogue_text: Label
var _speaker_name: Label
var _portrait_left: TextureRect
var _portrait_right: TextureRect
var _left_portrait_name: Label
var _right_portrait_name: Label
var _portrait_hints: Dictionary = {}
var _action_frames: Dictionary = {}
var _action_icons: Dictionary = {}
var _action_labels: Dictionary = {}
var _action_buttons: Dictionary = {}
# Contêineres que aceitam caminho de imagem do backend (§2.3)
var _dialogue_frame: TextureRect
var _speaker_plate: TextureRect
var _information_frame: TextureRect
var _settings_frame: TextureRect
var _settings_icon: TextureRect
var _portrait_frames: Dictionary = {}
var _portrait_plates: Dictionary = {}
var _tab_frames_active: Dictionary = {}
var _tab_frames_inactive: Dictionary = {}
var _tab_visuals: Dictionary = {}
var _tab_labels: Dictionary = {}
var _quest_list: VBoxContainer
var _content_list: VBoxContainer
var _active_tab := "Missões"
var _tab_buttons: Dictionary = {}
var _tab_content: Dictionary = {}


func _ready() -> void:
	_build_interface()
	get_viewport().size_changed.connect(_layout_for_viewport)
	_layout_for_viewport()
	if not initial_data.is_empty():
		inject_data(initial_data)


func inject_data(data: Dictionary) -> void:
	## Contrato visual: background_path, speaker, dialogue, portraits, missions,
	## map, attributes, tips. Nenhum estado de jogo é decidido aqui.
	if data.has("background_path"):
		_artwork.texture = _load_texture(str(data["background_path"]))
	if data.has("dialogue"):
		_dialogue_text.text = str(data["dialogue"])
	if data.has("speaker"):
		_speaker_name.text = str(data["speaker"])
		_left_portrait_name.text = str(data["speaker"])
	if data.has("companion"):
		_right_portrait_name.text = str(data["companion"])
	if data.has("portrait_left_path"):
		_portrait_left.texture = _load_texture(str(data["portrait_left_path"]))
		_portrait_hints["left"].visible = _portrait_left.texture == null
	if data.has("portrait_right_path"):
		_portrait_right.texture = _load_texture(str(data["portrait_right_path"]))
		_portrait_hints["right"].visible = _portrait_right.texture == null
	# Item 2: moldura do pergaminho de diálogo.
	if data.has("dialogue_frame_path"):
		_apply_texture(_dialogue_frame, str(data["dialogue_frame_path"]))

	# Item 3: placa do nome do falante.
	if data.has("speaker_plate_path"):
		_apply_texture(_speaker_plate, str(data["speaker_plate_path"]))

	# Item 6: área de conteúdo do painel de informações.
	if data.has("information_frame_path"):
		_apply_texture(_information_frame, str(data["information_frame_path"]))

	# Chave de configuração (superior esquerdo).
	if data.has("settings_frame_path"):
		_apply_texture(_settings_frame, str(data["settings_frame_path"]))
	if data.has("settings_icon_path"):
		_apply_texture(_settings_icon, str(data["settings_icon_path"]))

	# Item 3: moldura do retrato. Fica ENTRE o background geral e a imagem do
	# personagem (a arte é adicionada depois no _portrait_card, portanto
	# desenha por cima). "portrait_frame_path" vale para os dois lados;
	# as chaves por lado têm precedência.
	for side in ["left", "right"]:
		var portrait_frame_path: String = str(data.get("portrait_%s_frame_path" % side, ""))
		if portrait_frame_path.is_empty() and data.has("portrait_frame_path"):
			portrait_frame_path = str(data["portrait_frame_path"])
		_apply_texture(_portrait_frames.get(side, null), portrait_frame_path)

		if data.has("portrait_%s_plate_path" % side):
			_apply_texture(_portrait_plates.get(side, null), str(data["portrait_%s_plate_path" % side]))

	# Item 4: arte dos menus. Um caminho único para todas as abas ou um
	# dicionário por aba, para ativo e inativo.
	for tab_name in _tab_frames_active:
		var active_path: String = _resolve_menu_path(data, "menu_active", tab_name)
		var inactive_path: String = _resolve_menu_path(data, "menu_inactive", tab_name)
		_apply_texture(_tab_frames_active.get(tab_name, null), active_path)
		_apply_texture(_tab_frames_inactive.get(tab_name, null), inactive_path)

	if data.has("actions") and data["actions"] is Array:
		_inject_actions(data["actions"])
	for key in ["map", "attributes", "missions", "tips"]:
		if data.has(key):
			_tab_content[key] = data[key]
	_select_tab(_active_tab)


## Carrega uma textura de forma defensiva (§23). Caminho vazio é ignorado;
## caminho inválido emite aviso com o caminho solicitado.
func _apply_texture(target: TextureRect, path: String) -> void:
	if target == null:
		return

	target.texture = _load_texture(path)


## Resolve o caminho da arte de um menu ("menu_active" / "menu_inactive").
## Aceita "menu_active_path" (um caminho para todas as abas) ou
## "menu_active_frames" (dicionário por aba), que tem precedência.
func _resolve_menu_path(data: Dictionary, kind: String, tab_name: String) -> String:
	var per_tab: Variant = data.get("%s_frames" % kind, null)
	if per_tab is Dictionary:
		return str((per_tab as Dictionary).get(tab_name, ""))

	return str(data.get("%s_path" % kind, ""))


## Injeta as ações do backend (skill §15).
## Espera um array de dicionários: action_id, label, frame_path, icon_path
func _inject_actions(actions_data: Array) -> void:
	for entry in actions_data:
		if not entry is Dictionary:
			continue

		var action_id := str(entry.get("action_id", ""))
		if action_id.is_empty():
			continue

		if entry.has("label"):
			var label: Label = _action_labels.get(action_id, null)
			if label != null:
				label.text = str(entry["label"])

		if entry.has("frame_path"):
			_apply_texture(_action_frames.get(action_id, null), str(entry["frame_path"]))

		if entry.has("icon_path"):
			_apply_texture(_action_icons.get(action_id, null), str(entry["icon_path"]))


func _build_interface() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# One shared background container spans scene, dialogue, and action regions.
	_left_area = Control.new()
	_left_area.name = "SharedStageBackground"
	_left_area.anchor_right = 0.69
	_left_area.anchor_bottom = 1.0
	_left_area.clip_contents = true
	add_child(_left_area)

	_artwork = TextureRect.new()
	_artwork.name = "SharedBackgroundArtwork"
	_artwork.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_artwork.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_artwork.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_left_area.add_child(_artwork)

	# Chave de configuração (superior esquerdo): contêiner limpo.
	# A moldura e o ícone chegam por "settings_frame_path" / "settings_icon_path".
	var settings_slot := Control.new()
	settings_slot.name = "SettingsSlot"
	settings_slot.anchor_left = 0.018
	settings_slot.anchor_top = 0.018
	# Largura próxima da altura para a arte 440x440 não ficar com área
	# de clique morta ao lado (o ícone usa KEEP_ASPECT_CENTERED).
	settings_slot.anchor_right = 0.056
	settings_slot.anchor_bottom = 0.085
	settings_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_left_area.add_child(settings_slot)

	var settings_visual := Control.new()
	settings_visual.name = "Visual"
	settings_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	settings_visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings_visual.resized.connect(_center_pivot.bind(settings_visual))
	settings_slot.add_child(settings_visual)

	_settings_frame = TextureRect.new()
	_settings_frame.name = "Frame"
	_settings_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_settings_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_settings_frame.stretch_mode = TextureRect.STRETCH_SCALE
	_settings_frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_settings_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	settings_visual.add_child(_settings_frame)

	_settings_icon = TextureRect.new()
	_settings_icon.name = "Icon"
	_settings_icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_settings_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_settings_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_settings_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_settings_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# O giro acontece em torno do centro da própria imagem: sem o pivot
	# centralizado a engrenagem oscilaria em torno do canto.
	_settings_icon.pivot_offset = _settings_icon.size * 0.5
	_settings_icon.resized.connect(_center_pivot.bind(_settings_icon))
	settings_visual.add_child(_settings_icon)

	var settings := Button.new()
	settings.name = "Button"
	settings.flat = true
	settings.focus_mode = Control.FOCUS_NONE
	settings.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	settings.pressed.connect(_on_settings_pressed)
	settings_slot.add_child(settings)
	_bind_option_feedback(settings_visual, settings)

	_build_dialogue_region()
	_build_action_bar()
	_build_information_panel()


func _build_dialogue_region() -> void:
	# Transparent dialogue overlays above the shared stage background.
	var box := Control.new()
	box.name = "DialogueFrame"
	# Sem recorte: a arte do retrato/item 1 precisa transbordar para o palco.
	box.clip_contents = false
	box.anchor_left = 0.035
	box.anchor_top = 0.545
	box.anchor_right = 0.965
	box.anchor_bottom = 0.875
	_left_area.add_child(box)

	# Item 2: moldura do pergaminho de diálogo. Contêiner limpo; a imagem
	# chega por inject_data() com a chave "dialogue_frame_path".
	var center := Control.new()
	center.name = "DialogueTextArea"
	center.anchor_left = 0.245
	center.anchor_top = 0.17
	center.anchor_right = 0.755
	center.anchor_bottom = 0.8
	box.add_child(center)

	_dialogue_frame = TextureRect.new()
	_dialogue_frame.name = "Frame"
	_dialogue_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dialogue_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_dialogue_frame.stretch_mode = TextureRect.STRETCH_SCALE
	_dialogue_frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_dialogue_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(_dialogue_frame)

	# Item 3: placa do nome do falante ("speaker_plate_path").
	var plate := Control.new()
	plate.name = "SpeakerPlate"
	plate.anchor_left = 0.0
	plate.anchor_top = 0.03
	plate.anchor_right = 0.42
	plate.anchor_bottom = 0.28
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(plate)

	_speaker_plate = TextureRect.new()
	_speaker_plate.name = "Frame"
	_speaker_plate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_speaker_plate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_speaker_plate.stretch_mode = TextureRect.STRETCH_SCALE
	_speaker_plate.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_speaker_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_child(_speaker_plate)

	_speaker_name = _label("", 20, GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_speaker_name.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plate.add_child(_speaker_name)

	_dialogue_text = _label("A fala da cena será exibida aqui.", 17, TEXT)
	_dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_dialogue_text.anchor_left = 0.0
	_dialogue_text.anchor_top = 0.32
	_dialogue_text.anchor_right = 1.0
	_dialogue_text.anchor_bottom = 1.0
	center.add_child(_dialogue_text)

	var left_card := _portrait_card("SpeakerPortrait", "Retrato", false)
	left_card.anchor_left = 0.015
	left_card.anchor_top = -0.03
	left_card.anchor_right = 0.235
	left_card.anchor_bottom = 1.02
	box.add_child(left_card)
	var right_card := _portrait_card("CompanionPortrait", "Retrato", true)
	right_card.anchor_left = 0.765
	right_card.anchor_top = -0.03
	right_card.anchor_right = 0.985
	right_card.anchor_bottom = 1.02
	box.add_child(right_card)


## Item 1: cartão de retrato.
## O container NÃO recorta (`clip_contents` desligado) e a arte do personagem
## é centralizada e transborda do retrato, ficando visível também sobre o
## container do fundo da cena.
func _portrait_card(node_name: String, caption: String, right_side: bool) -> Control:
	var side_key: String = "right" if right_side else "left"

	var card := Control.new()
	card.name = node_name
	card.clip_contents = false
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Moldura do retrato: imagem opcional do backend.
	var frame := TextureRect.new()
	frame.name = "Frame"
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(frame)
	_portrait_frames[side_key] = frame

	# A arte do personagem: centralizada no eixo x e maior que o retrato,
	# transbordando para cima e para baixo (cabeça acima da moldura).
	var image := TextureRect.new()
	image.name = "Portrait"
	image.anchor_left = 0.5
	image.anchor_right = 0.5
	image.anchor_top = 0.0
	image.anchor_bottom = 1.0
	image.offset_left = -PORTRAIT_OVERFLOW_X
	image.offset_right = PORTRAIT_OVERFLOW_X
	image.offset_top = -PORTRAIT_OVERFLOW_TOP
	image.offset_bottom = PORTRAIT_OVERFLOW_BOTTOM
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(image)
	if right_side:
		_portrait_right = image
	else:
		_portrait_left = image

	# Marcador de posição: só aparece enquanto não há arte carregada.
	var empty_label := _label("ARTE DO PERSONAGEM", 11, MUTED, HORIZONTAL_ALIGNMENT_CENTER)
	empty_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card.add_child(empty_label)
	_portrait_hints[side_key] = empty_label

	# Placa de nome sob o retrato (imagem opcional do backend).
	var footer := Control.new()
	footer.name = "Nameplate"
	footer.anchor_left = 0.0
	footer.anchor_top = 0.83
	footer.anchor_right = 1.0
	footer.anchor_bottom = 1.0
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(footer)

	var plate := TextureRect.new()
	plate.name = "Frame"
	plate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plate.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	plate.stretch_mode = TextureRect.STRETCH_SCALE
	plate.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_child(plate)
	_portrait_plates[side_key] = plate

	var name := _label(caption, 15, TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	name.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	footer.add_child(name)
	if right_side:
		_right_portrait_name = name
	else:
		_left_portrait_name = name
	return card


func _build_action_bar() -> void:
	var bar := Control.new()
	bar.name = "ActionBar"
	bar.anchor_left = 0.0
	bar.anchor_top = 0.895
	bar.anchor_right = 1.0
	bar.anchor_bottom = 1.0
	_left_area.add_child(bar)

	var actions := HBoxContainer.new()
	actions.name = "ActionButtons"
	actions.anchor_left = 0.39
	actions.anchor_top = 0.12
	actions.anchor_right = 0.94
	actions.anchor_bottom = 0.9
	actions.add_theme_constant_override("separation", 10)
	bar.add_child(actions)

	# Cada ação é um contêiner limpo: Frame (moldura) + Icon + Label + Button.
	# Nenhuma imagem é embutida aqui; o backend injeta os caminhos.
	for action_id in ACTION_IDS:
		var slot := Control.new()
		slot.name = "Action%s" % action_id.capitalize()
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		actions.add_child(slot)

		# `visual` é o que escala no hover. Fica separado do `slot` para que a
		# área de clique nunca cresça: uma opção ampliada não pode invadir a
		# área da vizinha, senão o hover "gruda" e não volta ao normal.
		var visual := Control.new()
		visual.name = "Visual"
		visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		visual.pivot_offset = Vector2.ZERO
		visual.resized.connect(_center_pivot.bind(visual))
		slot.add_child(visual)

		var frame := TextureRect.new()
		frame.name = "Frame"
		frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		# STRETCH_SCALE: a moldura ocupa exatamente o container, sem corte
		# e sem margem. Para preservar a proporção use KEEP_ASPECT_CENTERED.
		frame.stretch_mode = TextureRect.STRETCH_SCALE
		frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		visual.add_child(frame)
		_action_frames[action_id] = frame

		var icon := TextureRect.new()
		icon.name = "Icon"
		icon.anchor_left = 0.5
		icon.anchor_right = 0.5
		icon.anchor_top = 0.08
		icon.anchor_bottom = 0.44
		icon.offset_left = -26.0
		icon.offset_right = 26.0
		icon.grow_horizontal = Control.GROW_DIRECTION_BOTH
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		visual.add_child(icon)
		_action_icons[action_id] = icon

		# Texto centralizado nos dois eixos dentro do contêiner da opção.
		var label := Label.new()
		label.name = "Label"
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.offset_top = 0.0
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		label.clip_text = false
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", TEXT)
		visual.add_child(label)
		_action_labels[action_id] = label

		var btn := Button.new()
		btn.name = "Button"
		# flat e sem texto: o Button é apenas o capturador de clique/hover,
		# e nunca é escalado. O rótulo é o Label dentro de `visual`.
		btn.flat = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		slot.add_child(btn)
		_action_buttons[action_id] = btn

		_bind_option_feedback(visual, btn)
		btn.pressed.connect(_forward_action.bind(action_id))


## Centraliza o pivot para o efeito de clique escalar a partir do meio.
func _center_pivot(visual: Control) -> void:
	visual.pivot_offset = visual.size * 0.5


## Simula hover e clique no contêiner + imagem da opção.
## `visual` é escalado; `button` nunca muda de tamanho.
func _bind_option_feedback(visual: Control, button: Button) -> void:
	button.mouse_entered.connect(_on_option_hover.bind(visual, true))
	button.mouse_exited.connect(_on_option_hover.bind(visual, false))
	button.button_down.connect(_on_option_press.bind(visual, true))
	button.button_up.connect(_on_option_press.bind(visual, false))


func _on_option_hover(visual: Control, entered: bool) -> void:
	if entered:
		_animate_option(visual, Color("fdf3df"), Vector2(1.04, 1.04), 0.12)
	else:
		_animate_option(visual, Color.WHITE, Vector2.ONE, 0.12)


func _on_option_press(visual: Control, pressed: bool) -> void:
	if pressed:
		_animate_option(visual, Color("9c8f74"), Vector2(0.94, 0.92), 0.05)
	else:
		# Soltar devolve ao estado de hover somente se o ponteiro continuar dentro.
		_reset_option(visual)


## Volta a opção ao estado neutro (sem hover, sem clique).
func _reset_option(visual: Control) -> void:
	if visual.get_global_rect().has_point(get_global_mouse_position()):
		_animate_option(visual, Color("fdf3df"), Vector2(1.04, 1.04), 0.12)
	else:
		_animate_option(visual, Color.WHITE, Vector2.ONE, 0.12)


## Anima modulate e escala. Uma única origem de verdade por opção:
## o tween anterior é morto antes de criar o próximo, senão tweens
## concorrentes disputam as mesmas propriedades e o estado "gruda".
func _animate_option(visual: Control, tint: Color, target_scale: Vector2, duration: float) -> void:
	var previous: Variant = visual.get_meta("option_tween", null)
	if previous is Tween:
		var stale := previous as Tween
		if stale.is_valid():
			stale.kill()

	# O pivot precisa refletir o tamanho atual, senão o texto e a moldura
	# saem do centro enquanto a opção está ampliada.
	_center_pivot(visual)

	var tween := visual.create_tween()
	visual.set_meta("option_tween", tween)
	tween.set_parallel(true)
	tween.tween_property(visual, "modulate", tint, duration)
	tween.tween_property(visual, "scale", target_scale, duration)


func _build_information_panel() -> void:
	var panel := Control.new()
	panel.name = "InformationPanel"
	# Item 4: as bordas encostam na palco (sem folga). A folga anterior
	# entre 0.69 e 0.695 deixava a cor de limpeza cinza do Godot aparecer
	# como uma borda vertical. As margens agora vêm da arte ui_menu.png.
	panel.anchor_left = 0.69
	panel.anchor_right = 1.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 1.0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)

	# Itens 1, 3 e 4: contêiner ÚNICO do painel.
	# A arte "information_frame_path" (ui_menu.png) é o fundo do painel e
	# ocupa também a área tracejada — não existe mais um Panel por cima.
	# O StyleBoxFlat que gerava a borda cinza foi removido.
	_information_frame = TextureRect.new()
	_information_frame.name = "MenuBackground"
	_information_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_information_frame.stretch_mode = TextureRect.STRETCH_SCALE
	_information_frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_information_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Sangria: a arte transborda um pouco para fora do painel, escondendo a
	# faixa transparente da borda do PNG. Sem isso sobra uma borda de
	# contêiner visível ao redor do menu.
	_information_frame.anchor_left = -MENU_BACKGROUND_BLEED
	_information_frame.anchor_top = -MENU_BACKGROUND_BLEED
	_information_frame.anchor_right = 1.0 + MENU_BACKGROUND_BLEED
	_information_frame.anchor_bottom = 1.0 + MENU_BACKGROUND_BLEED
	_information_frame.offset_left = 0.0
	_information_frame.offset_top = 0.0
	_information_frame.offset_right = 0.0
	_information_frame.offset_bottom = 0.0
	panel.add_child(_information_frame)

	# Item 2/3: as abas são adicionadas depois do fundo e do conteúdo,
	# então ficam sobrepostas acima do item 1, mantendo sua posição.
	var tabs := HBoxContainer.new()
	tabs.name = "TabBar"
	tabs.anchor_right = 1.0
	tabs.anchor_bottom = 0.062
	# Item 5: espaçamento reduzido entre os botões.
	tabs.add_theme_constant_override("separation", 0)
	panel.add_child(tabs)
	for tab in TAB_NAMES:
		var slot := Control.new()
		slot.name = "Tab%s" % tab
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Permite que a aba ativa transborde para baixo (seta do item 5).
		slot.clip_contents = false
		tabs.add_child(slot)

		var visual := Control.new()
		visual.name = "Visual"
		visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		visual.clip_contents = false
		visual.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		visual.resized.connect(_center_pivot.bind(visual))
		slot.add_child(visual)
		_tab_visuals[tab] = visual

		# Duas molduras empilhadas (inativa/ativa) permitem o crossfade fluido
		# entre "icon_menu_inactive.png" e "icon_menu_active.png".
		var frame_inactive := TextureRect.new()
		frame_inactive.name = "FrameInactive"
		frame_inactive.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		frame_inactive.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame_inactive.stretch_mode = TextureRect.STRETCH_SCALE
		frame_inactive.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		frame_inactive.mouse_filter = Control.MOUSE_FILTER_IGNORE
		visual.add_child(frame_inactive)
		_tab_frames_inactive[tab] = frame_inactive

		var frame_active := TextureRect.new()
		frame_active.name = "FrameActive"
		frame_active.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		frame_active.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame_active.stretch_mode = TextureRect.STRETCH_SCALE
		frame_active.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		frame_active.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame_active.modulate = Color(1, 1, 1, 0)
		visual.add_child(frame_active)
		_tab_frames_active[tab] = frame_active

		var label := _label(tab, 15, TEXT, HORIZONTAL_ALIGNMENT_CENTER)
		label.name = "Label"
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		visual.add_child(label)
		_tab_labels[tab] = label

		var button := Button.new()
		button.name = "Button"
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		button.pressed.connect(_select_tab.bind(tab))
		slot.add_child(button)
		_bind_option_feedback(visual, button)
		_tab_buttons[tab] = button

	# Área de conteúdo: apenas a lista rolável sobre a arte do item 1.
	var content := Control.new()
	content.name = "InformationContent"
	content.anchor_left = 0.03
	content.anchor_top = 0.075
	content.anchor_right = 0.97
	content.anchor_bottom = 0.985
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(content)

	var scroll := ScrollContainer.new()
	scroll.anchor_left = 0.03
	scroll.anchor_top = 0.02
	scroll.anchor_right = 0.97
	scroll.anchor_bottom = 0.98
	# O ScrollContainer tem um stylebox "panel" próprio no tema padrão;
	# limpando, ele deixa de desenhar uma borda de contêiner.
	scroll.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	content.add_child(scroll)
	_quest_list = VBoxContainer.new()
	_quest_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_quest_list.add_theme_constant_override("separation", 12)
	scroll.add_child(_quest_list)
	_content_list = _quest_list

	# Item 2/3: as abas vão para o topo da ordem de desenho, para que a arte
	# ativa (e a seta que transborda para baixo) fique sobre o item 1 e o
	# conteúdo, sem alterar a posição das abas na tela.
	panel.move_child(tabs, -1)

	_select_tab(_active_tab)


func _select_tab(tab_name: String) -> void:
	_active_tab = tab_name
	for key in _tab_buttons:
		var is_active: bool = key == tab_name

		# Tint do rótulo acompanha o estado da aba.
		var tint: Color = Color("f0d69d") if is_active else Color("9d9075")
		var label: Label = _tab_labels.get(key, null)
		if label != null:
			label.add_theme_color_override("font_color", tint)

		_animate_menu_frames(key, is_active)


## Crossfade fluido entre a arte inativa e a ativa de uma aba.
func _animate_menu_frames(tab_name: String, is_active: bool) -> void:
	var active_frame: TextureRect = _tab_frames_active.get(tab_name, null)
	var inactive_frame: TextureRect = _tab_frames_inactive.get(tab_name, null)
	if active_frame == null or inactive_frame == null:
		return

	# Mata o crossfade anterior desta aba para não haver dois em curso.
	for node in [active_frame, inactive_frame]:
		var previous: Variant = node.get_meta("menu_tween", null)
		if previous is Tween:
			var stale := previous as Tween
			if stale.is_valid():
				stale.kill()

	var target_active: float = 1.0 if is_active else 0.0
	var target_inactive: float = 0.0 if is_active else 1.0

	# Item 5: o slot da aba mantém o tamanho; só a arte ativa cresce para
	# baixo, para que a seta do desenho fique visível.
	var target_overflow: float = MENU_ACTIVE_OVERFLOW if is_active else 0.0

	var tween := create_tween()
	tween.set_parallel(true)
	active_frame.set_meta("menu_tween", tween)
	tween.tween_property(
		active_frame, "modulate:a", target_active, MENU_FADE_DURATION
	)
	tween.tween_property(
		inactive_frame, "modulate:a", target_inactive, MENU_FADE_DURATION
	)
	tween.tween_property(
		active_frame, "offset_bottom", target_overflow, MENU_FADE_DURATION
	)
	if _content_list != null:
		var content_key: String = ""
		match tab_name:
			"Mapa": content_key = "map"
			"Atributos": content_key = "attributes"
			"Missões": content_key = "missions"
			"Dicas": content_key = "tips"
		_set_entries(_content_list, _tab_content.get(content_key, []))
	tab_selected.emit(tab_name)


func _set_entries(list: VBoxContainer, entries: Variant) -> void:
	for child in list.get_children():
		child.queue_free()
	if not entries is Array:
		return
	for entry in entries:
		var text := str(entry.get("text", "")) if entry is Dictionary else str(entry)
		var row := _label(text, 17, TEXT)
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.custom_minimum_size.y = 30
		list.add_child(row)


func _load_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not ResourceLoader.exists(path):
		push_warning("Asset visual não encontrado: %s" % path)
		return null
	var loaded: Resource = ResourceLoader.load(path)
	var texture := loaded as Texture2D
	if texture == null:
		push_warning("O asset não pôde ser carregado como textura: %s" % path)
	return texture


func _forward_action(action_type: String) -> void:
	action_requested.emit(action_type)


## Clique no botão de configuração: a engrenagem gira no próprio lugar.
## Só `rotation` é animada — `position`, `size` e `offset_*` ficam intactos,
## então o botão não se move em X nem em Y.
func _on_settings_pressed() -> void:
	_spin_settings_icon()
	action_requested.emit("settings")


func _spin_settings_icon() -> void:
	if _settings_icon == null:
		return

	# Só um giro por vez; um novo clique reinicia o giro em curso.
	var previous: Variant = _settings_icon.get_meta("spin_tween", null)
	if previous is Tween:
		var stale := previous as Tween
		if stale.is_valid():
			stale.kill()

	_center_pivot(_settings_icon)
	_settings_icon.rotation = 0.0

	var tween := create_tween()
	_settings_icon.set_meta("spin_tween", tween)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		_settings_icon, "rotation", TAU, SETTINGS_SPIN_DURATION
	)


func _layout_for_viewport() -> void:
	if _left_area == null:
		return
	var viewport_size := get_viewport_rect().size
	var narrow := viewport_size.x < 900.0
	# O painel encosta no palco: sem folga, para não aparecer a cor de
	# limpeza cinza do Godot entre as duas áreas (item 4).
	_left_area.anchor_right = 1.0 if narrow else 0.69
	var panel: Control = get_node("InformationPanel")
	panel.anchor_left = 0.0 if narrow else 0.69
	panel.anchor_top = 0.68 if narrow else 0.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	if narrow:
		_left_area.anchor_bottom = 0.68
	else:
		_left_area.anchor_bottom = 1.0


func _panel(node_name: String, color: Color, alpha: float) -> Panel:
	## Removido no item 4: este Panel era a origem da borda cinza.
	## O painel de informações passou a ser um Control limpo, preenchido
	## pela arte de "information_frame_path".
	push_warning("MainExplorationUI: _panel() foi descontinuado (item 4)")
	var panel := Panel.new()
	panel.name = node_name
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color.r, color.g, color.b, alpha)
	style.border_color = Color(0, 0, 0, 0)
	style.set_border_width_all(0)
	style.set_corner_radius_all(0)
	style.shadow_size = 0
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _label(value: String, size: int, color: Color, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _button(value: String, size: int) -> Button:
	## Botão neutro, sem bordas. Usado apenas por controles que ainda não
	## migraram para o padrão slot -> visual -> Button (imagem injetada).
	var button := Button.new()
	button.text = value
	button.add_theme_font_size_override("font_size", size)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", Color("f0d69d"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("30251b")
	normal.border_color = Color(0, 0, 0, 0)
	normal.set_border_width_all(0)
	normal.set_corner_radius_all(0)
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("493725")
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("disabled", normal)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return button
