extends Node2D
## Heron: drops **straight down** from above the camera onto **`heron_land_anchor`** (**`Vector2`**).
## From **`HeronAmbient`**: **`HeronLandingSpot.global_position`** (**X** and **Y**) when the marker exists; else **`(land_world_x, NaN)`** and **Y** from ground raycast at **X**.
## Then **4× idle** → **1× pickup** → repeat.

const _FLY_FRAMES: Array[Texture2D] = [
	preload("res://level/props/birds/Heron/fly/Heron_fly1.png"),
	preload("res://level/props/birds/Heron/fly/Heron_fly2.png"),
	preload("res://level/props/birds/Heron/fly/Heron_fly3.png"),
	preload("res://level/props/birds/Heron/fly/Heron_fly4.png"),
	preload("res://level/props/birds/Heron/fly/Heron_fly5.png"),
	preload("res://level/props/birds/Heron/fly/Heron_fly6.png"),
]

const _LAND_TEX: Texture2D = preload("res://level/props/birds/Heron/fly/Heron_fly6.png")

const _IDLE_FRAMES: Array[Texture2D] = [
	preload("res://level/props/birds/Heron/idle/Heron_idle1.png"),
	preload("res://level/props/birds/Heron/idle/Heron_idle2.png"),
	preload("res://level/props/birds/Heron/idle/Heron_idle3.png"),
]

const _PICKUP_FRAMES: Array[Texture2D] = [
	preload("res://level/props/birds/Heron/pickup/Heron_pickup2.png"),
	preload("res://level/props/birds/Heron/pickup/Heron_pickup3.png"),
]

const _WORLD_COLLISION_MASK := 24
const _FALLBACK_GROUND_Y := 640.0
const _OFFSCREEN_MARGIN := 96.0
const _FLY_DURATION_SEC := 4.2
const _FLY_FRAME_SEC := 0.14
const _LAND_HOLD_SEC := 0.75
const _IDLE_FRAME_SEC := 0.62
const _PICKUP_FRAME_SEC := 0.62
const _IDLE_ROUNDS_BEFORE_PICKUP := 4
const _PICKUP_ROUNDS_BEFORE_IDLE := 1
const _HERON_TEX_SCALE := 1.0 / 3.0

enum _Phase { FLY_IN, LAND_HOLD, GROUND }

var _sprite := Sprite2D.new()
var _phase: _Phase = _Phase.FLY_IN
var _fly_start: Vector2
var _fly_end: Vector2
var _fly_t := 0.0
var _fly_frame_i := 0
var _fly_anim_acc := 0.0
var _land_timer := 0.0
var _ground_frame_i := 0
var _ground_frame_acc := 0.0
var _idle_rounds_done := 0
var _pickup_rounds_done := 0
var _ground_is_pickup := false
var _delay_left := 0.0


func _ready() -> void:
	z_index = 5
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.centered = true
	_sprite.scale = Vector2(_HERON_TEX_SCALE, _HERON_TEX_SCALE)
	add_child(_sprite)


func begin_flight(delay_sec: float) -> void:
	_delay_left = maxf(0.0, delay_sec)
	_phase = _Phase.FLY_IN
	var rect := _camera_world_rect()
	var land_x: float
	var land_y: float
	if has_meta(&"heron_land_anchor"):
		var anchor := get_meta(&"heron_land_anchor") as Vector2
		land_x = anchor.x
		if is_nan(anchor.y):
			land_y = _query_ground_y_at_x(land_x, rect.position.y)
		else:
			land_y = anchor.y
	else:
		land_x = float(get_meta(&"heron_land_world_x", -88.0))
		land_y = _query_ground_y_at_x(land_x, rect.position.y)
	_fly_end = Vector2(land_x, land_y)
	_fly_start = Vector2(land_x, rect.position.y - _OFFSCREEN_MARGIN)
	_fly_t = 0.0
	_fly_frame_i = 0
	_fly_anim_acc = 0.0
	global_position = _fly_start
	_face_toward(-1.0)
	_set_fly_frame(0)


func _camera_world_rect() -> Rect2:
	var vp := get_viewport()
	if vp == null:
		return Rect2(-400.0, -200.0, 1600.0, 900.0)
	var cam := vp.get_camera_2d() as Camera2D
	if cam == null:
		return Rect2(-400.0, -200.0, 1600.0, 900.0)
	var half := vp.get_visible_rect().size / (cam.zoom * 2.0)
	var center := cam.get_screen_center_position()
	return Rect2(center - half, half * 2.0)


func _query_ground_y_at_x(world_x: float, search_top_y: float) -> float:
	var space := get_world_2d().direct_space_state if is_inside_tree() else null
	if space == null:
		return _FALLBACK_GROUND_Y
	var from := Vector2(world_x, search_top_y - 400.0)
	var to := Vector2(world_x, 2000.0)
	var q := PhysicsRayQueryParameters2D.create(from, to)
	q.collision_mask = _WORLD_COLLISION_MASK
	var hit := space.intersect_ray(q)
	if hit.is_empty():
		return _FALLBACK_GROUND_Y
	return float(hit.position.y)


func _face_toward(dx: float) -> void:
	if absf(dx) < 0.01:
		return
	_sprite.flip_h = dx < 0.0


func _set_fly_frame(i: int) -> void:
	_fly_frame_i = clampi(i, 0, _FLY_FRAMES.size() - 1)
	_sprite.texture = _FLY_FRAMES[_fly_frame_i]
	_sprite.offset = _foot_offset_for_texture(_sprite.texture)


func _foot_offset_for_texture(tex: Texture2D) -> Vector2:
	if tex == null:
		return Vector2.ZERO
	var h := float(tex.get_height())
	return Vector2(0.0, -h * 0.5)


func _process(delta: float) -> void:
	if _delay_left > 0.0:
		_delay_left -= delta
		return
	match _phase:
		_Phase.FLY_IN:
			_process_fly(delta)
		_Phase.LAND_HOLD:
			_process_land_hold(delta)
		_Phase.GROUND:
			_process_ground(delta)


func _process_fly(delta: float) -> void:
	_fly_t += delta / _FLY_DURATION_SEC
	var u := clampf(_fly_t, 0.0, 1.0)
	global_position = _fly_start.lerp(_fly_end, u)
	const _LAND_BLEND_START := 0.78
	if u >= _LAND_BLEND_START:
		_set_fly_frame(_FLY_FRAMES.size() - 1)
	else:
		_fly_anim_acc += delta
		var cycle_len := maxi(1, _FLY_FRAMES.size() - 1)
		while _fly_anim_acc >= _FLY_FRAME_SEC:
			_fly_anim_acc -= _FLY_FRAME_SEC
			_fly_frame_i = (_fly_frame_i + 1) % cycle_len
			_set_fly_frame(_fly_frame_i)
	if u >= 1.0:
		global_position = _fly_end
		_phase = _Phase.LAND_HOLD
		_sprite.texture = _LAND_TEX
		_sprite.offset = _foot_offset_for_texture(_LAND_TEX)
		_land_timer = 0.0


func _process_land_hold(delta: float) -> void:
	_land_timer += delta
	if _land_timer >= _LAND_HOLD_SEC:
		_phase = _Phase.GROUND
		_ground_is_pickup = false
		_idle_rounds_done = 0
		_pickup_rounds_done = 0
		_ground_frame_i = 0
		_ground_frame_acc = 0.0
		_apply_ground_texture()


func _process_ground(delta: float) -> void:
	_ground_frame_acc += delta
	while true:
		var frame_sec := _PICKUP_FRAME_SEC if _ground_is_pickup else _IDLE_FRAME_SEC
		var frames: Array[Texture2D] = _PICKUP_FRAMES if _ground_is_pickup else _IDLE_FRAMES
		if frames.is_empty():
			return
		if _ground_frame_acc < frame_sec:
			break
		_ground_frame_acc -= frame_sec
		_ground_frame_i += 1
		if _ground_frame_i >= frames.size():
			_ground_frame_i = 0
			_on_ground_cycle_wrapped()
		_apply_ground_texture()


func _on_ground_cycle_wrapped() -> void:
	if _ground_is_pickup:
		_pickup_rounds_done += 1
		if _pickup_rounds_done >= _PICKUP_ROUNDS_BEFORE_IDLE:
			_ground_is_pickup = false
			_pickup_rounds_done = 0
			_idle_rounds_done = 0
			_ground_frame_acc = 0.0
	elif _idle_rounds_done < _IDLE_ROUNDS_BEFORE_PICKUP:
		_idle_rounds_done += 1
		if _idle_rounds_done >= _IDLE_ROUNDS_BEFORE_PICKUP:
			_ground_is_pickup = true
			_pickup_rounds_done = 0
			_ground_frame_i = 0
			_ground_frame_acc = 0.0


func _apply_ground_texture() -> void:
	var frames: Array[Texture2D] = _PICKUP_FRAMES if _ground_is_pickup else _IDLE_FRAMES
	if frames.is_empty():
		return
	var tex := frames[clampi(_ground_frame_i, 0, frames.size() - 1)]
	_sprite.texture = tex
	_sprite.offset = _foot_offset_for_texture(tex)
