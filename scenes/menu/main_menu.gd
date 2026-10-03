# main_menu.gd
# Script do Menu Principal
extends Control

@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var battle_button: Button = $VBoxContainer/BattleButton

func _ready() -> void:
	# Conectar sinais dos botões
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	battle_button.pressed.connect(_on_battle_pressed)
	
	# "Continuar" desabilitado por enquanto (FASE 13)
	continue_button.disabled = true
	settings_button.disabled = true

func _on_new_game_pressed() -> void:
	GameManager.start_new_game()

func _on_continue_pressed() -> void:
	GameManager.load_game()

func _on_settings_pressed() -> void:
	push_warning("Configurações não implementadas ainda.")

func _on_quit_pressed() -> void:
	GameManager.quit_game()

# Atalho de desenvolvimento: abre a tela de batalha sem passar pelo mundo.
func _on_battle_pressed() -> void:
	GameState.combat_state["in_combat"] = true
	SceneManager.load_scene(Constants.SCENE_BATTLE)
