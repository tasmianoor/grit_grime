extends Node2D
## One heron after **foreground smog is fully faded** and **no trash remains on river tiles**.

const _ACTOR_SCRIPT: GDScript = preload("res://level/props/birds/Heron/heron_actor.gd")

## Fallback world **X** when **`HeronLandingSpot`** is missing ( **`Y`** then comes from a ground raycast at that **X** ).
## When the marker exists, **both** **X** and **Y** use **`HeronLandingSpot.global_position`** so landing does not depend on physics ray order.
@export var land_world_x: float = -88.0

var _spawned := false


func _ready() -> void:
	add_to_group(&"heron_ambient")


func notify_maybe_spawn() -> void:
	if Engine.is_editor_hint():
		return
	_try_spawn()


func _try_spawn() -> void:
	if _spawned:
		return
	if not _smog_fully_cleared():
		return
	if _any_river_trash_remaining():
		return
	_spawned = true
	var bird := Node2D.new()
	bird.name = &"HeronActor"
	bird.set_script(_ACTOR_SCRIPT)
	bird.set_meta(&"heron_land_anchor", _resolve_land_anchor())
	bird.add_to_group(&"heron_spawned")
	add_child(bird)
	bird.call_deferred(&"begin_flight", 0.0)


func _resolve_land_anchor() -> Vector2:
	var lvl := get_parent() as Node2D
	if lvl == null:
		return Vector2(land_world_x, NAN)
	var spot := lvl.find_child(&"HeronLandingSpot", true, true) as Node2D
	if spot != null and is_instance_valid(spot):
		return spot.global_position
	return Vector2(land_world_x, NAN)


func _smog_fully_cleared() -> bool:
	var tree := get_tree()
	if tree == null:
		return false
	var smog_nodes := tree.get_nodes_in_group(&"smog_parallax_fade")
	if smog_nodes.is_empty():
		return true
	for n in smog_nodes:
		if not is_instance_valid(n):
			continue
		if not n.has_method(&"get_fade_progress"):
			return false
		if float(n.get_fade_progress()) < 1.0:
			return false
	return true


func _any_river_trash_remaining() -> bool:
	var tree := get_tree()
	if tree == null:
		return false
	for n in tree.get_nodes_in_group(&"trash_pickup"):
		if not is_instance_valid(n):
			continue
		if n.has_method(&"is_river_tile_trash") and bool(n.is_river_tile_trash()):
			return true
	return false
