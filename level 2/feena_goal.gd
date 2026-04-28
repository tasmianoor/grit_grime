extends Node2D

const _THEME: Theme = preload("res://gui/theme.tres")
const HINT_TEXT := "Talk to Feena"
const INTERACT_DISTANCE_PX := 40.0

@onready var _sprite := $Square as Sprite2D

var _hint: Label
var _done := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_hint = Label.new()
	_hint.theme = _THEME
	_hint.text = HINT_TEXT
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.visible = false
	_hint.z_index = 10
	add_child(_hint)


func _physics_process(_delta: float) -> void:
	if _done or Engine.is_editor_hint():
		return
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
		if _distance_point_to_feena_aabb(p.global_position) <= INTERACT_DISTANCE_PX:
			any_in_range = true
			break

	_hint.visible = any_in_range
	if any_in_range:
		var a := _feena_world_aabb()
		var top_mid := Vector2(a.position.x + a.size.x * 0.5, a.position.y)
		_hint.reset_size()
		_hint.global_position = top_mid - Vector2(_hint.size.x * 0.5, _hint.size.y + 4)

	for n in tree.get_nodes_in_group(&"player"):
		if not n is Player:
			continue
		var p := n as Player
		if not is_instance_valid(p):
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
	var game := get_tree().get_first_node_in_group(&"game_controller")
	if game != null and game.has_method(&"present_level_complete"):
		game.present_level_complete()
