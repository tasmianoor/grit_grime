extends Control

const LEVEL_1_ENTRY_SCENE := "res://game_singleplayer.tscn"
const LEVEL_2_ENTRY_SCENE := "res://game_level_2.tscn"

@onready var _level_1_button := $LevelButton as Button
@onready var _level_2_button := $Level2Button as Button


func _ready() -> void:
	if _level_1_button != null and not _level_1_button.pressed.is_connected(_on_level_pressed):
		_level_1_button.pressed.connect(_on_level_pressed)
	if _level_2_button != null and not _level_2_button.pressed.is_connected(_on_level_2_pressed):
		_level_2_button.pressed.connect(_on_level_2_pressed)


func _on_level_pressed() -> void:
	_open_scene(LEVEL_1_ENTRY_SCENE)


func _on_level_2_pressed() -> void:
	_open_scene(LEVEL_2_ENTRY_SCENE)


func _open_scene(scene_path: String) -> void:
	var err: Error = get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("Failed to open map target scene: %s (error %d)" % [scene_path, err])
