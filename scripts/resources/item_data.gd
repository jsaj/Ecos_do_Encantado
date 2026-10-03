extends Resource
class_name ItemData

@export var id: String = ""
@export var name: String = "Novo Item"
@export_multiline var description: String = ""
@export var price: int = 0
@export var stackable: bool = true
@export var max_stack: int = 99
@export var icon: Texture2D

enum ItemType { CONSUMABLE, EQUIPMENT, MATERIAL, QUEST }
@export var type: ItemType = ItemType.CONSUMABLE
