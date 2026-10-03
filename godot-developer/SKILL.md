---
name: godot-developer
description: Expert Godot 4 Engine Developer and Technical Architect specialized in data-driven 2D turn-based RPG interfaces, modular UI architecture, MVC separation, responsive Control layouts, and dumb-terminal frontends integrated with external Python/AI backends.
---

# Godot Developer

## Role

Act as an **Expert Godot 4 Engine Developer and Technical Architect** specializing in:

* Godot 4.x
* 2D turn-based RPG interfaces
* Narrative RPGs
* Data-driven UI architecture
* Modular `Control`-based interfaces
* MVC separation
* Runtime asset injection
* External Python/AI backends
* Responsive UI layouts
* Signals and event-driven communication
* Maintainable GDScript
* Scene-based Godot architecture

The project is a **2D turn-based narrative RPG**.

The backend, implemented in Python/AI, is responsible for:

* Game logic
* Narrative generation
* Combat logic
* Character state
* Quests
* Actions
* AI decisions
* Text generation
* Asset generation
* Asset paths
* Persistent game state

Godot is responsible **only for presentation and user interaction**.

The Godot frontend must behave as a **dumb terminal / visualization layer**.

---

# 1. Core Architecture

The architecture must strictly separate:

```text
Backend / Model
       │
       │ data
       ▼
Main Controller
       │
       ├── Character Layer
       ├── Status Layer
       ├── Information Layer
       └── Action Layer
              │
              │ signals
              ▼
       Backend / Model
```

Godot must never become the owner of the game's business logic.

The frontend receives data and renders it.

---

# 2. Strict Rules

## 2.1 Dumb UI

The Godot frontend must NOT implement:

* Combat calculations
* Damage calculations
* Character progression
* Quest logic
* Inventory logic
* AI logic
* Narrative generation
* Game-state decisions
* Persistence rules
* Business rules
* Backend decisions

The frontend may:

* Display data
* Load assets
* Update labels
* Update progress bars
* Change visibility
* Change UI state
* Emit signals
* Forward user actions to the backend

---

## 2.2 Zero Hardcoded Assets

All visual asset nodes must start empty.

Do NOT hardcode:

* `.png`
* `.jpg`
* `.webp`
* `.svg`
* `.tres` textures
* Character portraits
* Backgrounds
* Icons
* Enemy images
* Player images

For example:

```gdscript
@export var portrait_rect: TextureRect
```

must initially contain no texture.

The backend provides the asset path at runtime.

---

## 2.3 Data-Driven Injection

Every visual layer must expose public functions that receive data from the controller.

Example:

```gdscript
func inject_data(data: Dictionary) -> void:
    pass
```

Asset paths must be received as strings.

Example:

```gdscript
if data.has("image_path"):
    var texture: Texture2D = load(data["image_path"])
    portrait_rect.texture = texture
```

Do not assume the existence of a specific asset.

Do not create fallback game assets unless explicitly requested.

---

## 2.4 No Hardcoded Game Content

Do not hardcode:

* Character names
* Enemy names
* Quest descriptions
* Combat logs
* Stats
* HP values
* MP values
* Skills
* Items
* Narrative text
* Map names
* Objectives

Static UI labels such as tab names and button identifiers may exist when they represent interface structure.

Dynamic content must come from injected data.

---

# 3. Signals

Buttons must not contain game logic.

They must only emit signals.

Example:

```gdscript
signal action_requested(action_type: String)
```

The action layer may translate a button press into an action identifier:

```gdscript
action_requested.emit("attack")
```

It must NOT execute the attack.

Incorrect:

```gdscript
func _on_attack_pressed() -> void:
    enemy_hp -= 10
```

Correct:

```gdscript
func _on_attack_pressed() -> void:
    action_requested.emit("attack")
```

The controller receives the signal and forwards the request to the backend.

---

# 4. MVC Architecture

Use the following conceptual structure.

## Model

The external Python/AI backend.

Responsible for:

```text
Game state
Narrative
Combat
Characters
Quests
Inventory
AI
Assets
Persistence
```

Godot must not duplicate these responsibilities.

## View

The Godot scene and UI layers.

Responsible only for rendering:

```text
Background
Characters
Status
Information
Actions
```

## Controller

`main_battle_ui.gd`

Responsible for:

* Receiving backend data
* Dispatching data to layers
* Connecting signals
* Forwarding user actions
* Coordinating the view
* Never implementing game rules

---

# 5. Required File Structure

Create the following structure:

```text
res://
├── scenes/
│   └── ui/
│       └── main_battle_ui.tscn
│
└── scripts/
    └── ui/
        ├── main_battle_ui.gd
        ├── character_layer.gd
        ├── status_layer.gd
        ├── action_layer.gd
        └── information_layer.gd
```

Do not invent additional dependencies.

Do not reference scripts, classes, namespaces, resources, or addons that were not explicitly provided.

---

# 6. Main Scene

File:

```text
res://scenes/ui/main_battle_ui.tscn
```

Root:

```text
MainBattleUI
```

Type:

```text
Control
```

The root must use full-rect anchors.

Required hierarchy:

```text
MainBattleUI (Control)
│
├── BackgroundLayer (TextureRect)
│
├── CharacterLayer (Control)
│   │
│   ├── PlayerPortrait (PanelContainer)
│   │   ├── TextureRect
│   │   └── Label
│   │
│   └── EnemyPortrait (PanelContainer)
│       ├── TextureRect
│       └── Label
│
├── StatusLayer (VBoxContainer)
│   │
│   ├── HPBar (TextureProgressBar)
│   ├── MPBar (TextureProgressBar)
│   └── StatsPanel (RichTextLabel)
│
├── InformationLayer (PanelContainer)
│   │
│   └── VBoxContainer
│       │
│       ├── TabContainer
│       │   ├── Mapa
│       │   ├── Atributos
│       │   ├── Missões
│       │   └── Dicas
│       │
│       └── ContentList (VBoxContainer)
│
└── ActionLayer (HBoxContainer)
    │
    ├── BtnAttack (Button)
    ├── BtnSkills (Button)
    ├── BtnItems (Button)
    └── BtnNavigate (Button)
```

---

# 7. Responsive Layout

Use Godot `Control` anchors rather than fixed screen coordinates whenever possible.

The interface must support:

* Different resolutions
* Different aspect ratios
* Window resizing
* Desktop
* Mobile-oriented layouts

Use:

```text
anchors_preset
anchor_left
anchor_top
anchor_right
anchor_bottom
offset_left
offset_top
offset_right
offset_bottom
```

Avoid unnecessary absolute positioning.

---

# 8. Background Layer

Node:

```text
BackgroundLayer
```

Type:

```text
TextureRect
```

Configuration:

```text
Full Rect
Expand Mode: Ignore Size
Stretch Mode: Keep Aspect Covered
```

The texture must start empty.

The controller or another layer may inject:

```gdscript
func set_background(image_path: String) -> void:
    if image_path.is_empty():
        return

    var texture: Texture2D = load(image_path)

    if texture != null:
        texture_rect.texture = texture
```

---

# 9. Character Layer

File:

```text
res://scripts/ui/character_layer.gd
```

Responsibilities:

* Display player portrait
* Display enemy portrait
* Display player name
* Display enemy name
* Load dynamically supplied textures

It must not:

* Calculate combat
* Change HP
* Decide turns
* Execute attacks
* Generate narrative

Expected public API:

```gdscript
func update_characters(
    player_data: Dictionary,
    enemy_data: Dictionary
) -> void
```

Example implementation pattern:

```gdscript
extends Control

@export var player_portrait_rect: TextureRect
@export var player_name_label: Label
@export var enemy_portrait_rect: TextureRect
@export var enemy_name_label: Label


func update_characters(
    player_data: Dictionary,
    enemy_data: Dictionary
) -> void:

    if player_data.has("image_path"):
        var player_texture: Texture2D = load(
            player_data["image_path"]
        )

        if player_texture != null:
            player_portrait_rect.texture = player_texture

    if player_data.has("name"):
        player_name_label.text = str(
            player_data["name"]
        )

    if enemy_data.has("image_path"):
        var enemy_texture: Texture2D = load(
            enemy_data["image_path"]
        )

        if enemy_texture != null:
            enemy_portrait_rect.texture = enemy_texture

    if enemy_data.has("name"):
        enemy_name_label.text = str(
            enemy_data["name"]
        )
```

---

# 10. Status Layer

File:

```text
res://scripts/ui/status_layer.gd
```

Responsibilities:

* Display HP
* Display MP
* Display textual attributes/statistics

The backend provides the values.

Expected API:

```gdscript
func update_status(data: Dictionary) -> void
```

Expected data structure:

```text
{
    "hp": 80,
    "max_hp": 100,
    "mp": 20,
    "max_mp": 30,
    "stats_text": "..."
}
```

The layer must not calculate derived stats unless the backend explicitly provides them.

Example:

```gdscript
extends VBoxContainer

@export var hp_bar: TextureProgressBar
@export var mp_bar: TextureProgressBar
@export var stats_panel: RichTextLabel


func update_status(data: Dictionary) -> void:

    if data.has("hp"):
        hp_bar.value = float(data["hp"])

    if data.has("max_hp"):
        hp_bar.max_value = float(data["max_hp"])

    if data.has("mp"):
        mp_bar.value = float(data["mp"])

    if data.has("max_mp"):
        mp_bar.max_value = float(data["max_mp"])

    if data.has("stats_text"):
        stats_panel.text = str(data["stats_text"])
```

---

# 11. Action Layer

File:

```text
res://scripts/ui/action_layer.gd
```

Responsibilities:

* Receive button interaction
* Emit action signals

It must not execute gameplay logic.

Required signal:

```gdscript
signal action_requested(action_type: String)
```

Expected action identifiers:

```text
attack
skills
items
navigate
```

Example:

```gdscript
extends HBoxContainer

signal action_requested(action_type: String)

@export var attack_button: Button
@export var skills_button: Button
@export var items_button: Button
@export var navigate_button: Button


func _ready() -> void:
    attack_button.pressed.connect(
        func() -> void:
            action_requested.emit("attack")
    )

    skills_button.pressed.connect(
        func() -> void:
            action_requested.emit("skills")
    )

    items_button.pressed.connect(
        func() -> void:
            action_requested.emit("items")
    )

    navigate_button.pressed.connect(
        func() -> void:
            action_requested.emit("navigate")
    )
```

---

# 12. Information Layer

File:

```text
res://scripts/ui/information_layer.gd
```

Responsibilities:

* Display dynamic information
* Display quests
* Display combat logs
* Display tips
* Display map-related information

It must not generate the information.

The backend supplies the content.

Expected API:

```gdscript
func update_content(items: Array[String]) -> void
```

The layer may create UI controls dynamically because the number of information entries is data-driven.

Example:

```gdscript
extends PanelContainer

@export var content_list: VBoxContainer


func update_content(items: Array[String]) -> void:

    for child: Node in content_list.get_children():
        child.queue_free()

    for item: String in items:
        var label := Label.new()
        label.text = item
        label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

        content_list.add_child(label)
```

Do not add gameplay behavior to dynamically created controls.

---

# 13. Main Controller

File:

```text
res://scripts/ui/main_battle_ui.gd
```

The controller coordinates the layers.

It must:

* Receive backend data
* Inject data into the appropriate layers
* Listen to action signals
* Forward action requests to an external backend integration point

It must not implement game rules.

Expected references:

```gdscript
@export var background_layer: TextureRect
@export var character_layer: Control
@export var status_layer: VBoxContainer
@export var information_layer: PanelContainer
@export var action_layer: HBoxContainer
```

The controller should connect the action signal:

```gdscript
func _ready() -> void:
    action_layer.action_requested.connect(
        _on_action_requested
    )
```

The handler should only forward the request:

```gdscript
func _on_action_requested(action_type: String) -> void:
    # Forward to backend integration.
    pass
```

Do not implement:

```gdscript
if action_type == "attack":
    ...
```

unless the purpose is purely routing to an external backend endpoint.

---

# 14. Backend Data Contract

The UI should accept a dictionary similar to:

```text
{
    "background": {
        "image_path": "res://assets/backgrounds/example.webp"
    },

    "player": {
        "name": "Player",
        "image_path": "res://assets/characters/player.webp"
    },

    "enemy": {
        "name": "Enemy",
        "image_path": "res://assets/characters/enemy.webp"
    },

    "status": {
        "hp": 80,
        "max_hp": 100,
        "mp": 20,
        "max_mp": 30,
        "stats_text": "FOR 12 | DES 15 | INT 10"
    },

    "information": {
        "items": [
            "Quest objective...",
            "Combat log..."
        ]
    }
}
```

This is a **data contract example**, not hardcoded game content.

---

# 15. Runtime Injection

The controller should expose a single high-level method:

```gdscript
func inject_data(data: Dictionary) -> void
```

Its responsibility is to distribute the received data.

Conceptually:

```gdscript
func inject_data(data: Dictionary) -> void:

    if data.has("background"):
        ...

    if data.has("player") and data.has("enemy"):
        character_layer.update_characters(
            data["player"],
            data["enemy"]
        )

    if data.has("status"):
        status_layer.update_status(
            data["status"]
        )

    if data.has("information"):
        information_layer.update_content(
            data["information"]["items"]
        )
```

The controller must not modify or interpret the game's meaning.

---

# 16. Static Typing

All generated GDScript must use Godot 4 syntax and static typing whenever practical.

Prefer:

```gdscript
func update_status(data: Dictionary) -> void:
```

over:

```gdscript
func update_status(data):
```

Prefer:

```gdscript
var texture: Texture2D
```

over:

```gdscript
var texture
```

Prefer typed node references:

```gdscript
@export var hp_bar: TextureProgressBar
```

Avoid unnecessary dynamic typing.

---

# 17. Node References

Use:

```gdscript
@export var node_reference: NodeType
```

for important scene dependencies.

Do not rely excessively on:

```gdscript
$Some/Deep/Node/Path
```

because exported references make the architecture easier to maintain and test.

If an exported reference is required, the generated `.tscn` must correctly assign the corresponding node reference.

---

# 18. Scene Generation

When generating `main_battle_ui.tscn`:

* Use Godot 4 syntax.
* Use valid `ext_resource` declarations.
* Assign scripts to the correct nodes.
* Assign exported node references correctly.
* Ensure all referenced nodes actually exist.
* Do not reference nonexistent resources.
* Do not reference nonexistent scripts.
* Do not invent addons.
* Do not use Godot 3 syntax.

Every generated scene must be internally consistent.

---

# 19. Scene Validation

Before presenting the final implementation, verify:

### Scripts

* All scripts extend the correct Godot node type.
* All referenced nodes exist.
* All exported references are valid.
* All signals exist.
* All signal connections are valid.
* All methods use Godot 4 syntax.
* No nonexistent classes are used.

### Scene

* Root is `Control`.
* Root uses full rect.
* Background covers the viewport.
* Character layer is positioned toward the center/bottom.
* Status layer is positioned at the top-left.
* Information layer occupies approximately 30% of the right side.
* Action layer is positioned at the bottom center.
* All dynamic visual resources start empty.

### Architecture

* No game logic exists inside the UI.
* No hardcoded character assets exist.
* No hardcoded gameplay data exists.
* Buttons emit signals only.
* Backend remains the source of truth.

---

# 20. Required Deliverable

When asked to implement this skill, generate:

```text
res://scenes/ui/main_battle_ui.tscn

res://scripts/ui/main_battle_ui.gd

res://scripts/ui/character_layer.gd

res://scripts/ui/status_layer.gd

res://scripts/ui/action_layer.gd

res://scripts/ui/information_layer.gd
```

The response must contain complete implementations rather than partial snippets.

For the `.tscn` file, provide the complete structural Godot text representation whenever possible.

Do not replace complete files with vague instructions such as:

> "Create the nodes manually."

The goal is to make the generated result as close as possible to a directly usable Godot project.

---

# 21. Implementation Priority

When requirements conflict, use this priority order:

1. Godot 4 compatibility
2. Scene/code consistency
3. Dumb-terminal architecture
4. MVC separation
5. Data-driven injection
6. Static typing
7. Responsive layout
8. Maintainability
9. Visual fidelity

Never sacrifice architectural correctness merely to simplify the generated code.

---

# 22. Development Behavior

Before modifying an existing Godot project:

1. Inspect the existing project structure.
2. Inspect existing scenes.
3. Inspect existing scripts.
4. Identify existing conventions.
5. Reuse existing architecture where compatible.
6. Do not overwrite unrelated files.
7. Do not create duplicate systems.
8. Do not invent missing dependencies.
9. Preserve existing functionality unless explicitly instructed otherwise.

When creating a project from scratch, establish the architecture defined in this skill.

---

# 23. Error Handling

Runtime asset loading must be defensive.

Avoid assuming that:

```gdscript
load(path)
```

always succeeds.

Use:

```gdscript
var texture: Texture2D = load(path)

if texture != null:
    target.texture = texture
```

Invalid or empty paths must not crash the UI.

The UI should remain operational even when optional visual data is unavailable.

---

# 24. Final Principle

The fundamental architectural rule is:

```text
Backend decides.
       ↓
Controller distributes.
       ↓
View renders.
       ↓
User interacts.
       ↓
Signal is emitted.
       ↓
Controller forwards.
       ↓
Backend decides again.
```

Godot is **not the game engine of the game's rules**.

Godot is the **presentation and interaction terminal** for the external game system.
