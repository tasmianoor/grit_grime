extends Node2D
## One kingfisher after **two** mature trees and **one** river-tile trash pickup.

const _ACTOR_SCRIPT: GDScript = preload("res://level/props/birds/Kfisher/kingfisher_actor.gd")

var _mature_tree_count := 0
var _river_trash_removed := 0
var _spawned := false


func _ready() -> void:
	add_to_group(&"kingfisher_ambient")


func notify_tree_matured() -> void:
	if Engine.is_editor_hint():
		return
	_mature_tree_count += 1
	_try_spawn()


func notify_river_trash_removed() -> void:
	if Engine.is_editor_hint():
		return
	_river_trash_removed += 1
	_try_spawn()


func _try_spawn() -> void:
	if _spawned:
		return
	if _mature_tree_count < 2 or _river_trash_removed < 1:
		return
	_spawned = true
	_bring_draw_in_front_of_roots()
	var bird := Node2D.new()
	bird.name = &"KingfisherActor"
	bird.set_script(_ACTOR_SCRIPT)
	var lvl := get_parent() as Node2D
	if lvl != null:
		var spot := lvl.find_child(&"KingfisherLandingSpot", true, true) as Node2D
		if spot != null and is_instance_valid(spot):
			bird.set_meta(&"kingfisher_land_anchor", spot.global_position)
	add_child(bird)
	bird.call_deferred(&"begin_flight", 0.0)


func _bring_draw_in_front_of_roots() -> void:
	## Runtime roots use `level/props/Roots/*.png` (`CypressRoots`); stay below player (z≈5) but above those sprites.
	var max_roots_z := 0
	for n in get_tree().get_nodes_in_group(&"cypress_roots_prop"):
		if n is CanvasItem:
			max_roots_z = maxi(max_roots_z, (n as CanvasItem).z_index)
	z_index = maxi(max_roots_z + 1, 4)
	call_deferred(&"_deferred_move_to_last_level_sibling")


func _deferred_move_to_last_level_sibling() -> void:
	var p := get_parent()
	if p == null:
		return
	p.move_child(self, p.get_child_count() - 1)
