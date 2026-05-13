class_name PauseMenu extends Control


@export var fade_in_duration := 0.3
@export var fade_out_duration := 0.2
const MAP_SCENE_PATH := "res://map/map.tscn"

const _KEYBOARD_HELP_ROWS: Array[Dictionary] = [
	{&"action": &"move_left", &"label": "Move left"},
	{&"action": &"move_right", &"label": "Move right"},
	{&"action": &"move_up", &"label": "Move up"},
	{&"action": &"move_down", &"label": "Move down"},
	{&"action": &"jump", &"label": "Jump"},
	{&"action": &"drop_seed", &"label": "Plant / interact"},
	{&"action": &"toggle_pause", &"label": "Pause"},
]

@onready var center_cont := $ColorRect/CenterContainer as CenterContainer
@onready var resume_button := center_cont.get_node(^"VBoxContainer/ResumeButton") as Button
@onready var _player_controls_label := center_cont.get_node(^"VBoxContainer/PlayerControlsLabel") as Label


func _ready() -> void:
	hide()
	_player_controls_label.text = _build_keyboard_controls_help()
	_update_player_controls_width()
	get_viewport().size_changed.connect(_update_player_controls_width)


func _update_player_controls_width() -> void:
	var w := get_viewport().get_visible_rect().size.x / 3.0
	_player_controls_label.custom_minimum_size.x = w


func _keyboard_keys_for_action(action: StringName) -> PackedStringArray:
	var out: PackedStringArray = []
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			var key_ev := ev as InputEventKey
			var code := key_ev.physical_keycode
			if code == KEY_NONE:
				code = key_ev.keycode
			if code != KEY_NONE:
				var key_name := OS.get_keycode_string(code)
				if key_name == "Escape":
					key_name = "Esc"
				out.append(key_name)
	return out


func _build_keyboard_controls_help() -> String:
	var lines: PackedStringArray = []
	for row in _KEYBOARD_HELP_ROWS:
		var action: StringName = row[&"action"]
		var label: String = row[&"label"]
		var keys := _keyboard_keys_for_action(action)
		if keys.is_empty():
			continue
		lines.append("%s: %s" % [label, " / ".join(keys)])
	return "\n".join(lines)


func close() -> void:
	var tween := create_tween()
	get_tree().paused = false
	tween.tween_property(
		self,
		^"modulate:a",
		0.0,
		fade_out_duration
	).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(
		center_cont,
		^"anchor_bottom",
		0.5,
		fade_out_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_callback(hide)


func open() -> void:
	show()
	resume_button.grab_focus()

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


func _on_resume_button_pressed() -> void:
	close()


func _on_restart_button_pressed() -> void:
	if visible:
		get_tree().paused = false
		get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	if visible:
		get_tree().paused = false
		get_tree().change_scene_to_file(MAP_SCENE_PATH)
