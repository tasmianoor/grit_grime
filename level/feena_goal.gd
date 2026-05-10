extends Node2D

const _THEME: Theme = preload("res://gui/theme.tres")
const HINT_TEXT := "Talk to Feena"
const _COUGH_TEXT := "*cough cough*"
const INTERACT_DISTANCE_PX := 40.0
## When the cough line is visible, place the hint at least this many pixels **above** it (screen-up = lower Y).
const _GAP_HINT_ABOVE_COUGH_PX := 10.0
const _SMOG_GROUP := &"smog_parallax_fade"
## `AnimatedTexture` frame index for `F_sad6.png` (0-based).
const _SAD_FRAME_COUGH := 5

const _IDLE_FRAME_DURATION := 1.0
const _SAD_FRAME_DURATION := 1.4

const _IDLE_PATHS: PackedStringArray = [
	&"res://level/props/Feena/idle/F_idle1.png",
	&"res://level/props/Feena/idle/F_idle2.png",
	&"res://level/props/Feena/idle/F_idle3.png",
]

const _SAD_PATHS: PackedStringArray = [
	&"res://level/props/Feena/sad/F_sad1.png",
	&"res://level/props/Feena/sad/F_sad2.png",
	&"res://level/props/Feena/sad/F_sad3.png",
	&"res://level/props/Feena/sad/F_sad4.png",
	&"res://level/props/Feena/sad/F_sad5.png",
	&"res://level/props/Feena/sad/F_sad6.png",
	&"res://level/props/Feena/sad/F_sad7.png",
]

@onready var _sprite := $Square as Sprite2D

var _hint: Label
var _cough_label: Label
var _done := false
var _idle_texture: AnimatedTexture
var _sad_texture: AnimatedTexture
## Start “wrong” so the first `_apply_smog_visual` always picks sad vs idle from smog state.
var _using_idle := true


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_build_feena_animations()
	_apply_smog_visual()
	_hint = Label.new()
	_hint.theme = _THEME
	_hint.text = HINT_TEXT
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.visible = false
	_hint.z_index = 10
	add_child(_hint)
	_cough_label = Label.new()
	_cough_label.theme = _THEME
	_cough_label.text = _COUGH_TEXT
	_cough_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_cough_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cough_label.visible = false
	_cough_label.z_index = 11
	_cough_label.add_theme_font_size_override(&"font_size", 13)
	_cough_label.add_theme_color_override(&"font_color", Color(1, 1, 1, 1))
	_cough_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
	_cough_label.add_theme_constant_override(&"outline_size", 2)
	add_child(_cough_label)


func _build_feena_animations() -> void:
	_idle_texture = _make_animated_texture(_IDLE_PATHS, _IDLE_FRAME_DURATION)
	_sad_texture = _make_animated_texture(_SAD_PATHS, _SAD_FRAME_DURATION)


func _make_animated_texture(paths: PackedStringArray, frame_duration: float) -> AnimatedTexture:
	var at := AnimatedTexture.new()
	at.frames = paths.size()
	for i in range(paths.size()):
		at.set_frame_texture(i, load(paths[i]) as Texture2D)
		at.set_frame_duration(i, frame_duration)
	return at


func _smog_fade_progress() -> float:
	var n := get_tree().get_first_node_in_group(_SMOG_GROUP)
	if n == null or not n.has_method(&"get_fade_progress"):
		return 1.0
	if n is CanvasItem and not (n as CanvasItem).visible:
		return 1.0
	return clampf(float(n.get_fade_progress()), 0.0, 1.0)


func _apply_smog_visual() -> void:
	var want_idle := _smog_fade_progress() >= 1.0
	if want_idle == _using_idle:
		return
	_using_idle = want_idle
	_sprite.texture = _idle_texture if want_idle else _sad_texture


func _position_hint_label(top_mid: Vector2) -> void:
	_hint.reset_size()
	var half_w := _hint.size.x * 0.5
	if _cough_label.visible:
		var cough_top_y := _cough_label.global_position.y
		_hint.global_position = Vector2(
			top_mid.x - half_w,
			cough_top_y - _GAP_HINT_ABOVE_COUGH_PX - _hint.size.y,
		)
	else:
		_hint.global_position = top_mid - Vector2(half_w, _hint.size.y + 4.0)


func _update_cough_bubble() -> void:
	if _cough_label == null:
		return
	if _done or _using_idle:
		_cough_label.visible = false
		return
	var at := _sprite.texture as AnimatedTexture
	if at != _sad_texture:
		_cough_label.visible = false
		return
	var show_cough := at.current_frame == _SAD_FRAME_COUGH
	_cough_label.visible = show_cough
	if show_cough:
		var a := _feena_world_aabb()
		var top_mid := Vector2(a.position.x + a.size.x * 0.5, a.position.y)
		_cough_label.reset_size()
		_cough_label.global_position = top_mid - Vector2(_cough_label.size.x * 0.5, _cough_label.size.y + 8)


func _physics_process(_delta: float) -> void:
	if _done or Engine.is_editor_hint():
		return
	_apply_smog_visual()
	_update_cough_bubble()
	var tree := get_tree()
	if tree == null or _hint == null:
		return

	var any_in_range := false
	for n in tree.get_nodes_in_group(&"player"):
		if not n is Player:
			continue
		var p := n as Player
		if not is_instance_valid(p):
			continue
		if p.is_holding_trash():
			continue
		if _distance_point_to_feena_aabb(p.global_position) <= INTERACT_DISTANCE_PX:
			any_in_range = true
			break

	_hint.visible = any_in_range
	if any_in_range:
		var a := _feena_world_aabb()
		var top_mid := Vector2(a.position.x + a.size.x * 0.5, a.position.y)
		_position_hint_label(top_mid)

	for n in tree.get_nodes_in_group(&"player"):
		if not n is Player:
			continue
		var p := n as Player
		if not is_instance_valid(p):
			continue
		if p.is_holding_trash():
			continue
		if _distance_point_to_feena_aabb(p.global_position) > INTERACT_DISTANCE_PX:
			continue
		if Input.is_action_just_pressed(&"drop_seed" + p.action_suffix):
			_trigger_complete()
			return


func _feena_world_aabb() -> Rect2:
	var r := _sprite.get_rect()
	var xf := _sprite.get_global_transform()
	var pts: Array[Vector2] = [
		xf * r.position,
		xf * Vector2(r.end.x, r.position.y),
		xf * r.end,
		xf * Vector2(r.position.x, r.end.y),
	]
	var min_x: float = pts[0].x
	var max_x: float = pts[0].x
	var min_y: float = pts[0].y
	var max_y: float = pts[0].y
	for i in range(1, 4):
		var q := pts[i]
		min_x = minf(min_x, q.x)
		max_x = maxf(max_x, q.x)
		min_y = minf(min_y, q.y)
		max_y = maxf(max_y, q.y)
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))


func _distance_point_to_feena_aabb(world_pt: Vector2) -> float:
	var a := _feena_world_aabb()
	var q := Vector2(
		clampf(world_pt.x, a.position.x, a.position.x + a.size.x),
		clampf(world_pt.y, a.position.y, a.position.y + a.size.y),
	)
	return world_pt.distance_to(q)


func _trigger_complete() -> void:
	if _done:
		return
	_done = true
	set_physics_process(false)
	_hint.visible = false
	if is_instance_valid(_cough_label):
		_cough_label.visible = false
	var game := get_tree().get_first_node_in_group(&"game_controller")
	if game != null and game.has_method(&"present_level_complete"):
		game.present_level_complete()
