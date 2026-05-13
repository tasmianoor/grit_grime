extends CanvasLayer
## Global mute control: **Sound OFF** mutes the Master bus; **Sound ON** restores it.
## Top-right by default; during L1/L2 mission HUD, sits just left of the mission panel.

const _MISSION_GROUP := &"mission_hud_panel"
const _THEME: Theme = preload("res://gui/theme.tres")
const _SPLASH_BTN: GDScript = preload("res://gui/splash_screen_button.gd")

const _LAYER := 125
const _MARGIN_R := 12.0
const _MARGIN_T := 8.0
const _MARGIN_L_MIN := 8.0
const _GAP_MISSION := 8.0

var _root: Control
var _button: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = _LAYER

	_root = Control.new()
	_root.theme = _THEME
	_root.process_mode = Node.PROCESS_MODE_ALWAYS
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_button = Button.new()
	_button.process_mode = Node.PROCESS_MODE_ALWAYS
	_button.mouse_filter = Control.MOUSE_FILTER_STOP
	_button.focus_mode = Control.FOCUS_NONE
	_button.set_script(_SPLASH_BTN)
	_root.add_child(_button)
	_button.pressed.connect(_on_pressed)
	_sync_label()


func _process(_delta: float) -> void:
	_layout_button()


func _get_master_bus_index() -> int:
	return AudioServer.get_bus_index(&"Master")


func _sync_label() -> void:
	var idx := _get_master_bus_index()
	var muted := idx >= 0 and AudioServer.is_bus_mute(idx)
	_button.text = "Sound ON" if muted else "Sound OFF"
	if _button.has_method(&"refresh_after_content_change"):
		_button.call(&"refresh_after_content_change")


func _on_pressed() -> void:
	var idx := _get_master_bus_index()
	if idx < 0:
		return
	AudioServer.set_bus_mute(idx, not AudioServer.is_bus_mute(idx))
	_sync_label()


func _layout_button() -> void:
	if not is_instance_valid(_button):
		return
	var vp_sz := get_viewport().get_visible_rect().size
	var mission := get_tree().get_first_node_in_group(_MISSION_GROUP) as Control
	var use_left_of_mission := false
	var gr := Rect2()
	if mission != null and is_instance_valid(mission) and mission.is_visible_in_tree():
		gr = mission.get_global_rect()
		use_left_of_mission = gr.size.x > 4.0 and gr.position.x > 4.0

	var sz := _button.get_combined_minimum_size()
	var tw := sz.x
	var th := sz.y

	if use_left_of_mission and is_instance_valid(mission):
		gr = mission.get_global_rect()
		var x := gr.position.x - _GAP_MISSION - tw
		x = clampf(x, _MARGIN_L_MIN, vp_sz.x - _MARGIN_R - tw)
		_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		_button.offset_left = x
		_button.offset_top = _MARGIN_T
		_button.offset_right = x + tw
		_button.offset_bottom = _MARGIN_T + th
	else:
		_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		_button.offset_top = _MARGIN_T
		_button.offset_bottom = _MARGIN_T + th
		_button.offset_right = -_MARGIN_R
		_button.offset_left = _button.offset_right - tw
