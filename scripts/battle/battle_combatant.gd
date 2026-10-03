class_name BattleCombatant
extends Resource

## Representa um combatente na batalha por turnos.
## Os caminhos de textura ficam vazios de propósito: a arte final será
## conectada depois sem precisar mexer no layout.

@export var display_name: String = "Caipora"
@export var max_hp: int = 150
@export var hp: int = 150
@export var max_mp: int = 77
@export var mp: int = 77
@export var max_stamina: int = 0
@export var stamina: int = 0
@export var attack_power: int = 12
@export var defense: int = 5
@export var is_player: bool = true

# Pixels de arte (vazio = slot preparado para a arte final)
@export var portrait_texture_path: String = ""
@export var body_texture_path: String = ""

# Estado de turno
var has_acted: bool = false
var active_effects: Array[Dictionary] = []

func _init() -> void:
	hp = max_hp
	mp = max_mp
	stamina = max_stamina

func is_alive() -> bool:
	return hp > 0

func hp_ratio() -> float:
	return clampf(float(hp) / float(maxi(max_hp, 1)), 0.0, 1.0)

func mp_ratio() -> float:
	return clampf(float(mp) / float(maxi(max_mp, 1)), 0.0, 1.0)

func stamina_ratio() -> float:
	return clampf(float(stamina) / float(maxi(max_stamina, 1)), 0.0, 1.0)

func has_stamina_bar() -> bool:
	return max_stamina > 0

func receive_damage(amount: int) -> int:
	var mitigated: int = maxi(amount - defense / 2, 1)
	hp = maxi(hp - mitigated, 0)
	return mitigated

func spend_mana(amount: int) -> bool:
	if mp < amount:
		return false
	mp -= amount
	return true

func add_effect(effect: Dictionary) -> void:
	active_effects.append(effect)

func remove_effect(effect_name: String) -> void:
	for i in range(active_effects.size() - 1, -1, -1):
		if active_effects[i].get("name", "") == effect_name:
			active_effects.remove_at(i)

func has_effect(effect_name: String) -> bool:
	for e in active_effects:
		if e.get("name", "") == effect_name:
			return true
	return false

func reset_turn() -> void:
	has_acted = false

func portrait_texture() -> Texture2D:
	return _load_texture(portrait_texture_path)

func body_texture() -> Texture2D:
	return _load_texture(body_texture_path)

func _load_texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var res := ResourceLoader.load(path)
	return res if res is Texture2D else null
