extends Control


func _on_play_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://game_singleplayer.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
