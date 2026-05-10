class_name RiverSplashMenu extends Control

const MAP_SCENE_PATH := "res://map/map.tscn"

@export var fade_in_duration := 0.3
@export var fade_out_duration := 0.2

@onready var center_cont := $ColorRect/CenterContainer as CenterContainer
@onready var retry_button := center_cont.get_node(^"VBoxContainer/RetryButton") as Button

var _blocking := false


func _ready() -> void:
	hide()


func is_blocking() -> bool:
	return _blocking


func open() -> void:
	if _blocking:
		return
	_blocking = true
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


func _dismiss() -> void:
	get_tree().paused = false
	_blocking = false
	modulate.a = 1.0
	center_cont.anchor_bottom = 1.0
	hide()


func _on_retry_button_pressed() -> void:
	if not _blocking:
		return
	_dismiss()
	get_tree().reload_current_scene()


func _on_back_to_map_button_pressed() -> void:
	if not _blocking:
		return
	_dismiss()
	get_tree().change_scene_to_file(MAP_SCENE_PATH)


func _on_exit_game_button_pressed() -> void:
	if not _blocking:
		return
	_dismiss()
	get_tree().quit()
