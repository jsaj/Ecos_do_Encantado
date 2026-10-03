extends Node

## Captura a tela de batalha no tamanho real do viewport (1080x1920),
## independente do tamanho da janela do sistema.
##   godot --headless res://tests/screenshot.tscn
## Saida: user://battle_shot.png

func _ready() -> void:
	var scene: PackedScene = load("res://scenes/battle/battle.tscn")
	var screen: Control = scene.instantiate()

	var vp := SubViewport.new()
	vp.size = Vector2i(Constants.VIEWPORT_WIDTH, Constants.VIEWPORT_HEIGHT)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	vp.add_child(screen)

	for i in 8:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw

	var img := vp.get_texture().get_image()
	img.save_png("user://battle_shot.png")
	print("SAVED ", img.get_width(), "x", img.get_height())
	get_tree().quit(0)
