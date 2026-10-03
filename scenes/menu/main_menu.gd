# main_menu.gd
# Script do Menu Principal
extends Control

@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	# Conectar sinais dos botões
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# "Continuar" desabilitado por enquanto (FASE 13)
	continue_button.disabled = true
	settings_button.disabled = true

func _on_new_game_pressed() -> void:
	GameManager.start_new_game()

func _on_continue_pressed() -> void:
	GameManager.load_game()

func _on_settings_pressed() -> void:
	push_info("Configurações não implementadas ainda.")

func _on_quit_pressed() -> void:
	GameManager.quit_game()
