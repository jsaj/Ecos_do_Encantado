class_name SceneBackdrop
extends TextureRect

## Fundo de tela cheia para menus e cenas.
## Substitui um ColorRect solto: basta apontar `texture_path` para a imagem.
## A imagem cobre o painel inteiro sem deformar e pode ser escurecida para
## manter o texto legível.

## Caminho da imagem dentro de res:// (ex.: "res://assets/backgrounds/menu.png")
@export var texture_path: String = "":
	set(value):
		texture_path = value
		_refresh()

## Véu escuro sobre a imagem, de 0 (nenhum) a 1 (preto sólido).
@export_range(0.0, 1.0, 0.01) var dim_amount: float = 0.0:
	set(value):
		dim_amount = value
		_queue_dim()

@export var dim_color: Color = Color(0.02, 0.03, 0.02):
	set(value):
		dim_color = value
		_queue_dim()

var _dim: ColorRect

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS

	_dim = ColorRect.new()
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_dim)

	_refresh()
	_queue_dim()

func _refresh() -> void:
	if texture_path.is_empty() or not ResourceLoader.exists(texture_path):
		texture = null
		return
	var res := ResourceLoader.load(texture_path)
	texture = res if res is Texture2D else null

func _queue_dim() -> void:
	if _dim != null:
		_dim.queue_redraw()
		_dim.color = _veil()

func _veil() -> Color:
	var c := dim_color
	c.a = dim_amount
	return c