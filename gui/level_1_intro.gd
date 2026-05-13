extends Control
## Standalone pre-level screen for **Level 1** (no shared template).

const _NEXT_SCENE := "res://game_singleplayer.tscn"
const _CONTENT_BOTTOM_PAD_PX := 36.0
const _BTN_GAP_PX := 10.0
const _CONTINUE_BTN_W := 150.0
const _BTN_H := 44.0
const _DIALOGUE1: Texture2D = preload("res://level/intro/dialogue1.png")
const _DIALOGUE2: Texture2D = preload("res://level/intro/dialogue2.png")

const _ICON_COLOR_KEYS: Array[StringName] = [
	&"icon_normal_color",
	&"icon_hover_color",
	&"icon_pressed_color",
	&"icon_hover_pressed_color",
	&"icon_focus_color",
	&"icon_disabled_color",
]
const _FONT_COLOR_KEYS: Array[StringName] = [
	&"font_color",
	&"font_hover_color",
	&"font_pressed_color",
	&"font_hover_pressed_color",
	&"font_focus_color",
	&"font_disabled_color",
]
const _CONTINUE_FONT_COLOR := Color(0.02, 0.16, 0.42, 1.0)

@onready var _content := $Content as Control
@onready var _dialogue := $Content/DialoguePlate as TextureRect
@onready var _continue := $Content/ContinueButton as Button

var _first_step := true


func _ready() -> void:
	_content.offset_bottom = -_CONTENT_BOTTOM_PAD_PX
	_dialogue.texture = _DIALOGUE1
	if not _dialogue.resized.is_connected(_on_dialogue_resized):
		_dialogue.resized.connect(_on_dialogue_resized)
	if not resized.is_connected(_on_intro_resized):
		resized.connect(_on_intro_resized)
	if not _content.resized.is_connected(_on_content_resized):
		_content.resized.connect(_on_content_resized)
	_apply_first_step_continue()
	await get_tree().process_frame
	_refresh_continue_layout()
	call_deferred(&"_refresh_continue_layout")
	_continue.grab_focus()


func _apply_continue_non_white_font() -> void:
	for key in _FONT_COLOR_KEYS:
		_continue.add_theme_color_override(key, _CONTINUE_FONT_COLOR)


func _on_dialogue_resized() -> void:
	_refresh_continue_layout()


func _on_intro_resized() -> void:
	_refresh_continue_layout()


func _on_content_resized() -> void:
	_refresh_continue_layout()


func _refresh_continue_layout() -> void:
	_layout_continue_under_dialogue(_CONTINUE_BTN_W, _BTN_H)


## Centers **Continue** under **`DialoguePlate`** inside **`Content`** (same parent; **`Content`** ends **`_CONTENT_BOTTOM_PAD_PX`** above the full-screen bottom).
func _layout_continue_under_dialogue(width_px: float, height_px: float) -> void:
	_continue.set_anchors_preset(Control.PRESET_TOP_LEFT)
	var r := _dialogue.get_rect()
	var pos := Vector2(
		r.position.x + r.size.x * 0.5 - width_px * 0.5,
		r.position.y + r.size.y + _BTN_GAP_PX
	)
	var bounds := _content.size
	var max_x := bounds.x - width_px
	var max_y := bounds.y - height_px
	pos.x = clampf(pos.x, 0.0, maxf(0.0, max_x))
	pos.y = clampf(pos.y, 0.0, maxf(0.0, max_y))
	_continue.position = pos
	_continue.size = Vector2(width_px, height_px)
	_continue.visible = true


func _apply_first_step_continue() -> void:
	_first_step = true
	_dialogue.texture = _DIALOGUE1
	_continue.text = "Continue"
	_continue.icon = null
	_continue.expand_icon = false
	_continue.scale = Vector2.ONE
	_continue.custom_minimum_size = Vector2.ZERO
	for key in _ICON_COLOR_KEYS:
		_continue.remove_theme_color_override(key)
	_apply_continue_non_white_font()
	if _continue.has_method(&"refresh_after_content_change"):
		_continue.call(&"refresh_after_content_change")
	_refresh_continue_layout()


func _apply_start_level_button() -> void:
	_first_step = false
	_dialogue.texture = _DIALOGUE2
	for key in _ICON_COLOR_KEYS:
		_continue.remove_theme_color_override(key)
	_apply_continue_non_white_font()
	_continue.icon = null
	_continue.expand_icon = false
	_continue.text = "Start level"
	_continue.scale = Vector2.ONE
	_continue.custom_minimum_size = Vector2.ZERO
	if _continue.has_method(&"refresh_after_content_change"):
		_continue.call(&"refresh_after_content_change")
	_refresh_continue_layout()
	_continue.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_accept"):
		get_viewport().set_input_as_handled()
		_on_continue_pressed()


func _on_continue_pressed() -> void:
	if _first_step:
		_apply_start_level_button()
	else:
		_go_next()


func _go_next() -> void:
	var err: Error = get_tree().change_scene_to_file(_NEXT_SCENE)
	if err != OK:
		push_error("level_1_intro: failed to load %s (error %d)" % [_NEXT_SCENE, err])
