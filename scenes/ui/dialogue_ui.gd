extends CanvasLayer
class_name DialogueUI

@onready var portrait_rect = $Control/Margin/Columns/LeftCol/PortraitPanel/Margin/VBox/Portrait
@onready var name_label = $Control/Margin/Columns/LeftCol/PortraitPanel/Margin/VBox/NameLabel
@onready var mood_label = $Control/Margin/Columns/LeftCol/PortraitPanel/Margin/VBox/MoodLabel

@onready var text_label = $Control/Margin/Columns/CenterCol/TextPanel/Margin/TextLabel
@onready var next_button = $Control/Margin/Columns/CenterCol/TextPanel/NextButton
@onready var choices_container = $Control/Margin/Columns/CenterCol/ChoicesPanel/Margin/Scroll/ChoicesContainer

@onready var history_label = $Control/Margin/Columns/RightCol/HistoryPanel/Margin/VBox/ScrollHistory/HistoryLabel

signal choice_selected(index: int)
signal next_pressed()

# Premium styleboxes setup via code for buttons
var style_normal: StyleBoxFlat
var style_hover: StyleBoxFlat

func _ready() -> void:
	next_button.pressed.connect(func(): next_pressed.emit())
	history_label.text = ""
	
	style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.15, 0.15, 0.18, 1)
	style_normal.border_color = Color(0.3, 0.3, 0.3, 1)
	style_normal.border_width_bottom = 1
	style_normal.border_width_top = 1
	style_normal.border_width_left = 1
	style_normal.border_width_right = 1
	style_normal.corner_radius_bottom_left = 4
	style_normal.corner_radius_bottom_right = 4
	style_normal.corner_radius_top_left = 4
	style_normal.corner_radius_top_right = 4
	
	style_hover = style_normal.duplicate()
	style_hover.bg_color = Color(0.25, 0.25, 0.3, 1)
	style_hover.border_color = Color(0.8, 0.7, 0.3, 1)

func show_dialogue(character_name: String, text: String, portrait: Texture2D = null, mood: String = "Neutro") -> void:
	self.show()
	name_label.text = character_name
	mood_label.text = "[Mood: " + mood + "]"
	
	# If text is an internal thought, we can format it differently
	if character_name == "Internal Thought" or character_name == "Pensamento":
		text_label.text = "[i][color=#80b3ff]" + text + "[/color][/i]"
	else:
		text_label.text = text
		
	if portrait:
		portrait_rect.texture = portrait
		portrait_rect.show()
	else:
		portrait_rect.hide()
		
	clear_choices()
	next_button.show()
	
	history_label.text += "\n\n[b][color=#e6c34c]" + character_name + ":[/color][/b] " + text

func show_choices(choices: Array) -> void:
	clear_choices()
	next_button.hide()
	for i in range(choices.size()):
		var choice_data = choices[i]
		var btn = Button.new()
		
		var btn_text = choice_data.get("text", "Opção")
		
		if choice_data.has("skill_check"):
			var skill = choice_data["skill_check"].get("skill", "atributo")
			btn_text = "[color=#4da6ff][" + skill.capitalize() + " Check][/color] " + btn_text
			
		btn.text = btn_text
		btn.add_theme_font_size_override("font_size", 20)
		btn.custom_minimum_size = Vector2(0, 55)
		
		btn.add_theme_stylebox_override("normal", style_normal)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_stylebox_override("pressed", style_hover)
		btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		btn.add_theme_color_override("font_hover_color", Color(1, 0.9, 0.5))
		
		# Habilitar bbcode no botão nativo não é fácil, então usaremos rich text dentro do botão
		# Para manter simples, formataremos sem bbcode no botão, só cor base via theme.
		if choice_data.has("skill_check"):
			var skill = choice_data["skill_check"].get("skill", "atributo")
			btn.text = "[" + skill.capitalize() + " Check] " + choice_data.get("text", "")
		else:
			btn.text = choice_data.get("text", "")
		
		btn.pressed.connect(func(): _on_choice_pressed(i))
		choices_container.add_child(btn)

func clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()

func _on_choice_pressed(index: int) -> void:
	clear_choices()
	choice_selected.emit(index)

func hide_dialogue() -> void:
	self.hide()
