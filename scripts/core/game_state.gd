# game_state.gd
# Armazena o estado global do jogo
class_name GameState
extends Node

# Dados do Jogador
var player: Dictionary = {
	"name": "Aventureiro",
	"hp": 100,
	"max_hp": 100,
	"energy": 20,
	"max_energy": 20,
	"gold": 25,
	"level": 1,
	"xp": 0,
	"xp_next_level": 100,
}

var attributes: Dictionary = {
	"force": 10,      # FOR
	"dexterity": 10,  # DES
	"intellect": 10,  # INT
	"vigor": 10,      # VIG
	"luck": 10,       # SORTE
	"spirit": 10,     # ESP
}

var inventory: Array[String] = []
var equipment: Dictionary = {
	"weapon": null,
	"armor": null,
	"accessory": null,
}

var party: Array[String] = []

# Progressão e Mundo
var current_region: String = ""
var current_scene: String = ""
var current_quest: String = ""

# Sistema de Flags
var flags: Dictionary = {}

# Sistema de Escolhas
var choices_made: Array[String] = []

# Sistema de Karma
var karma: int = 0

# Progressão geral
var progression: Dictionary = {
	"regions_discovered": [],
	"enemies_defeated": [],
	"npcs_met": [],
	"quests_completed": [],
}

# Estado de combate
var combat_state: Dictionary = {
	"in_combat": false,
	"current_enemy": null,
	"turn_count": 0,
}

func _ready() -> void:
	pass

# Funções de Utilidade
func reset_game() -> void:
	player = {
		"name": "Aventureiro",
		"hp": 100,
		"max_hp": 100,
		"energy": 20,
		"max_energy": 20,
		"gold": 25,
		"level": 1,
		"xp": 0,
		"xp_next_level": 100,
	}
	attributes = {
		"force": 10,
		"dexterity": 10,
		"intellect": 10,
		"vigor": 10,
		"luck": 10,
		"spirit": 10,
	}
	inventory = []
	equipment = {
		"weapon": null,
		"armor": null,
		"accessory": null,
	}
	party = []
	current_region = ""
	current_scene = ""
	current_quest = ""
	flags = {}
	choices_made = []
	karma = 0
	progression = {
		"regions_discovered": [],
		"enemies_defeated": [],
		"npcs_met": [],
		"quests_completed": [],
	}
	combat_state = {
		"in_combat": false,
		"current_enemy": null,
		"turn_count": 0,
	}

func set_flag(flag_name: String, value: bool) -> void:
	flags[flag_name] = value

func get_flag(flag_name: String) -> bool:
	return flags.get(flag_name, false)

func add_gold(amount: int) -> void:
	player["gold"] += amount

func subtract_gold(amount: int) -> bool:
	if player["gold"] >= amount:
		player["gold"] -= amount
		return true
	return false

func add_xp(amount: int) -> void:
	player["xp"] += amount
	if player["xp"] >= player["xp_next_level"]:
		level_up()

func level_up() -> void:
	player["level"] += 1
	player["xp"] -= player["xp_next_level"]
	player["xp_next_level"] = int(player["xp_next_level"] * 1.1)
	player["max_hp"] += 10
	player["hp"] = player["max_hp"]
