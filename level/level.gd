class_name GameLevel extends Node2D

signal time_direction_changed(direction: int)

const _SOIL_DROP_SCRIPT := preload("res://pickups/soil_drop_zone.gd")
const _TRASH_PICKUP_SCRIPT := preload("res://pickups/trash_pickup.gd")
const _WILLOW_SEED_2_PICKUP_SCENE := preload("res://pickups/willow_seed_2_pickup.tscn")
## Matches typical `WillowSeed1Pickup` root scale in level scenes when no reference node exists.
const _WILLOW_SEED_2_FALLBACK_SCALE := Vector2(0.51, 0.45)

## Shown on the level-complete screen.
@export var level_display_name: String = "Level"
## Shown as **Level {n}: …** on the level-complete screen.
@export var level_index: int = 1
## If set, **Continue** loads this scene; otherwise it returns to the world map.
@export_file("*.tscn") var next_level_scene: String = ""

const LIMIT_LEFT = -1200
const LIMIT_TOP = -250
const LIMIT_RIGHT = 2200
const LIMIT_BOTTOM = 1050
const _TIME_DIR_EPSILON := 0.01
const _VINE_MIN_SCALE_FACTOR := 0.5
const _VINE_MAX_SCALE_FACTOR := 1.0
const _VINE_SCALE_RATE_PER_SEC := 0.22
## Match `player/player.gd` (avoid `Player` type at parse time).
const _POINTS_SOIL_PLANT := 10
const _POINTS_TRASH_DEPOSIT := 5

var _time_direction := 0
var _vines: Array[Sprite2D] = []
var _vine_base_scales: Array[Vector2] = []
var _vine_top_world_anchors: Array[Vector2] = []
var _vine_scale_factor := _VINE_MAX_SCALE_FACTOR
var _river_fall_tracking: Array[WeakRef] = []


func _ready() -> void:
	add_to_group(&"game_level")
	for vine_path in [^"Grass/Vine", ^"Grass/Vine2", ^"Grass/Vine3"]:
		var vine := get_node_or_null(vine_path) as Sprite2D
		if vine != null:
			vine.add_to_group(&"vine_climb")
			_vines.append(vine)
			_vine_base_scales.append(vine.scale)
			_vine_top_world_anchors.append(_vine_top_world_anchor(vine))
	for child in get_children():
		if child is CharacterBody2D and child.is_in_group(&"player"):
			var cam := child.get_node_or_null(^"Camera") as Camera2D
			if cam == null:
				continue
			cam.limit_left = LIMIT_LEFT
			cam.limit_top = LIMIT_TOP
			cam.limit_right = LIMIT_RIGHT
			cam.limit_bottom = LIMIT_BOTTOM
	var platforms := get_node_or_null(^"Platforms")
	if platforms != null:
		_setup_platform_visibility_collisions(platforms)


## Stars (0–3) and caption under the star row on the level-complete screen when this level is **not** using the Memphis mission pack (`memphis_mission_goals.gd`).
func get_completion_stars_and_message(_tree: SceneTree) -> Dictionary:
	if level_index == 2:
		return {
			&"stars": 3,
			&"message": "Nice work finishing this stage. Ready for the next challenge?",
		}
	return {&"stars": 0, &"message": ""}


func get_time_direction() -> int:
	return _time_direction


func get_soil_drop_zone_count() -> int:
	var soil_count := 0
	for n in find_children("*", "", true, false):
		if n.get_script() == _SOIL_DROP_SCRIPT:
			soil_count += 1
	return soil_count


func get_max_achievable_points() -> int:
	var trash_pickup_count := 0
	for n in find_children("*", "", true, false):
		if n.get_script() == _TRASH_PICKUP_SCRIPT:
			trash_pickup_count += 1
	return (
		get_soil_drop_zone_count() * _POINTS_SOIL_PLANT
		+ trash_pickup_count * _POINTS_TRASH_DEPOSIT
	)


func _physics_process(_delta: float) -> void:
	_check_river_fall()
	var new_direction := 0
	var tree := get_tree()
	if tree != null:
		for node in tree.get_nodes_in_group(&"player"):
			var player := node as CharacterBody2D
			if player == null:
				continue
			if player.velocity.x > _TIME_DIR_EPSILON:
				new_direction = 1
				break
			if player.velocity.x < -_TIME_DIR_EPSILON:
				new_direction = -1
				break
	_set_time_direction(new_direction)
	_update_vine_scale(_delta)


func _check_river_fall() -> void:
	var tree := get_tree()
	if tree == null or tree.paused:
		return
	var game := tree.get_first_node_in_group(&"game_controller") as Game
	if game == null:
		return
	var tm := get_node_or_null(^"TileMap") as TileMap
	if tm == null:
		return

	for wr in _river_fall_tracking:
		var tracked := wr.get_ref() as CharacterBody2D
		if tracked != null and is_instance_valid(tracked) and RiverTileQueries.player_feet_below_viewport(tracked):
			game.present_river_fall()
			_river_fall_tracking.clear()
			return

	var to_drop: Array[int] = []
	for i in range(_river_fall_tracking.size()):
		var p := _river_fall_tracking[i].get_ref() as CharacterBody2D
		if p == null or not is_instance_valid(p) or p.is_on_floor():
			to_drop.append(i)
	for j in range(to_drop.size() - 1, -1, -1):
		_river_fall_tracking.remove_at(to_drop[j])

	for node in tree.get_nodes_in_group(&"player"):
		var player := node as CharacterBody2D
		if player == null or not is_instance_valid(player):
			continue
		if _river_player_is_tracked(player):
			continue
		if RiverTileQueries.player_started_river_plummet(tm, player):
			_river_fall_tracking.append(weakref(player))


func _river_player_is_tracked(p: CharacterBody2D) -> bool:
	for wr in _river_fall_tracking:
		var q := wr.get_ref() as CharacterBody2D
		if q != null and is_instance_valid(q) and q == p:
			return true
	return false


func _set_time_direction(direction: int) -> void:
	direction = clampi(direction, -1, 1)
	if direction == _time_direction:
		return
	_time_direction = direction
	time_direction_changed.emit(_time_direction)


func _update_vine_scale(delta: float) -> void:
	if _vines.is_empty():
		return
	var target := _vine_scale_factor
	if _time_direction < 0:
		target = _VINE_MAX_SCALE_FACTOR
	elif _time_direction > 0:
		target = _VINE_MIN_SCALE_FACTOR
	_vine_scale_factor = move_toward(_vine_scale_factor, target, _VINE_SCALE_RATE_PER_SEC * delta)
	_vine_scale_factor = clampf(_vine_scale_factor, _VINE_MIN_SCALE_FACTOR, _VINE_MAX_SCALE_FACTOR)
	for i in range(_vines.size()):
		var vine := _vines[i]
		if not is_instance_valid(vine):
			continue
		_apply_vine_scale_from_top(vine, _vine_base_scales[i] * _vine_scale_factor, _vine_top_world_anchors[i])


func _vine_local_top_center(vine: Sprite2D) -> Vector2:
	if vine.texture == null:
		return Vector2.ZERO
	var tex_size := vine.texture.get_size()
	var top_x := 0.0 if vine.centered else tex_size.x * 0.5
	var top_y := -tex_size.y * 0.5 if vine.centered else 0.0
	return Vector2(top_x, top_y)


func _vine_top_world_anchor(vine: Sprite2D) -> Vector2:
	var local_top := _vine_local_top_center(vine)
	var scaled_local_top := Vector2(local_top.x * vine.scale.x, local_top.y * vine.scale.y)
	return vine.global_position + scaled_local_top.rotated(vine.global_rotation)


func _apply_vine_scale_from_top(vine: Sprite2D, target_scale: Vector2, world_top_anchor: Vector2) -> void:
	vine.scale = target_scale
	var local_top := _vine_local_top_center(vine)
	var scaled_local_top := Vector2(local_top.x * vine.scale.x, local_top.y * vine.scale.y)
	vine.global_position = world_top_anchor - scaled_local_top.rotated(vine.global_rotation)


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
	var p := _WILLOW_SEED_2_PICKUP_SCENE.instantiate() as Node2D
	var ref := get_node_or_null(^"WillowSeed1Pickup") as Node2D
	# Same root `scale` as the placed seed (set before `add_child` so `_ready` matches editor instances).
	if ref != null:
		p.scale = ref.scale
		p.modulate = ref.modulate
	else:
		p.scale = _WILLOW_SEED_2_FALLBACK_SCALE
	add_child(p)
	if ref != null:
		p.global_scale = ref.global_scale
	p.z_index = 2
	if p.has_method(&"begin_fall_from"):
		p.call(&"begin_fall_from", world_top, world_land)
