extends Node

var current_dialogue_tree: Dictionary = {}
var current_node_id: String = ""

var dialogue_ui_scene: PackedScene = preload("res://scenes/ui/dialogue_ui.tscn")
var ui_instance = null

signal dialogue_finished()

func _ready() -> void:
	pass

func start_dialogue(tree: Dictionary, start_node: String = "start") -> void:
	current_dialogue_tree = tree
	current_node_id = start_node
	
	if ui_instance == null:
		ui_instance = dialogue_ui_scene.instantiate()
		get_tree().root.add_child(ui_instance)
		ui_instance.choice_selected.connect(_on_choice_selected)
		ui_instance.next_pressed.connect(_on_next_pressed)
	
	process_current_node()

func process_current_node() -> void:
	if not current_dialogue_tree.has(current_node_id):
		end_dialogue()
		return
		
	var node_data = current_dialogue_tree[current_node_id]
	
	var speaker = node_data.get("speaker", "Desconhecido")
	var text = node_data.get("text", "")
	var mood = node_data.get("mood", "Neutro")
	
	# portrait logic could load based on speaker name
	ui_instance.show_dialogue(speaker, text, null, mood)
	
	if node_data.has("options") and node_data["options"].size() > 0:
		ui_instance.show_choices(node_data["options"])

func _on_next_pressed() -> void:
	var node_data = current_dialogue_tree[current_node_id]
	if node_data.has("next_node"):
		current_node_id = node_data["next_node"]
		process_current_node()
	elif node_data.has("options") and node_data["options"].size() > 0:
		pass # Esperando escolha do jogador
	else:
		end_dialogue()

func _on_choice_selected(index: int) -> void:
	var node_data = current_dialogue_tree[current_node_id]
	var choice = node_data["options"][index]
	
	# Teste de Rolagem (Skill Check estilo D&D)
	if choice.has("skill_check"):
		var skill = choice["skill_check"]["skill"]
		var dc = choice["skill_check"]["dc"]
		var player_stat = GameState.attributes.get(skill, 10)
		
		var roll = randi() % 20 + 1
		var total = roll + player_stat
		var result_text = "\n[i][Rolagem " + skill.capitalize() + " (" + str(player_stat) + "): " + str(total) + " vs DC " + str(dc) + "][/i] "
		
		if total >= dc:
			ui_instance.history_label.text += result_text + "[color=green]SUCESSO[/color]"
			current_node_id = choice.get("success_node", choice.get("next_node", ""))
		else:
			ui_instance.history_label.text += result_text + "[color=red]FALHA[/color]"
			current_node_id = choice.get("failure_node", "")
			
		if current_node_id == "":
			end_dialogue()
			return
	else:
		if choice.has("next_node"):
			current_node_id = choice["next_node"]
		else:
			end_dialogue()
			return
			
	process_current_node()

func end_dialogue() -> void:
	if ui_instance:
		ui_instance.hide_dialogue()
	dialogue_finished.emit()
