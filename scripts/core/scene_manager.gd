# scene_manager.gd
# Gerenciador de cenas e transições
class_name SceneManager
extends Node

signal scene_changed(scene_path: String)
signal scene_loading_started
signal scene_loading_finished

var current_scene: Node = null
var is_loading: bool = false

func _ready() -> void:
	# Obter a cena raiz inicial
	current_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)

func load_scene(scene_path: String) -> void:
	if is_loading:
		push_warning("Uma cena já está sendo carregada.")
		return
	
	if not ResourceLoader.exists(scene_path):
		push_error("Cena não encontrada: " + scene_path)
		return
	
	is_loading = true
	scene_loading_started.emit()
	
	# Remover cena anterior
	if current_scene:
		current_scene.queue_free()
	
	# Carregar nova cena
	var scene = load(scene_path)
	if scene == null:
		push_error("Erro ao carregar cena: " + scene_path)
		is_loading = false
		return
	
	current_scene = scene.instantiate()
	get_tree().root.add_child(current_scene)
	
	is_loading = false
	scene_loading_finished.emit()
	scene_changed.emit(scene_path)

func get_current_scene() -> Node:
	return current_scene

func reload_current_scene() -> void:
	if current_scene:
		var scene_path = current_scene.scene_file_path
		load_scene(scene_path)
