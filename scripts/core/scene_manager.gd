# scene_manager.gd
# Gerenciador de cenas e transições
extends Node

signal scene_changed(scene_path: String)
signal scene_loading_started
signal scene_loading_finished

var current_scene: Node = null
var is_loading: bool = false

func _ready() -> void:
	await get_tree().process_frame
	current_scene = get_tree().current_scene

## Troca a cena ativa. Protegida contra reentrância e contra uma cena que
## já foi liberada por outra via enquanto o frame ainda não fechou.
func load_scene(scene_path: String) -> void:
	if is_loading:
		push_warning("SceneManager: uma cena já está sendo carregada.")
		return

	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		push_error("SceneManager: cena não encontrada: " + scene_path)
		return

	is_loading = true
	scene_loading_started.emit()

	# A troca em si precisa ficar em um frame limpo: chamar change_scene_to_file
	# durante o _ready de outra cena pode liberar esse nó no meio do sinal.
	# Também garante que a cena antiga já saiu da árvore antes de inspecioná-la.
	var error: int = await _change_scene_deferred(scene_path)
	if error != OK:
		push_error("SceneManager: falha ao carregar %s (código %d)" % [scene_path, error])
		is_loading = false
		scene_loading_finished.emit()
		return

	await get_tree().process_frame

	current_scene = get_tree().current_scene
	is_loading = false
	scene_loading_finished.emit()
	scene_changed.emit(scene_path)

func _change_scene_deferred(scene_path: String) -> int:
	var result: Array[int] = [OK]
	await get_tree().process_frame
	result[0] = get_tree().change_scene_to_file(scene_path)
	return result[0]

func get_current_scene() -> Node:
	if is_instance_valid(current_scene):
		return current_scene
	return get_tree().current_scene

func reload_current_scene() -> void:
	var scene := get_current_scene()
	if scene == null:
		return
	var scene_path := scene.scene_file_path
	if scene_path.is_empty():
		get_tree().reload_current_scene()
	else:
		load_scene(scene_path)