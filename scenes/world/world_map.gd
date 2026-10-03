# world_map.gd
# Script do Mapa do Mundo (Placeholder)
extends Control

func _ready() -> void:
	print("WorldMap carregada com sucesso!")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		GameManager.go_to_menu()
		get_tree().root.get_node("MainMenu").queue_free()
