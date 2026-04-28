extends Control

const MAP_SCENE_PATH := "res://map/map.tscn"


func _on_start_cta_pressed() -> void:
	get_tree().change_scene_to_file(MAP_SCENE_PATH)
