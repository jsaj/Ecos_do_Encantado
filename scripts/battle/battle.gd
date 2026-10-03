extends Control

## Tela de batalha tática por turnos.
## Layout adaptado para o viewport retrato 1080x1920 do projeto:
##   Topo      -> cenário da floresta + personagens
##   Meio      -> painel de iniciativa e barras de status
##   Inferior  -> Battle Action Panel (ações / habilidades / inventário / alvo)
##   Base      -> Combat Log e Menu de Combate
##
## A arte final entra depois: os caminhos de textura em BattleSkills
## apontam para slots ainda não existentes e caem em placeholders.

@onready var _hero_portrait: PortraitSlot = %HeroPortrait
@onready var _enemy_portrait: PortraitSlot = %EnemyPortrait
@onready var _hero_status: StatusBar = %HeroStatus
@onready var _enemy_status: StatusBar = %EnemyStatus
@onready var _skill_tree: SkillTree = %SkillTree
@onready var _combat_log: CombatLog = %CombatLog
@onready var _combat_menu: CombatMenu = %CombatMenu
@onready var _attack_button: Button = %AttackButton
@onready var _status_list: VBoxContainer = %StatusList
@onready var _equipped_list: VBoxContainer = %EquippedList
@onready var _inventory_slot: Button = %InventorySlot
@onready var _target_name: Label = %TargetName
@onready var _target_portrait: PortraitSlot = %TargetPortrait
@onready var _turn_indicator: Label = %TurnIndicator
@onready var _settings_button: Button = %SettingsButton
@onready var _hero_body: TextureRect = %HeroBody
@onready var _enemy_body: TextureRect = %EnemyBody
@onready var _turn_order: VBoxContainer = %TurnOrder

var player: BattleCombatant
var enemy: BattleCombatant
var turn_number: int = 3
var _awaiting_player: bool = true

func _ready() -> void:
	player = BattleSkills.player()
	enemy = BattleSkills.enemy()

	_build_static_ui()
	_connect_signals()
	_refresh_combatants()
	_skill_tree.refresh_availability(player)
	_combat_log.push_entries(BattleSkills.initial_log())
	_update_turn_indicator()

# Montagem das listas repetitivas ---------------------------------------

func _build_static_ui() -> void:
	_style_buttons()
	_build_turn_order()
	_build_equipped_slots()
	_build_status_effects()
	_apply_portraits()
	_apply_target()
	_skill_tree.setup(BattleSkills.skill_tree())

func _style_buttons() -> void:
	BattleTheme.apply_button(_attack_button, BattleTheme.WOOD_MID, BattleTheme.FIRE)
	_attack_button.add_theme_font_size_override("font_size", 24)
	BattleTheme.apply_button(_inventory_slot, BattleTheme.GREEN_PANEL, BattleTheme.GREEN_SORCERY)
	_inventory_slot.add_theme_font_size_override("font_size", 22)
	BattleTheme.apply_button(_settings_button, BattleTheme.WOOD_MID, BattleTheme.BORDER_METAL)
	_settings_button.add_theme_font_size_override("font_size", 34)

## Coluna central de ordem de turnos com setas verticais.
func _build_turn_order() -> void:
	for child in _turn_order.get_children():
		child.queue_free()
	for i in 4:
		var marker := PanelContainer.new()
		marker.custom_minimum_size = Vector2(44, 44)
		marker.add_theme_stylebox_override(
			"panel",
			BattleTheme.slot_box(
				BattleTheme.WOOD_LIGHT if i == 0 else BattleTheme.WOOD_MID,
				BattleTheme.GOLD if i == 0 else BattleTheme.BORDER_METAL_DIM
			)
		)
		var label := Label.new()
		label.text = "▼" if i == 0 else "·"
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", BattleTheme.GOLD if i == 0 else BattleTheme.TEXT_DIM)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		marker.add_child(label)
		_turn_order.add_child(marker)

func _build_equipped_slots() -> void:
	for child in _equipped_list.get_children():
		child.queue_free()
	for item in BattleSkills.equipped_items():
		_equipped_list.add_child(_make_item_slot(item))

func _make_item_slot(item: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", BattleTheme.slot_box(BattleTheme.WOOD_MID, BattleTheme.BORDER_METAL_DIM))
	panel.custom_minimum_size = Vector2(0, 74)
	panel.clip_contents = true

	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	var icon_frame := PanelContainer.new()
	icon_frame.custom_minimum_size = Vector2(44, 44)
	icon_frame.add_theme_stylebox_override("panel", BattleTheme.slot_box(BattleTheme.PARCHMENT_SOFT, BattleTheme.BORDER_METAL_DIM))
	box.add_child(icon_frame)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(44, 44)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var path := str(item.get("icon_path", ""))
	if not path.is_empty() and ResourceLoader.exists(path):
		var res := ResourceLoader.load(path)
		if res is Texture2D:
			icon.texture = res
	icon_frame.add_child(icon)

	var info := VBoxContainer.new()
	info.add_theme_constant_override("separation", 0)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(info)

	var name_label := Label.new()
	name_label.text = str(item.get("label", ""))
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", BattleTheme.TEXT_MAIN)
	name_label.clip_text = true
	info.add_child(name_label)

	var stats := HBoxContainer.new()
	stats.add_theme_constant_override("separation", 8)
	# Sem expandir: a linha de atributos deve caber na célula, sem estourar o painel
	stats.clip_contents = true
	info.add_child(stats)
	_add_stat(stats, "♥", int(item.get("damage", 0)), BattleTheme.HP_RED)
	_add_stat(stats, "⛨", int(item.get("defense", 0)), Color("7fc7e8"))
	_add_stat(stats, "✦", int(item.get("mana", 0)), Color("6f9fd8"))
	_add_stat(stats, "⚡", int(item.get("stamina", 0)), BattleTheme.STAMINA_PURPLE)
	_add_stat(stats, "◈", int(item.get("slots", 0)), BattleTheme.GOLD)

	return panel

func _add_stat(parent: Node, glyph: String, value: int, color: Color) -> void:
	if value <= 0:
		return
	var label := Label.new()
	label.text = "%s %d" % [glyph, value]
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", color)
	label.clip_text = true
	parent.add_child(label)

func _build_status_effects() -> void:
	for child in _status_list.get_children():
		child.queue_free()
	for effect in BattleSkills.status_effects():
		_status_list.add_child(_make_effect_row(effect))

func _make_effect_row(effect: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var kind := str(effect.get("kind", "buff"))
	var icon_frame := PanelContainer.new()
	icon_frame.custom_minimum_size = Vector2(40, 40)
	icon_frame.add_theme_stylebox_override(
		"panel",
		BattleTheme.slot_box(
			BattleTheme.GREEN_PANEL if kind == "buff" else BattleTheme.PARCHMENT_SOFT,
			BattleTheme.GREEN_SORCERY if kind == "buff" else BattleTheme.DANGER
		)
	)
	row.add_child(icon_frame)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(40, 40)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var path := str(effect.get("icon_path", ""))
	if not path.is_empty() and ResourceLoader.exists(path):
		var res := ResourceLoader.load(path)
		if res is Texture2D:
			icon.texture = res
	icon_frame.add_child(icon)

	var label := Label.new()
	label.text = str(effect.get("name", ""))
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", BattleTheme.TEXT_MAIN)
	# autowrap sem clip_text: clip_text zeraria a altura minima e o texto sumiria
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)

	return row

func _apply_portraits() -> void:
	_hero_portrait.texture_path = player.portrait_texture_path
	_enemy_portrait.texture_path = enemy.portrait_texture_path
	_hero_portrait.set_accent(Color("d0872a"))
	_enemy_portrait.set_accent(Color("c0392b"))
	_set_body_texture(_hero_body, player.body_texture_path)
	_set_body_texture(_enemy_body, enemy.body_texture_path)

func _set_body_texture(rect: TextureRect, path: String) -> void:
	if path.is_empty() or not ResourceLoader.exists(path):
		rect.texture = null
		return
	var res := ResourceLoader.load(path)
	rect.texture = res if res is Texture2D else null

func _apply_target() -> void:
	_target_name.text = enemy.display_name
	_target_portrait.texture_path = enemy.portrait_texture_path
	_target_portrait.set_accent(Color("c0392b"))
	_target_portrait.set_portrait_size(60)

# Sinais -----------------------------------------------------------------

func _connect_signals() -> void:
	_attack_button.pressed.connect(_on_attack_pressed)
	_inventory_slot.pressed.connect(_on_inventory_pressed)
	_skill_tree.skill_selected.connect(_on_skill_selected)
	_combat_menu.flee_requested.connect(_on_flee_pressed)
	_combat_menu.pass_turn_requested.connect(_on_pass_turn_pressed)
	_combat_menu.pause_requested.connect(_on_pause_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)

# Fluxo de turnos --------------------------------------------------------

func _on_attack_pressed() -> void:
	if not _awaiting_player:
		return
	_combat_log.push_entry("[TURNO %d] Caipora ataca %s!" % [turn_number, enemy.display_name], "turn")
	var damage := enemy.receive_damage(player.attack_power)
	_combat_log.push_entry("Dano: %d" % damage, "damage")
	_refresh_combatants()
	_end_player_turn()

func _on_skill_selected(skill: Dictionary) -> void:
	var skill_name := str(skill.get("name", ""))
	var mana_cost := int(skill.get("mana_cost", 0))
	var damage := int(skill.get("damage", 0))
	var critical := int(skill.get("critical", 0))

	_combat_log.push_entry("[TURNO %d] Caipora usa '%s' em %s!" % [turn_number, skill_name, enemy.display_name], "turn")

	if damage > 0:
		if not player.spend_mana(mana_cost):
			_combat_log.push_entry("Mana insuficiente.", "system")
			_refresh_combatants()
			return
		var dealt := enemy.receive_damage(damage)
		_combat_log.push_entry("Dano: %d, Crítico: %d" % [dealt, critical], "damage")
	else:
		_combat_log.push_entry("%s sem dano direto." % skill_name, "buff")

	_refresh_combatants()
	_end_player_turn()

func _on_inventory_pressed() -> void:
	_combat_log.push_entry("Inventário de combate aberto (Equippable).", "system")

func _on_pass_turn_pressed() -> void:
	_combat_log.push_entry("Caipora passou o turno.", "system")
	_end_player_turn()

func _on_flee_pressed() -> void:
	_combat_log.push_entry("Caipora tenta fugir...", "system")
	_combat_log.push_entry("Fuga bem-sucedida!", "system")
	GameState.combat_state["in_combat"] = false
	_go_to_menu()

func _on_pause_pressed() -> void:
	# GameManager e o dono do estado de pausa do jogo
	GameManager.is_paused = false
	GameManager.pause_game()

func _on_settings_pressed() -> void:
	_go_to_menu()

func _go_to_menu() -> void:
	# Resolvido em runtime para permitir instanciar a cena em testes headless,
	# onde o autoload SceneManager pode nao estar registrado.
	var manager := get_node_or_null("/root/SceneManager")
	if manager != null and manager.has_method("load_scene"):
		manager.call("load_scene", Constants.SCENE_MAIN_MENU)
	else:
		push_warning("BattleScreen: SceneManager indisponível; permanecendo na cena.")

func _end_player_turn() -> void:
	if not _awaiting_player:
		return
	_awaiting_player = false
	player.has_acted = true
	_advance_turn()

func _advance_turn() -> void:
	turn_number += 1
	_combat_log.push_entry("Curupira's turn", "turn")
	_enemy_turn()

func _enemy_turn() -> void:
	var damage := player.receive_damage(enemy.attack_power)
	_combat_log.push_entry("Curupira ataca Caipora! (Dano: %d)" % damage, "damage")
	_refresh_combatants()

	if not player.is_alive():
		_combat_log.push_entry("Caipora foi derrotado.", "damage")
		_awaiting_player = false
		_combat_menu.set_actions_enabled(false)
		return

	_combat_log.push_entry("Caipora's turn", "turn")
	_awaiting_player = true
	_update_turn_indicator()

func _refresh_combatants() -> void:
	_hero_status.apply_combatant(player)
	_enemy_status.apply_combatant(enemy)
	_skill_tree.refresh_availability(player)

func _update_turn_indicator() -> void:
	_turn_indicator.text = "TURNO %d — %s" % [turn_number, player.display_name if _awaiting_player else enemy.display_name]
