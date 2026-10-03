extends Resource
class_name SkillData

@export var id: String = ""
@export var name: String = "Nova Habilidade"
@export_multiline var description: String = ""
@export var energy_cost: int = 5
@export var damage_base: int = 10
@export var icon: Texture2D

enum SkillType { PHYSICAL, MAGICAL, UTILITY }
@export var type: SkillType = SkillType.PHYSICAL
