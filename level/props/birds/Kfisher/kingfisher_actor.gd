extends Node2D
## Kingfisher: flies in, lands on a **random** level-1 river tile (`Kfisher_fly6`), then **2× idle** → **2× pickup** → repeat.

const _FLY_FRAMES: Array[Texture2D] = [
	preload("res://level/props/birds/Kfisher/fly/Kfisher_fly1.png"),
	preload("res://level/props/birds/Kfisher/fly/Kfisher_fly2.png"),
	preload("res://level/props/birds/Kfisher/fly/Kfisher_fly2_1.png"),
	preload("res://level/props/birds/Kfisher/fly/Kfisher_fly3.png"),
	preload("res://level/props/birds/Kfisher/fly/Kfisher_fly5.png"),
	preload("res://level/props/birds/Kfisher/fly/Kfisher_fly6.png"),
]

const _LAND_TEX: Texture2D = preload("res://level/props/birds/Kfisher/fly/Kfisher_fly6.png")

const _IDLE_FRAMES: Array[Texture2D] = [
	preload("res://level/props/birds/Kfisher/idle/Kfisher_idle1.png"),
	preload("res://level/props/birds/Kfisher/idle/Kfisher_idle2.png"),
	preload("res://level/props/birds/Kfisher/idle/Kfisher_idle3.png"),
]

const _PICKUP_FRAMES: Array[Texture2D] = [
	preload("res://level/props/birds/Kfisher/pickup/Kfisher_pickup1.png"),
	preload("res://level/props/birds/Kfisher/pickup/Kfisher_pickup2.png"),
	preload("res://level/props/birds/Kfisher/pickup/Kfisher_pickup3.png"),
]

const _OFFSCREEN_MARGIN := 96.0
const _FLY_DURATION_SEC := 4.8
const _FLY_FRAME_SEC := 0.14
const _LAND_HOLD_SEC := 0.7
const _IDLE_FRAME_SEC := 0.56
const _PICKUP_FRAME_SEC := 0.56
const _IDLE_ROUNDS_BEFORE_PICKUP := 2
const _PICKUP_ROUNDS_BEFORE_IDLE := 2
const _KFISHER_TEX_SCALE := 1.0 / 3.0

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
	# Draw order vs. `CypressRoots` is handled on `KingfisherAmbient`; keep this node neutral.
	z_index = 0
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.centered = true
	_sprite.scale = Vector2(_KFISHER_TEX_SCALE, _KFISHER_TEX_SCALE)
	add_child(_sprite)


func begin_flight(delay_sec: float) -> void:
	_delay_left = maxf(0.0, delay_sec)
	_phase = _Phase.FLY_IN
	var rect := _camera_world_rect()
	var tm := _find_level_tilemap()
	var land := Vector2.ZERO
	if tm != null:
		land = RiverTileQueries.random_river_tile_top_center_world(tm, rect)
	if land == Vector2.ZERO and tm != null:
		land = RiverTileQueries.random_river_tile_top_center_world(tm, Rect2(-1e6, -1e6, 2e6, 2e6))
	if land == Vector2.ZERO:
		land = Vector2(rect.get_center().x, rect.get_center().y)
	_fly_end = land
	var side := randi() % 4
	var m := _OFFSCREEN_MARGIN
	match side:
		0:
			_fly_start = Vector2(rect.position.x - m, randf_range(rect.position.y, rect.end.y))
		1:
			_fly_start = Vector2(rect.end.x + m, randf_range(rect.position.y, rect.end.y))
		2:
			_fly_start = Vector2(randf_range(rect.position.x, rect.end.x), rect.position.y - m)
		_:
			_fly_start = Vector2(randf_range(rect.position.x, rect.end.x), rect.end.y + m)
	_fly_t = 0.0
	_fly_frame_i = 0
	_fly_anim_acc = 0.0
	global_position = _fly_start
	_face_toward(_fly_end.x - _fly_start.x)
	_set_fly_frame(0)


func _find_level_tilemap() -> TileMap:
	var gl := get_tree().get_first_node_in_group(&"game_level") as Node2D
	if gl == null:
		return null
	return gl.get_node_or_null(^"TileMap") as TileMap


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
	var arc := 4.0 * u * (1.0 - u)
	var base := _fly_start.lerp(_fly_end, u)
	global_position = base + Vector2(0.0, -80.0 * arc)
	_face_toward(_fly_end.x - global_position.x)
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
