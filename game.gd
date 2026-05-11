class_name Game extends Node

const _SCORE_HUD_SCENE := preload("res://gui/score_hud.tscn")

var _memphis_mission_goals_script: GDScript

@onready var _pause_menu := $InterfaceLayer/PauseMenu as PauseMenu
@onready var _level_complete := $InterfaceLayer/LevelCompleteScreen as LevelCompleteScreen
@onready var _river_splash := $InterfaceLayer/RiverSplashMenu as RiverSplashMenu


func _ready() -> void:
	add_to_group(&"game_controller")
	var hud := _SCORE_HUD_SCENE.instantiate()
	$InterfaceLayer.add_child(hud)


func get_continue_scene_path() -> String:
	var gl := get_tree().get_first_node_in_group(&"game_level") as GameLevel
	if gl != null:
		return gl.next_level_scene
	return ""


func _memphis_mission_goals_script_cached() -> GDScript:
	if _memphis_mission_goals_script == null:
		_memphis_mission_goals_script = load("res://gui/memphis_mission_goals.gd") as GDScript
	return _memphis_mission_goals_script


func present_river_fall() -> void:
	if _river_splash == null or _river_splash.is_blocking() or _level_complete.is_blocking():
		return
	get_tree().paused = true
	_river_splash.open()


func present_level_complete() -> void:
	if _level_complete.is_blocking():
		return
	if _river_splash != null and _river_splash.is_blocking():
		return
	get_tree().paused = true
	var gl_node := get_tree().get_first_node_in_group(&"game_level")
	var title := "Level"
	var level_index := 1
	if gl_node != null:
		var name_raw: Variant = gl_node.get(&"level_display_name")
		if name_raw != null:
			title = String(name_raw)
		var idx_raw: Variant = gl_node.get(&"level_index")
		level_index = 1 if idx_raw == null else int(idx_raw)
	var stars_filled := 0
	var star_feedback := ""
	var goals := _memphis_mission_goals_script_cached()
	var memphis_title := String(goals.call(&"display_name"))
	if title == memphis_title and gl_node != null:
		var pack: Dictionary = goals.call(
			&"level1_completion_stars_and_message",
			get_tree(),
			gl_node
		) as Dictionary
		stars_filled = int(pack.get(&"stars", 0))
		var msg_raw: Variant = pack.get(&"message", "")
		star_feedback = "" if msg_raw == null else String(msg_raw)
	elif gl_node != null and (gl_node as Object).has_method(&"get_completion_stars_and_message"):
		var pack2: Variant = (gl_node as Object).call(
			&"get_completion_stars_and_message",
			get_tree()
		)
		if typeof(pack2) == TYPE_DICTIONARY:
			var d := pack2 as Dictionary
			stars_filled = int(d.get(&"stars", 0))
			var msg2: Variant = d.get(&"message", "")
			star_feedback = "" if msg2 == null else String(msg2)
	_level_complete.present(level_index, title, stars_filled, star_feedback)


func _unhandled_input(event: InputEvent) -> void:
	if _river_splash != null and _river_splash.is_blocking():
		if event.is_action_pressed(&"toggle_pause"):
			get_tree().root.set_input_as_handled()
		return
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
