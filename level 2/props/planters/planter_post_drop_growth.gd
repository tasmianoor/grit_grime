extends Node2D
## After **`planter1`** is deposited, advances **planter1→planter4** while Lawrence moves **right** (same **`game_level`** time direction as cypress growth), reverses on **left**. At full growth, stays on **planter4**. Every frame uses the same on-screen height as **planter1** at deposit (no shrinking during growth).

const _FRAMES: Array[Texture2D] = [
	preload("res://level 2/props/planters/planter1.png"),
	preload("res://level 2/props/planters/planter2.png"),
	preload("res://level 2/props/planters/planter3.png"),
	preload("res://level 2/props/planters/planter4.png"),
]
## Same multiplier as **`pickups/soil_drop_zone.gd`** cypress pacing.
const _GROWTH_STEP_DURATION_MULT := 1.7142857
const _FRAME_COUNT := 4
const _GROWTH_FULLY_GROWN_EPSILON := 0.0001

@export var planted_sprite_height_px := 56.0
@export var growth_step_delay_sec := 0.45
@export var planted_visual_scale_mult := 1.25
## Local offset for the sprite vs this node’s origin (matches prior drop-zone placement).
@export var sprite_local_offset := Vector2(0.0, -16.0)

var _level_time_direction := 0
var _level_time_bound := false
var _growth_progress := 0.0
var _growth_maturity_locked := false
var _coordinator_notified := false
var _sprite: Sprite2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_bind_to_level_time_direction()
	_ensure_sprite()
	_apply_growth_visual_frame()


func _ensure_sprite() -> void:
	if is_instance_valid(_sprite):
		return
	_sprite = Sprite2D.new()
	_sprite.name = &"PlantedPlanterSprite"
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.centered = true
	_sprite.position = sprite_local_offset
	add_child(_sprite)


func _bind_to_level_time_direction() -> void:
	var level := get_tree().get_first_node_in_group(&"game_level")
	if level == null:
		return
	if level.has_signal(&"time_direction_changed"):
		var cb := Callable(self, &"_on_level_time_direction_changed")
		if not level.time_direction_changed.is_connected(cb):
			level.time_direction_changed.connect(cb)
	if level.has_method(&"get_time_direction"):
		_level_time_direction = int(level.get_time_direction())
	_level_time_bound = true


func _on_level_time_direction_changed(direction: int) -> void:
	_level_time_direction = clampi(direction, -1, 1)


func _growth_total_duration_sec() -> float:
	var segment_count := maxf(1.0, float(_FRAME_COUNT - 1))
	return growth_step_delay_sec * _GROWTH_STEP_DURATION_MULT * segment_count


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not _level_time_bound:
		_bind_to_level_time_direction()
	if not is_instance_valid(_sprite):
		return
	if _growth_maturity_locked:
		_growth_progress = 1.0
		_apply_growth_visual_frame()
		return
	var total_duration := _growth_total_duration_sec()
	if total_duration > 0.0:
		var direction := float(clampi(_level_time_direction, -1, 1))
		_growth_progress = clampf(
			_growth_progress + direction * (delta / total_duration),
			0.0,
			1.0,
		)
	_apply_growth_visual_frame()
	if _growth_progress >= 1.0 - _GROWTH_FULLY_GROWN_EPSILON:
		if not _growth_maturity_locked:
			_notify_planter_maturity_coordinator_once()
		_growth_maturity_locked = true


func _notify_planter_maturity_coordinator_once() -> void:
	if _coordinator_notified:
		return
	_coordinator_notified = true
	var tree := get_tree()
	if tree == null:
		return
	for n in tree.get_nodes_in_group(&"planter_butterfly_coordinator"):
		if n.has_method(&"register_planter_fully_mature"):
			n.call(&"register_planter_fully_mature")
			return


func _apply_growth_visual_frame() -> void:
	if not is_instance_valid(_sprite) or _FRAMES.is_empty():
		return
	var last_i := _FRAMES.size() - 1
	var frame_t := _growth_progress * float(last_i)
	var frame_i := clampi(int(floor(frame_t + 0.000001)), 0, last_i)
	var tex := _FRAMES[frame_i]
	# Same on-screen height as **planter1** at deposit: `planted_sprite_height_px / h0 * mult` × `h0`.
	var target_world_h := planted_sprite_height_px * planted_visual_scale_mult
	var tex_h := float(tex.get_height())
	var s := target_world_h / maxf(1.0, tex_h)
	_sprite.texture = tex
	_sprite.scale = Vector2(s, s)
