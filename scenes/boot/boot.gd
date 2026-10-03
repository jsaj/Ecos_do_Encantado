# boot.gd
# Script de inicialização do jogo
extends Node

## Cena de entrada (res://main.tscn). Não cria nenhum nó visível: apenas
## valida os autoloads, prepara o estado e entrega o controle ao SceneManager.
## A troca de cena é adiada com call_deferred porque change_scene_to_file()
## libera a cena atual — ou seja, este próprio nó — durante o _ready().

func _ready() -> void:
	# Os autoloads são nós do SceneTree: nunca são null, mas podem não estar
	# registrados se o projeto for executado sem o project.godot correto.
	var missing: Array[String] = []
	for autoload_name in ["Constants", "GameState", "GameManager", "SceneManager"]:
		if not get_node_or_null("/root/" + autoload_name):
			missing.append(autoload_name)

	if not missing.is_empty():
		push_error("Boot: autoloads ausentes: " + ", ".join(missing))
		push_error("Boot: verifique a seção [autoload] do project.godot.")
		return

	GameState.reset_game()

	# Deferido: fora do _ready a cena ainda pode ser liberada com segurança.
	call_deferred("_goto_main_menu")

func _goto_main_menu() -> void:
	if not ResourceLoader.exists(Constants.SCENE_MAIN_MENU):
		push_error("Boot: cena do menu não encontrada em " + Constants.SCENE_MAIN_MENU)
		return
	SceneManager.load_scene(Constants.SCENE_MAIN_MENU)
