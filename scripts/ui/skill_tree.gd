class_name SkillTree
extends VBoxContainer

## Árvore de habilidades com linhas conectoras entre os nós.
## A raiz ("Chama da Mata") fica no topo; as demais habilidades partem
## de um tronco vertical à esquerda, como na imagem de referência.

signal skill_selected(skill: Dictionary)

const ROW_HEIGHT := 72
const TRUNK_X := 22.0
const BRANCH_LEN := 16.0

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
		row.add_theme_constant_override("separation", BRANCH_LEN)
		row.custom_minimum_size = Vector2(0, ROW_HEIGHT)
		row.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(row)

		# Deixa a coluna do tronco livre à esquerda de cada linha
		var indent := Control.new()
		indent.custom_minimum_size = Vector2(TRUNK_X + BRANCH_LEN, 0)
		indent.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(indent)

		var node := SkillTreeNode.new()
		node.setup(skill, i)
		node.skill_pressed.connect(_on_node_pressed)
		row.add_child(node)

		_rows.append({"skill": skill, "node": node})

	queue_redraw()

func _draw() -> void:
	if _rows.size() < 2:
		return
	var root_center := _row_center(0)
	var last_center := _row_center(_rows.size() - 1)
	# Tronco vertical
	draw_line(
		Vector2(TRUNK_X, root_center),
		Vector2(TRUNK_X, last_center),
		BattleTheme.BORDER_METAL_DIM, 3.0
	)
	# Ramos horizontais até cada folha
	for i in range(1, _rows.size()):
		var y := _row_center(i)
		draw_line(Vector2(TRUNK_X, y), Vector2(TRUNK_X + BRANCH_LEN, y), BattleTheme.BORDER_METAL_DIM, 3.0)

func _row_center(index: int) -> float:
	var offset := 0.0
	for i in range(mini(index, _rows.size())):
		offset += ROW_HEIGHT + 4
	return offset + ROW_HEIGHT * 0.5

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
