class_name SkillTree
extends VBoxContainer

## Árvore de habilidades sem linhas conectoras (UI limpa).
## A raiz ("Chama da Mata") fica no topo; as demais habilidades são listadas verticalmente.

signal skill_selected(skill: Dictionary)

const ROW_HEIGHT := 72

var _skills: Array[Dictionary] = []
var _rows: Array[Dictionary] = []  # { skill, node }
var _selected: int = -1

func _init() -> void:
	add_theme_constant_override("separation", 4)
	mouse_filter = Control.MOUSE_FILTER_PASS

func setup(skills: Array[Dictionary]) -> void:
	_skills = skills.duplicate(true)
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		child.queue_free()
	_rows.clear()
	_selected = -1

	if _skills.is_empty():
		return

	for i in _skills.size():
		var skill: Dictionary = _skills[i]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		row.custom_minimum_size = Vector2(0, ROW_HEIGHT)
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(row)

		var node := SkillTreeNode.new()
		node.setup(skill, i)
		node.skill_pressed.connect(_on_node_pressed)
		row.add_child(node)

		_rows.append({"skill": skill, "node": node})

func _on_node_pressed(index: int) -> void:
	if index < 0 or index >= _rows.size():
		return
	_selected = index
	for i in _rows.size():
		var node: SkillTreeNode = _rows[i]["node"]
		node.set_selected(i == _selected)
	skill_selected.emit(_skills[index])

## Ajusta a disponibilidade conforme o mana atual do jogador.
func refresh_availability(player: BattleCombatant) -> void:
	for i in _rows.size():
		var skill: Dictionary = _skills[i]
		var cost := int(skill.get("mana_cost", 0))
		var node: SkillTreeNode = _rows[i]["node"]
		node.set_cost_labels(cost, int(skill.get("damage", 0)), int(skill.get("critical", 0)))
		node.set_affordable(player.mp >= cost)
