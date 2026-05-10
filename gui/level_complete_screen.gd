class_name LevelCompleteScreen extends Control

const _WORLD_MAP := "res://gui/world_map.tscn"
const _MEMPHIS_L1_NAME := "Memphis Riverfront"

@export var fade_in_duration := 0.3
@export var fade_out_duration := 0.2

@onready var center_cont := $ColorRect/CenterContainer as CenterContainer
@onready var retry_button := center_cont.get_node(^"VBoxContainer/RetryButton") as Button
@onready var level_name_label := center_cont.get_node(^"VBoxContainer/LevelNameLabel") as Label
@onready var points_label := center_cont.get_node(^"VBoxContainer/PointsLabel") as Label

var _blocking := false


func _ready() -> void:
	hide()


func is_blocking() -> bool:
	return _blocking


func present(level_title: String, earned: int, possible: int) -> void:
	_blocking = true
	level_name_label.text = level_title
	if level_title == _MEMPHIS_L1_NAME:
		points_label.visible = false
	else:
		points_label.visible = true
		points_label.text = "%d / %d points" % [earned, possible]
	show()
	retry_button.grab_focus()

	modulate.a = 0.0
	center_cont.anchor_bottom = 0.5
	var tween := create_tween()
	tween.tween_property(
		self,
		^"modulate:a",
		1.0,
		fade_in_duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(
		center_cont,
		^"anchor_bottom",
		1.0,
		fade_out_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _dismiss_immediate() -> void:
	get_tree().paused = false
	_blocking = false
	modulate.a = 1.0
	center_cont.anchor_bottom = 1.0
	hide()


func _on_retry_button_pressed() -> void:
	if not _blocking:
		return
	_dismiss_immediate()
	get_tree().reload_current_scene()


func _on_continue_button_pressed() -> void:
	if not _blocking:
		return
	var game := get_tree().get_first_node_in_group(&"game_controller")
	var next_path := ""
	if game != null and game.has_method(&"get_continue_scene_path"):
		next_path = str(game.get_continue_scene_path())
	if next_path.is_empty():
		next_path = _WORLD_MAP
	_dismiss_immediate()
	get_tree().change_scene_to_file(next_path)


func _on_back_to_map_button_pressed() -> void:
	if not _blocking:
		return
	_dismiss_immediate()
	get_tree().change_scene_to_file(_WORLD_MAP)
