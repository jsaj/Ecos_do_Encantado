class_name PortraitSlot
extends PanelContainer

## Moldura de retrato quadrada com placeholder.
## Quando `texture_path` aponta para um arquivo existente, usa a arte final;
## caso contrário, desenha uma silhueta estilizada como marcador de posição.

@export var texture_path: String = "":
	set(value):
		texture_path = value
		_refresh()

var _rect: TextureRect
var _draw_rect: Control
var _accent: Color = BattleTheme.BORDER_METAL_DIM

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# O retrato nunca deve esticar: tamanho fixo, centralizado na célula
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	custom_minimum_size = Vector2(56, 56)

func _ready() -> void:
	# Clean panel without borders
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = BattleTheme.WOOD_DARK
	panel_style.set_corner_radius_all(6)
	add_theme_stylebox_override("panel", panel_style)

	# Container de área única: o desenho e a textura dividem exatamente o
	# mesmo retangulo, evitando que a silhueta fique maior que a moldura.
	var holder := Control.new()
	holder.custom_minimum_size = Vector2(56, 56)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.resized.connect(_sync_children)
	add_child(holder)

	_draw_rect = Control.new()
	_draw_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_draw_rect.draw.connect(_draw_placeholder)
	holder.add_child(_draw_rect)

	_rect = TextureRect.new()
	_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(_rect)

	_refresh()
	_sync_children()

func _sync_children() -> void:
	if _draw_rect == null:
		return
	var holder := _draw_rect.get_parent() as Control
	if holder == null:
		return
	var s: Vector2 = holder.size
	_draw_rect.position = Vector2.ZERO
	_draw_rect.size = s
	_rect.position = Vector2.ZERO
	_rect.size = s
	_draw_rect.queue_redraw()

func set_accent(color: Color) -> void:
	_accent = color
	if is_node_ready():
		# Clean panel without borders
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = BattleTheme.WOOD_DARK
		panel_style.set_corner_radius_all(6)
		add_theme_stylebox_override("panel", panel_style)
		_sync_children()

func set_portrait_size(pixels: int) -> void:
	custom_minimum_size = Vector2(pixels, pixels)
	if _draw_rect == null:
		return
	var holder := _draw_rect.get_parent()
	if holder is Control:
		(holder as Control).custom_minimum_size = Vector2(pixels, pixels)
	_sync_children()

func _refresh() -> void:
	if _rect == null:
		return
	if texture_path.is_empty() or not ResourceLoader.exists(texture_path):
		_rect.texture = null
		_draw_rect.visible = true
		_draw_rect.queue_redraw()
	else:
		var res := ResourceLoader.load(texture_path)
		_rect.texture = res if res is Texture2D else null
		_draw_rect.visible = _rect.texture == null

## Marcador de posição: silhueta com moldura, substituível pela arte final.
func _draw_placeholder() -> void:
	var s := _draw_rect.size
	if s.x <= 0.0 or s.y <= 0.0:
		return
	var r := Rect2(Vector2.ZERO, s)
	var accent := Color(_accent.r, _accent.g, _accent.b, 0.9)

	_draw_rect.draw_rect(r, Color(0.09, 0.07, 0.04, 0.92), true)

	var head_r := s.x * 0.17
	var head_center := Vector2(s.x * 0.5, s.y * 0.3)
	_draw_rect.draw_circle(head_center, head_r, accent)

	# Ombros: trapézio simplificado a partir de um retangulo com topo estreito
	var shoulder_top := head_center.y + head_r * 1.3
	var body := PackedVector2Array([
		Vector2(s.x * 0.22, s.y * 0.86),
		Vector2(s.x * 0.34, shoulder_top),
		Vector2(s.x * 0.66, shoulder_top),
		Vector2(s.x * 0.78, s.y * 0.86),
	])
	_draw_rect.draw_colored_polygon(body, accent)

	# Removed border line