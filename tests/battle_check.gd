extends Node

## Verificação headless da tela de batalha.
## Roda como cena para que os autoloads (GameState, GameManager,
## SceneManager, Constants) estejam registrados:
##   godot --headless res://tests/battle_test.tscn
## Sai com código 0 se tudo passar, 1 em caso de falha.

const SCENE_PATH := "res://scenes/battle/battle.tscn"

var _failures: Array[String] = []

func _ready() -> void:
	await _run()
	if _failures.is_empty():
		print("OK: tela de batalha validada")
		get_tree().quit(0)
	else:
		for f in _failures:
			printerr("FAIL: ", f)
		get_tree().quit(1)

func _run() -> void:
	var scene: PackedScene = load(SCENE_PATH)
	if scene == null:
		_fail("cena nao carregou: " + SCENE_PATH)
		return

	var screen: Control = scene.instantiate()
	add_child(screen)
	await get_tree().process_frame
	await get_tree().process_frame

	_check_nodes(screen)
	if not _failures.is_empty():
		return

	var skill_tree: SkillTree = screen.get_node("%SkillTree")
	if skill_tree.get_child_count() != BattleSkills.skill_tree().size():
		_fail("habilidades: esperado %d, obtido %d" % [
			BattleSkills.skill_tree().size(), skill_tree.get_child_count()
		])

	var equipped: VBoxContainer = screen.get_node("%EquippedList")
	if equipped.get_child_count() != BattleSkills.equipped_items().size():
		_fail("itens: esperado %d, obtido %d" % [
			BattleSkills.equipped_items().size(), equipped.get_child_count()
		])

	var statuses: VBoxContainer = screen.get_node("%StatusList")
	if statuses.get_child_count() != BattleSkills.status_effects().size():
		_fail("efeitos: esperado %d, obtido %d" % [
			BattleSkills.status_effects().size(), statuses.get_child_count()
		])

	_check_effect_labels_are_visible(statuses)
	_check_turn_flow(screen, skill_tree)
	await _check_log(screen)

func _check_nodes(screen: Control) -> void:
	for node_name in [
		"AttackButton", "InventorySlot", "SkillTree", "EquippedList", "StatusList",
		"CombatLog", "CombatMenu", "TurnOrder", "HeroStatus", "EnemyStatus",
		"HeroPortrait", "EnemyPortrait", "TargetPortrait", "TargetName",
		"TurnIndicator", "SettingsButton", "HeroBody", "EnemyBody",
	]:
		if screen.get_node_or_null("%" + node_name) == null:
			_fail("no ausente: " + node_name)

## Os rotulos de efeito sumiam quando clip_text zerava a altura minima.
func _check_effect_labels_are_visible(statuses: VBoxContainer) -> void:
	for row in statuses.get_children():
		var label := _find_label(row)
		if label == null:
			_fail("linha de efeito sem Label")
			return
		if label.text.is_empty():
			_fail("rotulo de efeito vazio")
			return
		if label.clip_text:
			_fail("rotulo de efeito com clip_text ligado (some na renderizacao)")

func _find_label(node: Node) -> Label:
	for child in node.get_children():
		if child is Label:
			return child
		var found := _find_label(child)
		if found != null:
			return found
	return null

func _check_turn_flow(screen: Control, skill_tree: SkillTree) -> void:
	var initial_turn: int = screen.turn_number
	var initial_enemy_hp: int = screen.enemy.hp

	screen.get_node("%AttackButton").emit_signal("pressed")
	await get_tree().process_frame

	if screen.enemy.hp >= initial_enemy_hp:
		_fail("ataque basico nao reduziu a vida do inimigo")

	skill_tree.emit_signal("skill_selected", BattleSkills.skill_tree()[1])
	await get_tree().process_frame

	screen.get_node("%CombatMenu").emit_signal("pass_turn_requested")
	await get_tree().process_frame

	if screen.turn_number <= initial_turn:
		_fail("turno nao avancou apos as acoes")

func _check_log(screen: Control) -> void:
	var log: CombatLog = screen.get_node("%CombatLog")
	var list := log.get_child(0).get_child(2)
	var rows := list.get_child_count()
	if rows < BattleSkills.initial_log().size():
		_fail("log: esperado ao menos %d linhas, obtido %d" % [
			BattleSkills.initial_log().size(), rows
		])
	else:
		print("log com ", rows, " linhas; turno final ", screen.turn_number)

func _fail(message: String) -> void:
	_failures.append(message)