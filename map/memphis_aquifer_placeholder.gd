extends Control

const _MAP_SCENE := "res://map/map.tscn"


func _ready() -> void:
	var back := get_node_or_null(^"CenterTexts/CenterContainer/VBox/BackButton") as Button
	if back != null and not back.pressed.is_connected(_on_back_pressed):
		back.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	var err: Error = get_tree().change_scene_to_file(_MAP_SCENE)
	if err != OK:
		push_error("MemphisAquiferPlaceholder: failed to return to map (error %d)" % err)
