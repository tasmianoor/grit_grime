class_name LevelCompleteScreen extends Control

const _LEVEL_SELECT_MAP := "res://map/map.tscn"
const _STAR_FILLED := Color(0.992157, 0.729412, 0.129412, 1)
const _STAR_EMPTY := Color(0.2, 0.22, 0.26, 1)

@export var fade_in_duration := 0.3
@export var fade_out_duration := 0.2

@onready var center_cont := $ColorRect/CenterContainer as CenterContainer
@onready var retry_button := center_cont.get_node(^"VBoxContainer/RetryButton") as Button
@onready var continue_button := center_cont.get_node(^"VBoxContainer/ContinueButton") as Button
@onready var level_heading_label := center_cont.get_node(^"VBoxContainer/LevelHeadingLabel") as Label
@onready var complete_line_label := center_cont.get_node(^"VBoxContainer/CompleteLineLabel") as Label
@onready var _star_row := center_cont.get_node(^"VBoxContainer/StarsRow") as HBoxContainer
@onready var _star_feedback_label := center_cont.get_node(^"VBoxContainer/StarFeedbackLabel") as Label

var _blocking := false
var _star_labels: Array[Label] = []


func _ready() -> void:
	for c in _star_row.get_children():
		if c is Label:
			_star_labels.append(c as Label)
	hide()


func is_blocking() -> bool:
	return _blocking


func present(
	level_index: int,
	level_display_name: String,
	stars_filled: int = 0,
	star_feedback: String = ""
) -> void:
	_blocking = true
	level_heading_label.text = "Level %d: %s" % [level_index, level_display_name]
	complete_line_label.text = "Level complete!"
	_apply_star_row(stars_filled)
	_star_feedback_label.text = star_feedback
	_star_feedback_label.visible = not star_feedback.is_empty()
	var show_continue := stars_filled >= 2
	continue_button.visible = show_continue
	show()
	if show_continue:
		continue_button.grab_focus()
	else:
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


func _apply_star_row(filled_count: int) -> void:
	var n := clampi(filled_count, 0, _star_labels.size())
	for i in range(_star_labels.size()):
		var lab := _star_labels[i]
		var col := _STAR_FILLED if i < n else _STAR_EMPTY
		lab.add_theme_color_override(&"font_color", col)


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
		next_path = _LEVEL_SELECT_MAP
	_dismiss_immediate()
	get_tree().change_scene_to_file(next_path)


func _on_back_to_map_button_pressed() -> void:
	if not _blocking:
		return
	_dismiss_immediate()
	get_tree().change_scene_to_file(_LEVEL_SELECT_MAP)
