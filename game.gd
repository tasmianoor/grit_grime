class_name Game extends Node

const _SCORE_HUD_SCENE := preload("res://gui/score_hud.tscn")

@onready var _pause_menu := $InterfaceLayer/PauseMenu as PauseMenu
@onready var _level_complete := $InterfaceLayer/LevelCompleteScreen as LevelCompleteScreen


func _ready() -> void:
	add_to_group(&"game_controller")
	var hud := _SCORE_HUD_SCENE.instantiate()
	$InterfaceLayer.add_child(hud)


func get_continue_scene_path() -> String:
	var gl := get_tree().get_first_node_in_group(&"game_level") as GameLevel
	if gl != null:
		return gl.next_level_scene
	return ""


func present_level_complete() -> void:
	if _level_complete.is_blocking():
		return
	get_tree().paused = true
	var gl := get_tree().get_first_node_in_group(&"game_level") as GameLevel
	var title := "Level"
	var max_pts := 0
	if gl != null:
		title = gl.level_display_name
		max_pts = gl.get_max_achievable_points()
	var earned := _total_player_score()
	_level_complete.present(title, earned, max_pts)


func _total_player_score() -> int:
	var total := 0
	for n in get_tree().get_nodes_in_group(&"player"):
		if n is Player:
			total += (n as Player).score
	return total


func _unhandled_input(event: InputEvent) -> void:
	if _level_complete.is_blocking():
		return
	if event.is_action_pressed(&"toggle_fullscreen"):
		var mode := DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or \
				mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_tree().root.set_input_as_handled()

	elif event.is_action_pressed(&"toggle_pause"):
		var tree := get_tree()
		tree.paused = not tree.paused
		if tree.paused:
			_pause_menu.open()
		else:
			_pause_menu.close()
		get_tree().root.set_input_as_handled()
