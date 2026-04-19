@tool
extends "res://pickups/seed_pickup.gd"

## Time for the seed to fall from the pink placeholder to the ground.
@export var fall_duration_sec := 0.55

## Raycast above/below the target X to find platforms + ground (`project.godot` layers 4–5).
const _RAY_PROBE_ABOVE := 900.0
const _RAY_CAST_BELOW := 200.0
const _CLEARANCE_ABOVE_SURFACE := 3.0
## Bitmask: layer 4 (platforms) | layer 5 (ground).
const _FLOOR_RAY_MASK := (1 << 3) | (1 << 4)

var _fall_commenced := false


func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return
	monitoring = false
	visible = false


## [param world_land] World position where the seed settles, usually beside the pink placeholder base.
func begin_fall_from(world_top: Vector2, world_land: Vector2) -> void:
	if _fall_commenced:
		return
	_fall_commenced = true
	visible = true
	var land_safe := _land_world_above_ground(world_land)
	global_position = world_top
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_QUAD)
	tw.set_ease(Tween.EASE_IN)
	tw.tween_property(self, ^"global_position", land_safe, fall_duration_sec)
	tw.finished.connect(_on_fall_finished)


func _pickup_radius_world() -> float:
	var circle := _collision.shape as CircleShape2D
	var r := circle.radius if circle != null else 4.26667
	var s := global_transform.get_scale()
	return r * maxf(absf(s.x), absf(s.y))


func _land_world_above_ground(world_land: Vector2) -> Vector2:
	var w2d := get_world_2d()
	if w2d == null:
		return Vector2(world_land.x, world_land.y - 16.0)
	var space := w2d.direct_space_state
	var from := Vector2(world_land.x, world_land.y - _RAY_PROBE_ABOVE)
	var to := Vector2(world_land.x, world_land.y + _RAY_CAST_BELOW)
	var pq := PhysicsRayQueryParameters2D.create(from, to)
	pq.collision_mask = _FLOOR_RAY_MASK
	pq.collide_with_areas = false
	pq.collide_with_bodies = true
	var hit := space.intersect_ray(pq)
	if hit.is_empty():
		return Vector2(world_land.x, world_land.y - 16.0)
	var y: float = float(hit.position.y) - _pickup_radius_world() - _CLEARANCE_ABOVE_SURFACE
	return Vector2(world_land.x, y)


func _on_fall_finished() -> void:
	monitoring = true
