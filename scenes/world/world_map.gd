# world_map.gd
# Script do Mapa do Mundo (Placeholder)
extends Control

@onready var btn_voltar: Button = $CenterContainer/VBoxContainer/BtnVoltar
@onready var btn_teste: Button = $CenterContainer/VBoxContainer/BtnTesteDialogo

func _ready() -> void:
	print("WorldMap carregada com sucesso!")
	if btn_voltar:
		btn_voltar.pressed.connect(_on_voltar_pressed)
	if btn_teste:
		btn_teste.pressed.connect(_on_teste_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		_on_voltar_pressed()

func _on_voltar_pressed() -> void:
	GameManager.go_to_menu()

func _on_teste_pressed() -> void:
	var teste_dialogo = {
		"start": {
			"speaker": "Caipora",
			"text": "O caminho só se abre para aqueles que demonstram respeito pelas matas.",
			"options": [
				{"text": "Nós viemos em paz.", "next_node": "peace"},
				{"text": "Perguntar sobre a Iara e o Rio.", "skill_check": {"skill": "intellect", "dc": 10}, "success_node": "lore_success", "failure_node": "lore_fail"},
				{"text": "Eu não tenho tempo para isso. (Sair)", "next_node": "end"}
			]
		},
		"peace": {
			"speaker": "Caipora",
			"text": "Todos dizem isso. Mas suas ações dirão a verdade. Pode passar... por enquanto.",
			"options": [
				{"text": "Agradecer e partir.", "next_node": "end"}
			]
		},
		"lore_success": {
			"speaker": "Caipora",
			"text": "Você sabe sobre a oferenda das águas? Interessante... Talvez você não seja como os outros forasteiros.",
			"options": [
				{"text": "Continuar a jornada.", "next_node": "end"}
			]
		},
		"lore_fail": {
			"speaker": "Caipora",
			"text": "Iara? Do que você está falando? Claramente não entende as tradições. Afaste-se!",
			"options": [
				{"text": "Ir embora.", "next_node": "end"}
			]
		}
	}
	
	DialogueManager.start_dialogue(teste_dialogo)
