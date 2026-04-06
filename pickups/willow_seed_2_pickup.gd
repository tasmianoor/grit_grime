@tool
extends "res://pickups/seed_pickup.gd"

## Time for the seed to fall from the pink placeholder to the ground.
@export var fall_duration_sec := 0.55

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
	global_position = world_top
	var tw := create_tween()
	tw.set_trans(Tween.TRANS_QUAD)
	tw.set_ease(Tween.EASE_IN)
	tw.tween_property(self, ^"global_position", world_land, fall_duration_sec)
	tw.finished.connect(_on_fall_finished)


func _on_fall_finished() -> void:
	monitoring = true
