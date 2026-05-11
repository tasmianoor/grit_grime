@tool
extends Area2D

@export var seed_kind: SeedDefs.Type = SeedDefs.Type.WILLOW_1

## Matches `player/player.tscn`: 64×64 atlas frame, root scale 0.8.
const _PLAYER_FRAME_PX := 64.0
const _PLAYER_ROOT_SCALE := 0.8
const _SEED_VS_PLAYER := 1.0 / 6.0

@onready var _sprite := $Sprite2D as Sprite2D
@onready var _collision := $CollisionShape2D as CollisionShape2D

var _inside: Array[Node2D] = []
var _glow_sprite: Sprite2D


func _ready() -> void:
	_apply_seed_size()
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)
		_setup_proximity_glow()


func _display_name_for_seed(kind: SeedDefs.Type) -> String:
	match kind:
		SeedDefs.Type.WILLOW_1, SeedDefs.Type.WILLOW_2:
			return "willow tree seed"
		SeedDefs.Type.CYPRESS:
			return "cypress tree seed"
		_:
			return "seed"


func _apply_seed_size() -> void:
	var quad := _PLAYER_FRAME_PX * _PLAYER_ROOT_SCALE * _SEED_VS_PLAYER
	var scale_factor := quad / _PLAYER_FRAME_PX
	_sprite.scale = Vector2(scale_factor, scale_factor)
	var circle := _collision.shape as CircleShape2D
	if circle:
		circle.radius = _PLAYER_FRAME_PX * 0.5 * scale_factor


func _setup_proximity_glow() -> void:
	var glow := Sprite2D.new()
	glow.name = &"ProximityGlow"
	glow.z_index = 1
	glow.centered = true
	glow.texture = PickupNearPlayer.radial_glow_texture()
	glow.visible = false
	# World-space halo ~behind~ pickup sprite (texture is 128×128).
	glow.scale = Vector2(0.65, 0.65)
	add_child(glow)
	move_child(glow, 0)
	_glow_sprite = glow


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group(&"player") and body not in _inside:
		_inside.append(body as Node2D)


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group(&"player"):
		_inside.erase(body as Node2D)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var near := PickupNearPlayer.any_player_within_glow_distance(
		get_tree(), _sprite.global_position
	)
	if _glow_sprite:
		_glow_sprite.visible = near
		_glow_sprite.global_position = _sprite.global_position
	var dead: Array[Node2D] = []
	for p in _inside:
		if not is_instance_valid(p):
			dead.append(p)
	for p in dead:
		_inside.erase(p)

	for p in _inside:
		if not p.has_method(&"try_pickup_seed"):
			continue
		var sfx := str(p.get(&"action_suffix"))
		if Input.is_action_just_pressed(&"drop_seed" + sfx):
			if bool(p.call(&"try_pickup_seed", seed_kind, _sprite.global_scale)):
				_pickup_succeeded()
				return


func _pickup_succeeded() -> void:
	PickupNotifications.show_pickup(_display_name_for_seed(seed_kind))
	var sfx := get_node_or_null(^"PickupSound") as AudioStreamPlayer2D
	if sfx and sfx.stream:
		var holder := get_parent()
		if holder:
			remove_child(sfx)
			holder.add_child(sfx)
			sfx.play()
			sfx.finished.connect(sfx.queue_free)
	monitoring = false
	queue_free()
