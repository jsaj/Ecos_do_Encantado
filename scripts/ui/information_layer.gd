class_name InformationLayer
extends Control

## Information Layer: Exibe abas de conteúdo (Mapa, Atributos, Missões, Dicas)
##
## Esta camada é completamente data-driven:
## - Não implementa lógica de jogo
## - Apenas renderiza dados fornecidos pelo controller
## - Emite sinais quando o usuário interage

signal tab_changed(tab_index: int)

const TAB_MAPA: int = 0
const TAB_ATRIBUTOS: int = 1
const TAB_MISSOES: int = 2
const TAB_DICAS: int = 3

@export var tab_container: TabContainer
@export var content_list: VBoxContainer

# Referências diretas dos nós da cena (para atribuição via inspector)
@export var _tab_container_node: TabContainer
@export var _content_list_node: VBoxContainer

var _current_tab: int = TAB_MAPA
var _tab_data: Dictionary = {}


func _ready() -> void:
	_resolve_references()
	
	if tab_container == null:
		# Fallback: sem abas, a camada funciona como uma lista simples.
		push_warning("InformationLayer: tab_container não foi atribuído")
		return

	_connect_tab_signals()
	_initialize_tabs()


## Resolve referências diretas dos nós da cena.
func _resolve_references() -> void:
	if tab_container == null:
		tab_container = _tab_container_node if _tab_container_node != null else find_child("TabContainer", true, false) as TabContainer
	if content_list == null:
		content_list = _content_list_node if _content_list_node != null else find_child("ContentList", true, false) as VBoxContainer


func _connect_tab_signals() -> void:
	if tab_container.tab_changed.is_connected(_on_tab_changed):
		return
	tab_container.tab_changed.connect(_on_tab_changed)


func _initialize_tabs() -> void:
	# As abas já existem na cena, apenas garantir que estão prontas.
	_current_tab = tab_container.current_tab
	_update_content_for_tab(_current_tab)


## API simples (skill §12): escreve itens na aba atualmente visível.
func update_content(items: Array[String]) -> void:
	_tab_data[_current_tab] = items
	_update_content_for_tab(_current_tab)


## Injeta dados para uma aba específica
func set_tab_content(tab_index: int, items: Array[String]) -> void:
	_tab_data[tab_index] = items
	if _current_tab == tab_index:
		_update_content_for_tab(tab_index)


## Injeta dados para múltiplas abas de uma vez.
## Aceita as chaves por aba (mapa/atributos/missoes/dicas) e também a chave
## genérica "items", aplicada à aba atual.
func inject_data(data: Dictionary) -> void:
	if data.has("mapa") and data["mapa"] is Array:
		set_tab_content(TAB_MAPA, _to_string_array(data["mapa"]))

	if data.has("atributos") and data["atributos"] is Array:
		set_tab_content(TAB_ATRIBUTOS, _to_string_array(data["atributos"]))

	if data.has("missoes") and data["missoes"] is Array:
		set_tab_content(TAB_MISSOES, _to_string_array(data["missoes"]))

	if data.has("dicas") and data["dicas"] is Array:
		set_tab_content(TAB_DICAS, _to_string_array(data["dicas"]))

	if data.has("items") and data["items"] is Array:
		update_content(_to_string_array(data["items"]))


## Converte um Array heterogêneo vindo do backend em Array[String].
func _to_string_array(source: Array) -> Array[String]:
	var result: Array[String] = []
	for item in source:
		result.append(str(item))
	return result


## Limpa o conteúdo de uma aba
func clear_tab_content(tab_index: int) -> void:
	_tab_data.erase(tab_index)
	if _current_tab == tab_index:
		_clear_content_list()


## Limpa todos os conteúdos
func clear_all() -> void:
	_tab_data.clear()
	_clear_content_list()


func _on_tab_changed(tab_index: int) -> void:
	_current_tab = tab_index
	_update_content_for_tab(tab_index)
	tab_changed.emit(tab_index)


func _update_content_for_tab(tab_index: int) -> void:
	_clear_content_list()

	if not _tab_data.has(tab_index):
		return

	_render_items(_tab_data[tab_index])


func _clear_content_list() -> void:
	if content_list == null:
		return

	for child in content_list.get_children():
		child.queue_free()


func _render_items(items: Array[String]) -> void:
	if content_list == null:
		return

	for item_text in items:
		var label := Label.new()
		label.text = item_text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color(0.91, 0.863, 0.753, 1))
		label.custom_minimum_size.y = 0
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		content_list.add_child(label)


## Obtém o índice da aba atual
func get_current_tab() -> int:
	return _current_tab


## Define a aba ativa programaticamente
func set_active_tab(tab_index: int) -> void:
	if tab_container != null and tab_index >= 0 and tab_index < tab_container.get_tab_count():
		tab_container.current_tab = tab_index