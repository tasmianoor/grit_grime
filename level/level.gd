extends Node2D


const LIMIT_LEFT = -1200
const LIMIT_TOP = -250
const LIMIT_RIGHT = 2200
const LIMIT_BOTTOM = 690


func _ready() -> void:
	add_to_group(&"game_level")
	for vine_path in [^"Grass/Vine", ^"Grass/Vine2", ^"Grass/Vine3"]:
		var vine := get_node_or_null(vine_path)
		if vine != null:
			vine.add_to_group(&"vine_climb")
	for child in get_children():
		if child is Player:
			var camera = child.get_node("Camera")
			camera.limit_left = LIMIT_LEFT
			camera.limit_top = LIMIT_TOP
			camera.limit_right = LIMIT_RIGHT
			camera.limit_bottom = LIMIT_BOTTOM
	var platforms := get_node_or_null(^"Platforms")
	if platforms != null:
		_setup_platform_visibility_collisions(platforms)


func _setup_platform_visibility_collisions(root: Node) -> void:
	if root is CollisionObject2D:
		var body := root as CollisionObject2D
		body.set_meta(&"_default_collision_layer", body.collision_layer)
		body.set_meta(&"_default_collision_mask", body.collision_mask)
		if root is CanvasItem:
			var item := root as CanvasItem
			item.visibility_changed.connect(_on_platform_visibility_changed.bind(body))
		_apply_platform_visibility_collision(body)
	for child in root.get_children():
		_setup_platform_visibility_collisions(child)


func _on_platform_visibility_changed(body: CollisionObject2D) -> void:
	_apply_platform_visibility_collision(body)


func _apply_platform_visibility_collision(body: CollisionObject2D) -> void:
	var item := body as CanvasItem
	if item == null:
		return
	var should_collide := item.is_visible_in_tree()
	var default_layer := int(body.get_meta(&"_default_collision_layer", body.collision_layer))
	var default_mask := int(body.get_meta(&"_default_collision_mask", body.collision_mask))
	body.collision_layer = default_layer if should_collide else 0
	body.collision_mask = default_mask if should_collide else 0


func drop_willow_seed_2_from(world_top: Vector2, world_land: Vector2) -> void:
	var p := get_node_or_null(^"WillowSeed2Pickup")
	if p != null and p.has_method(&"begin_fall_from"):
		p.begin_fall_from(world_top, world_land)
