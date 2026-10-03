class_name MainBattleUI
extends Control

## Main Battle UI Controller
##
## Responsabilidades:
## - Recebe dados do backend
## - Distribui dados para as camadas de visualização
## - Conecta sinais das camadas
## - Encaminha ações do usuário de volta ao backend
##
## NUNCA implementa:
## - Lógica de jogo
## - Cálculos de dano
## - Progressão de personagem
## - Lógica de quests
## - Decisões de estado
##
## Godot é apenas uma camada de apresentação dumb.

signal action_received(action_type: String, data: Dictionary)
signal tab_changed(tab_index: int)

# Referências às camadas
@export var background_layer: TextureRect
@export var character_layer: CharacterLayer
@export var status_layer: StatusLayer
@export var information_layer: InformationLayer
@export var action_layer: ActionLayer

# Referências diretas dos nós da cena (para atribuição via inspector)
@export var _background_layer_node: TextureRect
@export var _character_layer_node: CharacterLayer
@export var _status_layer_node: StatusLayer
@export var _information_layer_node: InformationLayer
@export var _action_layer_node: ActionLayer

# Estado interno (apenas para coordenação de UI, NÃO lógica de jogo)
var _ui_state: Dictionary = {}


func _ready() -> void:
	_setup_references()
	_connect_signals()
	
	push_warning("=== MAIN_BATTLE_UI READY ===")
	push_warning("background_layer = ", background_layer)
	push_warning("character_layer = ", character_layer)
	push_warning("status_layer = ", status_layer)
	push_warning("information_layer = ", information_layer)
	push_warning("action_layer = ", action_layer)
	
	# TESTE: usa asset existente
	inject_data({
		"background": {"image_path": "res://assets/backgrounds/bg_front_game.png"},
		"player": {"name": "Teste", "image_path": "res://assets/characters/luana.png"},
		"enemy": {"name": "Inimigo", "image_path": "res://assets/characters/luana.png"},
		"status": {"hp": 50, "max_hp": 100, "mp": 10, "max_mp": 20, "stats_text": "TESTE"},
		"information": {"mapa": [], "atributos": [], "missoes": [], "dicas": []},
		"actions": [
			{
				"label": "Atacar",
				"accent_color": Color(1, 0.5, 0.2),
				"frame_path": "res://assets/ui/option_moldure.png",
				"action_id": "attack"
			},
			{
				"label": "Habilidades",
				"accent_color": Color(0.5, 0.8, 0.3),
				"frame_path": "res://assets/ui/option_moldure.png",
				"action_id": "skills"
			},
			{
				"label": "Itens",
				"accent_color": Color(0.3, 0.7, 1),
				"frame_path": "res://assets/ui/option_moldure.png",
				"action_id": "items"
			},
			{
				"label": "Navegar",
				"accent_color": Color(0.8, 0.5, 0.8),
				"frame_path": "res://assets/ui/option_moldure.png",
				"action_id": "navigate"
			}
		]
	})


## Garante que todas as referências estão válidas
func _setup_references() -> void:
	if background_layer == null:
		background_layer = _background_layer_node if _background_layer_node != null else find_child("BackgroundLayer", true, false) as TextureRect

	if character_layer == null:
		character_layer = _character_layer_node if _character_layer_node != null else find_child("CharacterLayer", true, false) as CharacterLayer

	if status_layer == null:
		status_layer = _status_layer_node if _status_layer_node != null else find_child("StatusLayer", true, false) as StatusLayer

	if information_layer == null:
		information_layer = _information_layer_node if _information_layer_node != null else find_child("InformationLayer", true, false) as InformationLayer

	if action_layer == null:
		action_layer = _action_layer_node if _action_layer_node != null else find_child("ActionLayer", true, false) as ActionLayer


## Conecta os sinais das camadas
func _connect_signals() -> void:
	if action_layer != null:
		if not action_layer.action_requested.is_connected(_on_action_requested):
			action_layer.action_requested.connect(_on_action_requested)

	if information_layer != null:
		if not information_layer.tab_changed.is_connected(_on_tab_changed):
			information_layer.tab_changed.connect(_on_tab_changed)


## Injeta dados completos na UI (skill §15).
## Distribui o contrato do backend sem interpretar o significado do jogo.
func inject_data(data: Dictionary) -> void:
	if data.has("background") and data["background"] is Dictionary:
		set_background(data["background"])

	_inject_characters(data)

	if data.has("status") and data["status"] is Dictionary:
		if status_layer != null:
			status_layer.update_status(data["status"])

	if data.has("information") and data["information"] is Dictionary:
		if information_layer != null:
			information_layer.inject_data(data["information"])

	if data.has("actions") and data["actions"] is Array:
		if action_layer != null:
			action_layer.inject_actions(data["actions"])


## Aceita tanto "player"/"enemy" no topo quanto "characters": {player, enemy}.
func _inject_characters(data: Dictionary) -> void:
	if character_layer == null:
		return

	var player_data: Dictionary = {}
	var enemy_data: Dictionary = {}

	if data.has("characters") and data["characters"] is Dictionary:
		var characters: Dictionary = data["characters"]
		if characters.has("player") and characters["player"] is Dictionary:
			player_data = characters["player"]
		if characters.has("enemy") and characters["enemy"] is Dictionary:
			enemy_data = characters["enemy"]
	else:
		if data.has("player") and data["player"] is Dictionary:
			player_data = data["player"]
		if data.has("enemy") and data["enemy"] is Dictionary:
			enemy_data = data["enemy"]

	if not player_data.is_empty() or not enemy_data.is_empty():
		character_layer.update_characters(player_data, enemy_data)


## Atualiza o fundo (skill §8). Caminho vazio ou inválido é ignorado.
func set_background(bg_data: Dictionary) -> void:
	push_warning("set_background chamado com: ", bg_data)
	if background_layer == null:
		push_warning("set_background: background_layer é NULL!")
		return

	var image_path: String = str(bg_data.get("image_path", ""))
	push_warning("set_background: image_path = ", image_path)
	if image_path.is_empty() or not ResourceLoader.exists(image_path):
		push_warning("set_background: caminho vazio ou arquivo não existe")
		return

	var texture: Texture2D = ResourceLoader.load(image_path) as Texture2D
	push_warning("set_background: texture carregada = ", texture)
	if texture != null:
		background_layer.texture = texture
		push_warning("set_background: textura aplicada ao background_layer")
	else:
		push_warning("set_background: texture é NULL após load")


## Atualiza apenas o status de um personagem
func update_character_status(character_id: String, status_data: Dictionary) -> void:
	if status_layer == null:
		return

	# A camada de status exibe um único conjunto de valores por vez.
	status_layer.update_status(status_data)


## Atualiza o conteúdo de uma aba específica
func update_tab_content(tab_index: int, items: Array[String]) -> void:
	if information_layer == null:
		return

	information_layer.set_tab_content(tab_index, items)


## Habilita ou desabilita as ações do usuário
func set_ui_enabled(enabled: bool) -> void:
	if action_layer != null:
		action_layer.set_actions_enabled(enabled)


## Recebe um sinal de ação do usuário e o encaminha ao backend.
## Não existe lógica de jogo aqui: apenas roteia o pedido.
func _on_action_requested(action_id: String) -> void:
	var action_data: Dictionary = {
		"action_id": action_id,
		"timestamp": Time.get_ticks_msec(),
		"source": "action_layer"
	}

	action_received.emit(action_id, action_data)


## Recebe notificação de mudança de aba
func _on_tab_changed(tab_index: int) -> void:
	tab_changed.emit(tab_index)


## Limpa toda a UI
func clear_all() -> void:
	if background_layer != null:
		background_layer.texture = null

	if character_layer != null:
		character_layer.clear()

	if information_layer != null:
		information_layer.clear_all()

	if action_layer != null:
		action_layer.inject_actions([])


## Retorna o estado atual da UI (apenas para debug/save)
func get_ui_state() -> Dictionary:
	return _ui_state.duplicate()




## Exemplo de contrato de dados esperado do backend:
##
## {
##     "background": {
##         "image_path": "res://assets/backgrounds/example.webp"
##     },
##
##     "player": {
##         "name": "...",
##         "image_path": "res://assets/characters/example.webp"
##     },
##
##     "enemy": {
##         "name": "...",
##         "image_path": "res://assets/enemies/example.webp"
##     },
##
##     "status": {
##         "hp": 80,
##         "max_hp": 100,
##         "mp": 20,
##         "max_mp": 30,
##         "stamina": 15,
##         "max_stamina": 20,
##         "stats_text": "..."
##     },
##
##     "information": {
##         "mapa": ["..."],
##         "atributos": ["..."],
##         "missoes": ["..."],
##         "dicas": ["..."]
##     },
##
##     "actions": [
##         {
##             "label": "...",
##             "accent_color": Color(1, 1, 1),
##             "icon_path": "res://assets/icons/example.png",
##             "action_id": "attack"
##         }
##     ]
## }
##
## A forma aninhada "characters": {"player": ..., "enemy": ...} também é aceita.
