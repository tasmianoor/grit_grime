extends Node2D

const _THEME: Theme = preload("res://gui/theme.tres")
const HINT_TEXT := "Talk to Bruno"
const INTERACT_DISTANCE_PX := 40.0

## Fallback when no `player` is in the tree yet (e.g. editor): `player.gd` HD strip × default root scale only.
const _PLAYER_SPRITE_WORLD_H_FALLBACK := 64.0 * 0.8
const _BRUNO_TEX_PIXEL_H := 377.0
## Bruno’s **world height** vs Lawrence’s **measured on-screen** sprite height (includes e.g. `game_level_2` Player `scale` ~1.46).
const _BRUNO_HEIGHT_VS_LAWRENCE := 1.25
const _HINT_FONT_SIZE := 15

## 1.6 = transitions **60% slower** (each frame held 60% longer).
const _SPRITE_TRANSITION_SLOWDOWN := 1.6
const _WIPE_FRAME_DURATION := 0.11 * _SPRITE_TRANSITION_SLOWDOWN
const _IDLE_FRAME_DURATION := 0.32 * _SPRITE_TRANSITION_SLOWDOWN
const _WIPE_LOOP_COUNT := 4
const _WIPE_FRAME_COUNT := 6
const _IDLE_FRAME_COUNT := 4

const _WIPE_TEX: Array[Texture2D] = [
	preload("res://level 2/props/Bruno/wipe/wipe1.png"),
	preload("res://level 2/props/Bruno/wipe/wipe2.png"),
	preload("res://level 2/props/Bruno/wipe/wipe3.png"),
	preload("res://level 2/props/Bruno/wipe/wipe4.png"),
	preload("res://level 2/props/Bruno/wipe/wipe5.png"),
	preload("res://level 2/props/Bruno/wipe/wipe6.png"),
]

const _IDLE_TEX: Array[Texture2D] = [
	preload("res://level 2/props/Bruno/idle/idle1.png"),
	preload("res://level 2/props/Bruno/idle/idle2.png"),
	preload("res://level 2/props/Bruno/idle/idle3.png"),
	preload("res://level 2/props/Bruno/idle/idle4.png"),
]

## If **true**, Bruno’s art is mirrored on **X** (**`Sprite2D.flip_h`**).
@export var flip_sprite_horizontally := true

@onready var _sprite := $Square as Sprite2D

var _hint: Label
var _done := false
var _phase_idle := false
var _frame_index := 0
var _frame_time := 0.0
var _wipe_loops_done := 0


func _sprite_world_aabb_height(spr: Sprite2D) -> float:
	var r := spr.get_rect()
	var xf := spr.get_global_transform()
	var min_y := INF
	var max_y := -INF
	for corner in [
		xf * r.position,
		xf * Vector2(r.end.x, r.position.y),
		xf * r.end,
		xf * Vector2(r.position.x, r.end.y),
	]:
		min_y = minf(min_y, corner.y)
		max_y = maxf(max_y, corner.y)
	return maxf(0.0, max_y - min_y)


func _lawrence_on_screen_height_world() -> float:
	var best := 0.0
	var tree := get_tree()
	if tree == null:
		return best
	for n in tree.get_nodes_in_group(&"player"):
		if not n is Node2D:
			continue
		var spr := n.get_node_or_null(^"Sprite2D") as Sprite2D
		if spr == null or not spr.is_inside_tree():
			continue
		best = maxf(best, _sprite_world_aabb_height(spr))
	return best


func _apply_bruno_sprite_visual() -> void:
	var lawrence_h := _lawrence_on_screen_height_world()
	if lawrence_h <= 0.001:
		lawrence_h = _PLAYER_SPRITE_WORLD_H_FALLBACK
	var target_h := lawrence_h * _BRUNO_HEIGHT_VS_LAWRENCE
	var s := target_h / _BRUNO_TEX_PIXEL_H
	_sprite.scale = Vector2(s, s)
	_sprite.flip_h = flip_sprite_horizontally
	_sprite.texture = _WIPE_TEX[0]


func _ready() -> void:
	_apply_bruno_sprite_visual()
	# Player is often a **sibling** of `Level` under `Game`, so measure again next frame once transforms exist.
	call_deferred(&"_apply_bruno_sprite_visual")
	call_deferred(&"_move_finish_line_after_t8_for_draw_order")
	if Engine.is_editor_hint():
		return
	_hint = Label.new()
	_hint.theme = _THEME
	_hint.text = HINT_TEXT
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.visible = false
	_hint.z_index = 10
	_hint.top_level = true
	_hint.add_theme_font_size_override(&"font_size", _HINT_FONT_SIZE)
	_hint.add_theme_color_override(&"font_color", Color(1, 1, 1, 1))
	_hint.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
	_hint.add_theme_constant_override(&"outline_size", 3)
	add_child(_hint)


## **`Trees/T8`** used **`z_index = 10`** and overlaps Bruno’s **X** range while **`FinishLine`** is **`z_index = 4`**, so Bruno was fully painted under the tree. With **T8** brought to **4**, move **FinishLine** to just after **T8** so Bruno draws **above** that tree but still **below** Lawrence (**`z_index = 5`**).
func _move_finish_line_after_t8_for_draw_order() -> void:
	var p := get_parent()
	if p == null:
		return
	var t8 := p.get_node_or_null(^"Trees/T8")
	if t8 == null:
		return
	var want := t8.get_index() + 1
	want = mini(want, p.get_child_count() - 1)
	if get_index() == want:
		return
	p.move_child(self, want)


func _process(delta: float) -> void:
	if _done or Engine.is_editor_hint():
		return
	_frame_time += delta
	var dur := _IDLE_FRAME_DURATION if _phase_idle else _WIPE_FRAME_DURATION
	if _frame_time < dur:
		return
	_frame_time = 0.0
	if not _phase_idle:
		_frame_index += 1
		if _frame_index >= _WIPE_FRAME_COUNT:
			_frame_index = 0
			_wipe_loops_done += 1
			if _wipe_loops_done >= _WIPE_LOOP_COUNT:
				_phase_idle = true
				_wipe_loops_done = 0
				_frame_index = 0
				_sprite.texture = _IDLE_TEX[0]
				return
		_sprite.texture = _WIPE_TEX[_frame_index]
	else:
		_frame_index += 1
		if _frame_index >= _IDLE_FRAME_COUNT:
			_phase_idle = false
			_frame_index = 0
			_sprite.texture = _WIPE_TEX[0]
			return
		_sprite.texture = _IDLE_TEX[_frame_index]


func _physics_process(_delta: float) -> void:
	if _done or Engine.is_editor_hint():
		return
	var tree := get_tree()
	if tree == null or _hint == null:
		return

	var any_in_range := false
	for n in tree.get_nodes_in_group(&"player"):
		if not n is Node2D:
			continue
		var p := n as Node2D
		if not is_instance_valid(p):
			continue
		if not p.has_method(&"is_holding_trash"):
			continue
		if bool(p.call(&"is_holding_trash")):
			continue
		if _distance_point_to_bruno_aabb(p.global_position) <= INTERACT_DISTANCE_PX:
			any_in_range = true
			break

	_hint.visible = any_in_range
	if any_in_range:
		var a := _bruno_world_aabb()
		var top_mid := Vector2(a.position.x + a.size.x * 0.5, a.position.y)
		_hint.reset_size()
		_hint.global_position = top_mid - Vector2(_hint.size.x * 0.5, _hint.size.y + 4.0)

	for n in tree.get_nodes_in_group(&"player"):
		if not n is Node2D:
			continue
		var p := n as Node2D
		if not is_instance_valid(p):
			continue
		if not p.has_method(&"is_holding_trash"):
			continue
		if bool(p.call(&"is_holding_trash")):
			continue
		if _distance_point_to_bruno_aabb(p.global_position) > INTERACT_DISTANCE_PX:
			continue
		var sfx := str(p.get(&"action_suffix"))
		if Input.is_action_just_pressed(&"drop_seed" + sfx):
			_trigger_complete()
			return


func _bruno_world_aabb() -> Rect2:
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


func _distance_point_to_bruno_aabb(world_pt: Vector2) -> float:
	var a := _bruno_world_aabb()
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
	set_process(false)
	_hint.visible = false
	var game := get_tree().get_first_node_in_group(&"game_controller")
	if game != null and game.has_method(&"present_level_complete"):
		game.present_level_complete()
