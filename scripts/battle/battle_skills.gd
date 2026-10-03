class_name BattleSkills
extends RefCounted

## Catálogo de dados da tela de batalha.
## Mantém os valores fora da cena para que o balanceamento e a arte
## possam ser ajustados depois sem reescrever a UI.

const PLAYER_NAME := "Caipora"
const ENEMY_NAME := "Curupira"

static func player() -> BattleCombatant:
	var c := BattleCombatant.new()
	c.display_name = PLAYER_NAME
	c.max_hp = 150
	c.hp = 150
	c.max_mp = 77
	c.mp = 78
	c.max_stamina = 0
	c.stamina = 0
	c.attack_power = 12
	c.defense = 5
	c.is_player = true
	# Slots de arte (vazios até a arte final existir)
	c.portrait_texture_path = "res://assets/characters/caipora_portrait.png"
	c.body_texture_path = "res://assets/characters/luana.png"
	c.add_effect({"name": "Manto das Lianas", "kind": "buff", "turns": 3})
	c.add_effect({"name": "Deferente", "kind": "debuff", "turns": 2})
	return c

static func enemy() -> BattleCombatant:
	var c := BattleCombatant.new()
	c.display_name = ENEMY_NAME
	c.max_hp = 130
	c.hp = 130
	c.max_mp = 30
	c.mp = 30
	c.max_stamina = 0
	c.attack_power = 35
	c.defense = 4
	c.is_player = false
	c.portrait_texture_path = "res://assets/enemies/curupira_portrait.png"
	c.body_texture_path = "res://assets/enemies/curupira_body.png"
	return c

## Árvore de habilidades do Caipora. `icon_path` vazio = placeholder desenhado.
static func skill_tree() -> Array[Dictionary]:
	return [
		{
			"name": "Chama da Mata",
			"icon_path": "",
			"color": Color("e07b26"),
			"damage": 0,
			"mana_cost": 0,
			"critical": 0,
			"stamina_cost": 0,
			"branch": "root",
			"description": "Invoca o fogo da floresta contra o alvo.",
		},
		{
			"name": "Investida",
			"icon_path": "",
			"color": Color("b8562c"),
			"damage": 35,
			"mana_cost": 10,
			"critical": 15,
			"stamina_cost": 0,
			"branch": "left",
			"description": "Investida Flamejante com chance de crítico.",
		},
		{
			"name": "Ehuita",
			"icon_path": "",
			"color": Color("4f9d4a"),
			"damage": 0,
			"mana_cost": 5,
			"critical": 0,
			"stamina_cost": 0,
			"branch": "right",
			"description": "Feitiço verde de proteção e cura leve.",
		},
		{
			"name": "Chamira",
			"icon_path": "",
			"color": Color("7a4fbf"),
			"damage": 0,
			"mana_cost": 1,
			"critical": 0,
			"stamina_cost": 0,
			"branch": "trunk",
			"description": "Encantamento místico ancestral.",
		},
	]

## Slots rápidos do inventário de combate equipped.
static func equipped_items() -> Array[Dictionary]:
	return [
		{
			"label": "Equi",
			"icon_path": "res://assets/icons/dagger.png",
			"damage": 2,
			"mana": 3,
			"slots": 3,
		},
		{
			"label": "Equip",
			"icon_path": "res://assets/icons/dagger_2.png",
			"damage": 1,
			"defense": 10,
			"stamina": 3,
		},
		{
			"label": "Bag",
			"icon_path": "res://assets/icons/pouch.png",
			"damage": 0,
			"defense": 0,
		},
	]

## Efeitos ativos exibidos em "Alvo e Status".
static func status_effects() -> Array[Dictionary]:
	return [
		{"name": "Temporária", "icon_path": "res://assets/icons/effect_temp.png", "kind": "buff"},
		{"name": "Temporária de 'Manto das Lianais'", "icon_path": "res://assets/icons/effect_lianas.png", "kind": "buff"},
		{"name": "Debuff de Deferente", "icon_path": "res://assets/icons/effect_debuff.png", "kind": "debuff"},
		{"name": "Debuffs", "icon_path": "res://assets/icons/effect_debuffs.png", "kind": "debuff"},
	]

## Linhas iniciais do Combat Log, reproduzindo a captura de referência.
static func initial_log() -> Array[Dictionary]:
	return [
		{"text": "Caipora ativa um 'Mante buffs'", "kind": "buff"},
		{"text": "Caipora buffs  →  Debuffs ✖", "kind": "debuff"},
		{"text": "Caipora ativa \"Manto das Lianas\"!", "kind": "buff"},
		{"text": "Caipora's turn", "kind": "turn"},
		{"text": "[TURNO 3] Curupira usa 'Investida Flamejante' em Caipora! (Dano: 35, Crítico: 15)", "kind": "damage"},
		{"text": "Caipora ativa \"Manto das Lianas\"!", "kind": "buff"},
		{"text": "Caipora's turn", "kind": "turn"},
	]
