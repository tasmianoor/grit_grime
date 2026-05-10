extends Area2D

const _KINGFISHER_AMBIENT_ENSURE := preload("res://pickups/kingfisher_ambient_ensure.gd")
const _HERON_AMBIENT_ENSURE := preload("res://pickups/heron_ambient_ensure.gd")

## Optional override; defaults to `Sprite2D.texture` from the scene.
@export var trash_texture: Texture2D
## Gentle vertical bob for trash sitting on open water (e.g. river tiles).
@export var float_on_water: bool = false
@export_range(0.5, 24.0, 0.1) var water_bob_period_sec: float = 3.4
@export_range(0.5, 16.0, 0.25) var water_bob_amplitude_px: float = 3.25

@onready var _sprite := $Sprite2D as Sprite2D

var _inside: Array[Player] = []
var _glow_sprite: Sprite2D
var _water_rest_y: float
var _water_phase: float
var _water_time: float


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if float_on_water:
		_water_rest_y = position.y
		_water_phase = randf() * TAU
	if trash_texture != null:
		_sprite.texture = trash_texture
	add_to_group(&"trash_pickup")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_setup_proximity_glow()


func _setup_proximity_glow() -> void:
	var glow := Sprite2D.new()
	glow.name = &"ProximityGlow"
	glow.z_index = 1
	glow.centered = true
	glow.texture = PickupNearPlayer.radial_glow_texture()
	glow.visible = false
	glow.scale = Vector2(0.65, 0.65)
	add_child(glow)
	move_child(glow, 0)
	_glow_sprite = glow


func _on_body_entered(body: Node2D) -> void:
	if body is Player and body not in _inside:
		_inside.append(body as Player)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_inside.erase(body as Player)


func _physics_process(delta: float) -> void:
	if float_on_water:
		_water_time += delta
		var bob := sin(_water_time * TAU / maxf(0.01, water_bob_period_sec) + _water_phase) * water_bob_amplitude_px
		position.y = _water_rest_y + bob

	var near := PickupNearPlayer.any_player_within_glow_distance(
		get_tree(), _sprite.global_position
	)
	if _glow_sprite:
		_glow_sprite.visible = near
		_glow_sprite.global_position = _sprite.global_position
	var dead: Array[Player] = []
	for p in _inside:
		if not is_instance_valid(p):
			dead.append(p)
	for p in dead:
		_inside.erase(p)

	for p in _inside:
		if Input.is_action_just_pressed(&"drop_seed" + p.action_suffix):
			if p.try_pickup_trash(_sprite.texture, _sprite.global_scale):
				_notify_kingfisher_if_river_trash_removed()
				var tree := get_tree()
				if tree != null:
					_HERON_AMBIENT_ENSURE.notify_maybe_spawn_deferred(tree)
				queue_free()
				return


func _notify_kingfisher_if_river_trash_removed() -> void:
	if Engine.is_editor_hint():
		return
	if not _is_trash_on_river_tile():
		return
	var tree := get_tree()
	if tree == null:
		return
	var kf: Node = _KINGFISHER_AMBIENT_ENSURE.ensure_under_game_level(tree)
	if kf != null and kf.has_method(&"notify_river_trash_removed"):
		kf.notify_river_trash_removed()


func is_river_tile_trash() -> bool:
	return _is_trash_on_river_tile()


func _is_trash_on_river_tile() -> bool:
	if float_on_water:
		return true
	var tree := get_tree()
	if tree == null:
		return false
	var level := tree.get_first_node_in_group(&"game_level") as Node2D
	if level == null:
		return false
	var tm := level.get_node_or_null(^"TileMap") as TileMap
	if tm == null:
		return false
	return RiverTileQueries.global_point_on_river_tile(tm, _sprite.global_position)
