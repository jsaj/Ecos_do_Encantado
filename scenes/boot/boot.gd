# boot.gd
# Script de inicialização do jogo
extends Node

func _ready() -> void:
	# Garantir que GameState, GameManager e SceneManager estão disponíveis
	if GameState == null:
		push_error("GameState não está carregado como autoload!")
		return
	
	if GameManager == null:
		push_error("GameManager não está carregado como autoload!")
		return
	
	if SceneManager == null:
		push_error("SceneManager não está carregado como autoload!")
		return
	
	# Inicializar GameState
	GameState.reset_game()
	
	# Ir para o Menu Principal
	await get_tree().process_frame
	SceneManager.load_scene(Constants.SCENE_MAIN_MENU)
