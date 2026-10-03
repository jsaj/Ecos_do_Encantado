class_name BattleStageArt
extends Control

## Marcador do cenário de batalha.
## Enquanto a arte final (floresta tropical, personagens, fogueira) não
## existir em assets/, esta classe desenha um cenário provisório com as
## mesmas regiões de arte, para validar o layout.
## Basta preencher StageTexture com a imagem final e o desenho some.

## Caminho da imagem final do cenário, dentro de res://
## (ex.: "res://assets/backgrounds/battle_forest.png").
## Vazio = desenha o cenário provisório.
@export var stage_texture_path: String = "":
	set(value):
		stage_texture_path = value
		queue_redraw()

## Como a imagem é encaixada no painel:
## STRETCH  - deforma até preencher (ignora a proporção)
## KEEP_ASPECT_COVERED - preenche cortando o excedente (recomendado para fundos)
## KEEP_ASPECT        - encaixa inteira, deixando bordas
enum Fit {
	STRETCH,
	KEEP_ASPECT_COVERED,
	KEEP_ASPECT,
}

@export var fit: Fit = Fit.KEEP_ASPECT_COVERED:
	set(value):
		fit = value
		queue_redraw()

## Escurece a imagem para o texto da UI continuar legível por cima.
@export_range(0.0, 1.0, 0.01) var dim_amount: float = 0.0:
	set(value):
		dim_amount = value
		queue_redraw()

@export var dim_color: Color = Color(0.02, 0.03, 0.02):
	set(value):
		dim_color = value
		queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	resized.connect(queue_redraw)
	queue_redraw()

func _draw() -> void:
	var tex := _load_texture(stage_texture_path)
	if tex != null:
		_draw_texture(tex)
		return
	_draw_placeholder_forest()
	_draw_placeholder_fire()
	_draw_placeholder_figure(Rect2(size.x * 0.16, size.y * 0.22, size.x * 0.2, size.y * 0.62), Color("d0872a"))
	_draw_placeholder_figure(Rect2(size.x * 0.64, size.y * 0.24, size.x * 0.2, size.y * 0.6), Color("c0392b"))

## Desenha a imagem respeitando a proporção e, se dim_amount > 0, aplica
## um véu escuro por cima.
func _draw_texture(tex: Texture2D) -> void:
	var target := _fit_rect(tex)
	draw_texture_rect(tex, target, false)

	if dim_amount > 0.0:
		var veil := dim_color
		veil.a = dim_amount
		draw_rect(Rect2(Vector2.ZERO, size), veil, true)

func _fit_rect(tex: Texture2D) -> Rect2:
	var full := Rect2(Vector2.ZERO, size)
	if fit == Fit.STRETCH or size.x <= 0.0 or size.y <= 0.0:
		return full

	var tex_size := tex.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return full

	var scale := size / tex_size
	match fit:
		Fit.KEEP_ASPECT:
			var s := minf(scale.x, scale.y)
			var drawn := tex_size * s
			return Rect2((size - drawn) * 0.5, drawn)
		_:
			# KEEP_ASPECT_COVERED
			var s2 := maxf(scale.x, scale.y)
			var drawn2 := tex_size * s2
			return Rect2((size - drawn2) * 0.5, drawn2)

func _draw_placeholder_forest() -> void:
	var w := size.x
	var h := size.y
	# Céu / dossel
	draw_rect(Rect2(0, 0, w, h * 0.45), Color(0.075, 0.13, 0.086), true)
	# Chão de terra
	draw_rect(Rect2(0, h * 0.62, w, h * 0.38), Color(0.216, 0.161, 0.098), true)
	draw_rect(Rect2(0, h * 0.6, w, h * 0.05), Color(0.153, 0.227, 0.129), true)
	# Troncos
	for i in 5:
		var x := w * (0.08 + 0.21 * i)
		draw_rect(Rect2(x, 0, w * 0.035, h * 0.72), Color(0.161, 0.114, 0.071), true)
	# Copa
	for i in 5:
		var cx := w * (0.08 + 0.21 * i) + w * 0.017
		draw_circle(Vector2(cx, h * 0.14), w * 0.13, Color(0.086, 0.176, 0.098))
		draw_circle(Vector2(cx - w * 0.06, h * 0.2), w * 0.09, Color(0.114, 0.22, 0.118))
	# Bromélias / samambaias nas bordas
	for i in 8:
		var bx := w * (0.03 + 0.13 * i)
		_draw_leaf(Vector2(bx, h * 0.95), w * 0.09, Color(0.157, 0.31, 0.149))
		_draw_leaf(Vector2(w - bx, h * 0.9), w * 0.08, Color(0.18, 0.35, 0.16))
	# Borda interna para leitura do painel
	draw_rect(Rect2(0, 0, w, h), Color(0.353, 0.275, 0.149, 0.9), false, 3.0)

func _draw_leaf(base: Vector2, length: float, color: Color) -> void:
	for i in 5:
		var angle := lerpf(-1.9, -0.4, float(i) / 4.0)
		var tip := base + Vector2(cos(angle), sin(angle)) * length
		var mid := (base + tip) * 0.5 + Vector2(0, -length * 0.18)
		var prev_p: Vector2 = base
		for step in range(1, 7):
			var t := float(step) / 6.0
			var p := _quad_bezier(base, mid, tip, t)
			prev_p = _quad_bezier(base, mid, tip, maxf(t - 0.16, 0.0))
			draw_line(prev_p, p, color, 5.0)
		draw_line(base, tip, color.darkened(0.2), 3.0)

func _quad_bezier(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	return a.lerp(b, t).lerp(b.lerp(c, t), t)

func _draw_placeholder_fire() -> void:
	var center := size * Vector2(0.5, 0.66)
	# Lenha
	draw_line(center + Vector2(-40, 22), center + Vector2(40, 22), Color(0.35, 0.22, 0.12), 9.0)
	draw_line(center + Vector2(-34, 12), center + Vector2(34, 30), Color(0.3, 0.19, 0.1), 7.0)
	# Chama
	draw_circle(center + Vector2(0, -6), size.x * 0.045, Color(0.878, 0.478, 0.149, 0.9))
	draw_circle(center + Vector2(0, 4), size.x * 0.03, Color(0.98, 0.78, 0.3, 0.95))

func _draw_placeholder_figure(rect: Rect2, color: Color) -> void:
	# Sombra no chão para ancorar o personagem
	draw_rect(
		Rect2(rect.position + Vector2(rect.size.x * 0.05, rect.size.y * 0.94), Vector2(rect.size.x * 0.9, rect.size.y * 0.06)),
		Color(0, 0, 0, 0.35), true
	)
	draw_rect(rect, Color(color.r, color.g, color.b, 0.18), true)
	draw_rect(rect, Color(color.r, color.g, color.b, 0.85), false, 2.0)
	# Label substituível
	var font := ThemeDB.fallback_font
	if font == null:
		return
	var text := "ARTE"
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16)
	draw_string(
		font,
		rect.position + (rect.size - text_size) * 0.5,
		text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color
	)

func _load_texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var res := ResourceLoader.load(path)
	return res if res is Texture2D else null
