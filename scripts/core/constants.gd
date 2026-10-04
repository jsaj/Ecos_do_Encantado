# constants.gd
# Constantes globais do jogo
extends Node

# Cenas
const SCENE_BOOT = "res://scenes/boot/boot.tscn"
const SCENE_MAIN_MENU = "res://scenes/menu/main_menu.tscn"
const SCENE_WORLD_MAP = "res://scenes/world/world_map.tscn"
const SCENE_EXPLORATION = "res://scenes/exploration/exploration.tscn"
const SCENE_DIALOGUE = "res://scenes/dialogue/dialogue.tscn"
const SCENE_BATTLE = "res://scenes/battle/battle.tscn"
const SCENE_INVENTORY = "res://scenes/inventory/inventory.tscn"
const SCENE_CHARACTER = "res://scenes/character/character.tscn"
const SCENE_XILOGRAVURA_RELIQUARY = "res://scenes/ui/xilogravura_reliquary.tscn"
const SCENE_GAME_OVER = "res://scenes/game_over/game_over.tscn"
const SCENE_VICTORY = "res://scenes/victory/victory.tscn"

# Resolução de referência (Mobile)
const VIEWPORT_WIDTH = 1080
const VIEWPORT_HEIGHT = 1920

# Atributos do Personagem
const ATTRIBUTES = {
	"force": "FOR",
	"dexterity": "DES",
	"intellect": "INT",
	"vigor": "VIG",
	"luck": "SORTE",
	"spirit": "ESP"
}

# Valores Iniciais
const INITIAL_HP = 100
const INITIAL_ENERGY = 20
const INITIAL_GOLD = 25
const INITIAL_ATTRIBUTE_VALUE = 10

# Combate
const TURN_TIMEOUT = 30.0
const BASE_DAMAGE_MULTIPLIER = 1.0

# Progressão
const XP_MULTIPLIER = 1.1
const LEVEL_UP_HP_BONUS = 10

# Cores (será usado na UI)
const COLOR_HP = Color.RED
const COLOR_ENERGY = Color.BLUE
const COLOR_GOLD = Color.YELLOW
const COLOR_TEXT_PRIMARY = Color.WHITE
const COLOR_TEXT_SECONDARY = Color.LIGHT_GRAY
const COLOR_BACKGROUND = Color.BLACK

# Tipos de Itens
enum ItemType {
	CONSUMABLE,
	EQUIPMENT,
	QUEST,
	MATERIAL,
	SPECIAL
}

# Status de Missão
enum QuestStatus {
	LOCKED,
	AVAILABLE,
	ACTIVE,
	COMPLETED,
	FAILED
}

# Estados de Combate
enum CombatState {
	WAITING,
	PLAYER_TURN,
	PLAYER_ACTION,
	ENEMY_TURN,
	ENEMY_ACTION,
	VICTORY,
	DEFEAT
}
