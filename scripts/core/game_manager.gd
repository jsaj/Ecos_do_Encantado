# game_manager.gd
# Gerenciador central do jogo
extends Node

signal game_started
signal game_paused
signal game_resumed
signal game_ended

var is_paused: bool = false

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("cancel"):
		return
	var current := SceneManager.get_current_scene()
	if current is MainExplorationUI or current is XilogravuraReliquary:
		return
	if not is_paused:
		pause_game()
	else:
		resume_game()

func pause_game() -> void:
	if not is_paused:
		is_paused = true
		get_tree().paused = true
		game_paused.emit()

func resume_game() -> void:
	if is_paused:
		is_paused = false
		get_tree().paused = false
		game_resumed.emit()

func start_new_game() -> void:
	GameState.reset_game()
	game_started.emit()
	SceneManager.load_scene("res://scenes/world/world_map.tscn")

func load_game() -> void:
	# Será implementado na FASE 13 (Save System)
	game_started.emit()
	SceneManager.load_scene("res://scenes/world/world_map.tscn")

func quit_game() -> void:
	game_ended.emit()
	get_tree().quit()

func go_to_menu() -> void:
	SceneManager.load_scene("res://scenes/menu/main_menu.tscn")

func advance_time(minutes: int) -> void:
	GameState.time["minute"] += minutes
	while GameState.time["minute"] >= 60:
		GameState.time["minute"] -= 60
		GameState.time["hour"] += 1
		
	while GameState.time["hour"] >= 24:
		GameState.time["hour"] -= 24
		GameState.time["day"] += 1
