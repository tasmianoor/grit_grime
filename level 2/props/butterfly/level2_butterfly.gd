extends Sprite2D
## One **bfly** critter: wing cycle **bfly1–4**, flies in from the left, then floats like money notes (**`post_interaction_celebration.gd`**) inside the **bottom half** of **BStreet** — same **`sin(phase * freq + offset) * half`** pattern so motion never stops.

const _FRAMES: Array[Texture2D] = [
	preload("res://level 2/props/butterfly/bfly1.png"),
	preload("res://level 2/props/butterfly/bfly2.png"),
	preload("res://level 2/props/butterfly/bfly3.png"),
	preload("res://level 2/props/butterfly/bfly4.png"),
]

const _LEVEL_LIMIT_LEFT := -1200.0
const _LEVEL_LIMIT_TOP := -250.0
const _LEVEL_LIMIT_RIGHT := 2200.0
const _LEVEL_LIMIT_BOTTOM := 1050.0
const _LEVEL_PAD := 80.0
## Same **`z_index`** as **`post_interaction_celebration.gd`** **`_note_holder`** so butterflies sort with floating notes.
const _NOTE_MATCH_Z := 24

@export var wing_frame_sec := 0.08
@export var fly_duration_sec := 4.2
@export var butterfly_height_px := 28.0
@export var wander_rect_margin_px := 18.0

var _frame_i := 0
var _anim_accum := 0.0
var _slot := 0

var _wandering := false
## Same role as each note entry’s **`phase`** (accumulates forever).
var _float_phase := 0.0
var _float_mid := Vector2.ZERO
var _float_half := Vector2.ZERO
var _freq_x := 0.14
var _freq_y := 0.15
var _off_x := 0.0
var _off_y := 0.0


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	add_to_group(&"level2_monarch_butterfly")
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	centered = true
	z_as_relative = true
	z_index = _NOTE_MATCH_Z
	texture = _FRAMES[0]
	_apply_frame_scale()


func _apply_frame_scale() -> void:
	var tex := _FRAMES[0]
	var th := float(tex.get_height())
	var s := butterfly_height_px / maxf(1.0, th)
	scale = Vector2(s, s)


func setup_flight(slot: int) -> void:
	if Engine.is_editor_hint():
		return
	_slot = slot
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(global_position) + int(slot) * 911382323
	var y0 := 200.0 + float(slot) * 72.0 + rng.randf_range(-28.0, 28.0)
	var x_start := _LEVEL_LIMIT_LEFT - 160.0 - float(slot) * 50.0
	var x_end := 380.0 + float(slot) * 210.0 + rng.randf_range(0.0, 260.0)
	var y1 := y0 + rng.randf_range(-50.0, 50.0)
	global_position = Vector2(x_start, y0)
	_apply_frame_scale()
	var tw := create_tween()
	tw.tween_interval(0.16 * float(slot))
	tw.tween_property(self, "global_position", Vector2(x_end, y1), fly_duration_sec).set_trans(
		Tween.TRANS_SINE
	).set_ease(Tween.EASE_OUT)
	tw.finished.connect(_on_entry_flight_finished, CONNECT_ONE_SHOT)


func _on_entry_flight_finished() -> void:
	_start_wandering_near_bstreet_bottom()


func _sprite_world_aabb(spr: Sprite2D) -> Rect2:
	var r := spr.get_rect()
	var xf := spr.get_global_transform()
	var min_x := INF
	var min_y := INF
	var max_x := -INF
	var max_y := -INF
	for corner in [
		r.position,
		Vector2(r.end.x, r.position.y),
		r.end,
		Vector2(r.position.x, r.end.y),
	]:
		var wp: Vector2 = xf * corner
		min_x = minf(min_x, wp.x)
		min_y = minf(min_y, wp.y)
		max_x = maxf(max_x, wp.x)
		max_y = maxf(max_y, wp.y)
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)


func _fallback_wander_rect() -> Rect2:
	var L := _LEVEL_LIMIT_LEFT + _LEVEL_PAD
	var T := _LEVEL_LIMIT_TOP + _LEVEL_PAD
	var R := _LEVEL_LIMIT_RIGHT - _LEVEL_PAD
	var B := _LEVEL_LIMIT_BOTTOM - _LEVEL_PAD
	var full := Rect2(L, T, R - L, B - T)
	var mid_y := full.position.y + full.size.y * 0.5
	return Rect2(full.position.x, mid_y, full.size.x, full.position.y + full.size.y - mid_y)


func _bstreet_bottom_half_world_rect() -> Rect2:
	var lv := get_tree().get_first_node_in_group(&"game_level") as Node2D
	if lv == null:
		return _fallback_wander_rect()
	var bs := lv.get_node_or_null(^"BStreet") as Sprite2D
	if bs == null or bs.texture == null:
		return _fallback_wander_rect()
	var aabb := _sprite_world_aabb(bs)
	if aabb.size.x <= 1.0 or aabb.size.y <= 1.0:
		return _fallback_wander_rect()
	var mid_y := aabb.position.y + aabb.size.y * 0.5
	return Rect2(aabb.position.x, mid_y, aabb.size.x, aabb.position.y + aabb.size.y - mid_y)


func _start_wandering_near_bstreet_bottom() -> void:
	var wr := _bstreet_bottom_half_world_rect()
	var m := wander_rect_margin_px
	wr = wr.grow_individual(-m, -m, -m, -m)
	if wr.size.x < 32.0 or wr.size.y < 24.0:
		wr = _bstreet_bottom_half_world_rect()
	_float_mid = wr.get_center()
	# Same scaling idea as notes: **`_note_float_half = nb.size * 0.5`** — Lissajous stays inside the rect.
	_float_half = wr.size * 0.5
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(_float_mid) + int(_slot) * 140002471
	# Match **`post_interaction_celebration.gd`** note **`freq_x` / `freq_y`** ranges.
	_freq_x = rng.randf_range(0.085, 0.2)
	_freq_y = rng.randf_range(0.095, 0.22)
	_off_x = rng.randf() * TAU
	_off_y = rng.randf() * TAU
	_float_phase = rng.randf() * TAU
	_wandering = true


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or _FRAMES.is_empty():
		return
	_anim_accum += delta
	var step := wing_frame_sec
	if step > 0.0:
		while _anim_accum >= step:
			_anim_accum -= step
			_frame_i = (_frame_i + 1) % _FRAMES.size()
	texture = _FRAMES[_frame_i]
	if not _wandering:
		return
	# Same order as **`_float_money_notes_phase`** **`_process`**: advance phase, then position.
	_float_phase += delta
	global_position = _float_mid + Vector2(
		sin(_float_phase * _freq_x + _off_x) * _float_half.x,
		sin(_float_phase * _freq_y + _off_y) * _float_half.y,
	)
