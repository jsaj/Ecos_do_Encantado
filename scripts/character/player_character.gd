extends CharacterBase
class_name PlayerCharacter

func _ready() -> void:
	super._ready()
	character_name = GameState.player.get("name", "Aventureiro")
	max_hp = GameState.player.get("max_hp", 100)
	current_hp = GameState.player.get("hp", 100)
	
	# Sync initial stats from GameState
	sync_stats()

func sync_stats() -> void:
	max_hp = GameState.player.get("max_hp", 100)
	current_hp = GameState.player.get("hp", 100)

func gain_xp(amount: int) -> void:
	GameState.add_xp(amount)
