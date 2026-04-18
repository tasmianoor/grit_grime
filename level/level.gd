extends Node2D


const LIMIT_LEFT = -1200
const LIMIT_TOP = -250
const LIMIT_RIGHT = 2200
const LIMIT_BOTTOM = 690


func _ready() -> void:
	add_to_group(&"game_level")
	for child in get_children():
		if child is Player:
			var camera = child.get_node("Camera")
			camera.limit_left = LIMIT_LEFT
			camera.limit_top = LIMIT_TOP
			camera.limit_right = LIMIT_RIGHT
			camera.limit_bottom = LIMIT_BOTTOM


func drop_willow_seed_2_from(world_top: Vector2, world_land: Vector2) -> void:
	var p := get_node_or_null(^"WillowSeed2Pickup")
	if p != null and p.has_method(&"begin_fall_from"):
		p.begin_fall_from(world_top, world_land)
