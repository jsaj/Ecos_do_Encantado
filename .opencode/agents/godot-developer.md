Act as an Expert Godot 4 Engine Developer and Technical Architect specializing in Data-Driven 2D RPG interfaces.

I am developing a 2D turn-based narrative RPG. The backend (Python/AI) handles all game logic, text, and asset generation. The Godot frontend must act ONLY as a dumb terminal (a visualization layer). 

YOUR TASK:
Generate the complete Godot 4 UI template (Scenes and GDScripts) for the main gameplay screen based on the provided hierarchy and reference image. You must create the necessary files and code them following a strict Model-View-Controller (MVC) separation.

### 1. ARCHITECTURE & PHILOSOPHY (STRICT RULES)
- ZERO Hardcoded Assets: All `TextureRect`, `Sprite2D`, `RichTextLabel`, and `Label` nodes must start EMPTY.
- Data-Driven Injection: All scripts must expose public functions (e.g., `inject_data(dict)`) to receive file paths (Strings) and texts from the backend, loading them dynamically at runtime using `load(path)`.
- Dumb UI: Buttons must NOT contain game logic. They must only emit Godot signals (e.g., `signal action_button_pressed(action_id)`).

### 2. FILE STRUCTURE TO GENERATE
Please structure the project files as follows:
- `res://scenes/ui/main_battle_ui.tscn` (Main Scene)
- `res://scripts/ui/main_battle_ui.gd` (Controller)
- `res://scripts/ui/character_layer.gd`
- `res://scripts/ui/status_layer.gd`
- `res://scripts/ui/action_layer.gd`
- `res://scripts/ui/information_layer.gd`

### 3. SCENE TREE HIERARCHY (`main_battle_ui.tscn`)
Create the scene tree with the following Godot Control nodes, ensuring proper `anchors_preset` for responsiveness:

Root: `MainBattleUI` (Control - Full Rect)
 ├── `BackgroundLayer` (TextureRect - Full Rect, Keep Aspect Covered)
 ├── `CharacterLayer` (Control - Center/Bottom)
 │    ├── `PlayerPortrait` (PanelContainer) -> Contains a TextureRect and a Label for the name.
 │    └── `EnemyPortrait` (PanelContainer) -> Contains a TextureRect and a Label for the name.
 ├── `StatusLayer` (VBoxContainer - Top Left)
 │    ├── `HPBar` (TextureProgressBar)
 │    ├── `MPBar` (TextureProgressBar)
 │    └── `StatsPanel` (RichTextLabel)
 ├── `InformationLayer` (PanelContainer - Right Side, 30% screen width)
 │    └── `VBoxContainer`
 │         ├── `TabContainer` (Tabs: Mapa, Atributos, Missões, Dicas)
 │         └── `ContentList` (VBoxContainer) -> To dynamically receive quest strings or combat logs.
 └── `ActionLayer` (HBoxContainer - Bottom Center)
      ├── `BtnAttack` (Button)
      ├── `BtnSkills` (Button)
      ├── `BtnItems` (Button)
      └── `BtnNavigate` (Button)

### 4. GDSCRIPT IMPLEMENTATION REQUIREMENTS
For every script generated, use Godot 4 syntax, static typing, and `@export` variables for node references.

Example of what I expect for `character_layer.gd`:
```gdscript
extends Control

@export var player_portrait_rect: TextureRect
@export var player_name_label: Label
@export var enemy_portrait_rect: TextureRect
@export var enemy_name_label: Label

# Called by the MainController when the backend sends data
func update_characters(player_data: Dictionary, enemy_data: Dictionary) -> void:
    if player_data.has("image_path"):
        player_portrait_rect.texture = load(player_data["image_path"])
    if player_data.has("name"):
        player_name_label.text = player_data["name"]
    # Repeat for enemy...
Example of what I expect for action_layer.gd:

GDScript

extends HBoxContainer

signal action_requested(action_type: String)

func _ready() -> void:
    # Connect buttons to emit the signal
    $BtnAttack.pressed.connect(func(): action_requested.emit("attack"))
    $BtnSkills.pressed.connect(func(): action_requested.emit("skills"))
    # etc...
    
```


### 5. FINAL DELIVERABLE

Write the GDScript code for all the layers mentioned. Then, provide the structural Godot .tscn text representation (or a detailed step-by-step on how the nodes are configured with their anchor presets) so that I can directly implement this modular frontend architecture in my Godot project.