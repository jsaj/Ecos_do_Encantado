extends CharacterBody2D
class_name CharacterBase

@export var character_name: String = "Unknown"
@export var max_hp: int = 100
var current_hp: int = 100
@export var movement_speed: float = 150.0

func _ready() -> void:
	current_hp = max_hp

func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	if current_hp == 0:
		die()

func heal(amount: int) -> void:
	current_hp = min(max_hp, current_hp + amount)

func die() -> void:
	queue_free()
