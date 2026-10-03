class_name CharacterLayer
extends Control

## Character Layer: Exibe retratos de personagens (jogador e inimigo)
##
## Arquitetura Dumb Terminal:
## - Não implementa lógica de jogo
## - Apenas renderiza dados injetados
## - Carrega texturas de caminhos fornecidos pelo backend
##
## Referências de nós são exportadas (§17). Quando não são atribuídas,
## a camada resolve os filhos por tipo — o que mantém o uso programático
## do nó funcional sem duplicar sistemas.

signal character_selected(character_id: String)

@export_group("Player")
@export var player_portrait: Control
@export var player_portrait_rect: TextureRect
@export var player_name_label: Label

@export_group("Enemy")
@export var enemy_portrait: Control
@export var enemy_portrait_rect: TextureRect
@export var enemy_name_label: Label

# Referências diretas dos nós da cena (para atribuição via inspector)
@export var _player_portrait_node: Control
@export var _player_portrait_rect_node: TextureRect
@export var _player_name_label_node: Label
@export var _enemy_portrait_node: Control
@export var _enemy_portrait_rect_node: TextureRect
@export var _enemy_name_label_node: Label

var _player_data: Dictionary = {}
var _enemy_data: Dictionary = {}


func _ready() -> void:
	_resolve_references()


## Resolve referências ausentes procurando filhos por tipo.
func _resolve_references() -> void:
	push_warning("CharacterLayer: _resolve_references iniciado")
	push_warning("CharacterLayer: _player_portrait_node = ", _player_portrait_node)
	push_warning("CharacterLayer: _enemy_portrait_node = ", _enemy_portrait_node)
	
	if player_portrait == null:
		player_portrait = _player_portrait_node if _player_portrait_node != null else find_child("PlayerPortrait", true, false) as Control
		push_warning("CharacterLayer: player_portrait resolvido = ", player_portrait)
	if enemy_portrait == null:
		enemy_portrait = _enemy_portrait_node if _enemy_portrait_node != null else find_child("EnemyPortrait", true, false) as Control
		push_warning("CharacterLayer: enemy_portrait resolvido = ", enemy_portrait)

	if player_portrait_rect == null and player_portrait != null:
		player_portrait_rect = _player_portrait_rect_node if _player_portrait_rect_node != null else _find_texture_rect(player_portrait)
		push_warning("CharacterLayer: player_portrait_rect resolvido = ", player_portrait_rect)
	if enemy_portrait_rect == null and enemy_portrait != null:
		enemy_portrait_rect = _enemy_portrait_rect_node if _enemy_portrait_rect_node != null else _find_texture_rect(enemy_portrait)
		push_warning("CharacterLayer: enemy_portrait_rect resolvido = ", enemy_portrait_rect)

	if player_name_label == null and player_portrait != null:
		player_name_label = _player_name_label_node if _player_name_label_node != null else _find_label(player_portrait)
		push_warning("CharacterLayer: player_name_label resolvido = ", player_name_label)
	if enemy_name_label == null and enemy_portrait != null:
		enemy_name_label = _enemy_name_label_node if _enemy_name_label_node != null else _find_label(enemy_portrait)
		push_warning("CharacterLayer: enemy_name_label resolvido = ", enemy_name_label)


## API principal (skill §9): recebe jogador e inimigo separadamente.
func update_characters(player_data: Dictionary, enemy_data: Dictionary) -> void:
	push_warning("CharacterLayer.update_characters chamado")
	push_warning("  player_data = ", player_data)
	push_warning("  enemy_data = ", enemy_data)
	update_player(player_data)
	update_enemy(enemy_data)


## Injeta dados de personagens
## Espera: {"player": {...}, "enemy": {...}}
func inject_characters(data: Dictionary) -> void:
	if data.has("player"):
		update_player(data["player"])

	if data.has("enemy"):
		update_enemy(data["enemy"])


## Atualiza o retrato do jogador
func update_player(player_data: Dictionary) -> void:
	_player_data = player_data
	_render_portrait(
		player_portrait,
		player_portrait_rect,
		player_name_label,
		player_data
	)


## Atualiza o retrato do inimigo
func update_enemy(enemy_data: Dictionary) -> void:
	_enemy_data = enemy_data
	_render_portrait(
		enemy_portrait,
		enemy_portrait_rect,
		enemy_name_label,
		enemy_data
	)


## Limpa os retratos (usado pelo controller ao resetar a tela).
func clear() -> void:
	_player_data.clear()
	_enemy_data.clear()

	for rect in [player_portrait_rect, enemy_portrait_rect]:
		if rect != null:
			rect.texture = null

	for label in [player_name_label, enemy_name_label]:
		if label != null:
			label.text = ""


## Renderiza um retrato com dados injetados.
func _render_portrait(
		portrait_container: Control,
		texture_rect: TextureRect,
		name_label: Label,
		char_data: Dictionary
) -> void:
	if portrait_container == null:
		push_warning("_render_portrait: portrait_container é null")
		return

	var target_rect: TextureRect = texture_rect
	if target_rect == null:
		target_rect = _find_texture_rect(portrait_container)

	var target_label: Label = name_label
	if target_label == null:
		target_label = _find_label(portrait_container)

	# Carrega a textura do caminho fornecido (§23: nunca assumir sucesso).
	var image_path: String = str(char_data.get("image_path", ""))
	push_warning("_render_portrait: image_path = ", image_path)
	if not image_path.is_empty():
		if ResourceLoader.exists(image_path):
			push_warning("_render_portrait: arquivo existe, carregando...")
			var texture: Texture2D = ResourceLoader.load(image_path) as Texture2D
			if target_rect != null and texture != null:
				target_rect.texture = texture
				push_warning("_render_portrait: textura aplicada com sucesso")
			else:
				push_warning("_render_portrait: target_rect ou texture é null")
		else:
			push_warning("_render_portrait: arquivo NÃO existe: ", image_path)

	if target_label != null:
		target_label.text = str(char_data.get("name", ""))
		push_warning("_render_portrait: nome aplicado: ", target_label.text)


func _find_texture_rect(container: Node) -> TextureRect:
	for child in container.get_children():
		if child is TextureRect:
			return child
	return null


func _find_label(container: Node) -> Label:
	for child in container.get_children():
		if child is Label:
			return child
	return null


## Retorna os dados atuais do jogador
func get_player_data() -> Dictionary:
	return _player_data.duplicate()


## Retorna os dados atuais do inimigo
func get_enemy_data() -> Dictionary:
	return _enemy_data.duplicate()


## Define a fonte (paleta) dos retratos dinamicamente
func set_portrait_style(character_id: String, accent_color: Color) -> void:
	var target_portrait: Control = null

	if character_id == "player":
		target_portrait = player_portrait
	elif character_id == "enemy":
		target_portrait = enemy_portrait

	if target_portrait == null:
		return

	# Clean style without borders
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.227, 0.184, 0.125, 1)
	style.set_corner_radius_all(4)
	target_portrait.add_theme_stylebox_override("panel", style)
