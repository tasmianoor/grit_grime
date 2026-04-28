extends Area2D

## Optional override; defaults to `Sprite2D.texture` from the scene.
@export var trash_texture: Texture2D

@onready var _sprite := $Sprite2D as Sprite2D

var _inside: Array[Player] = []
var _glow_sprite: Sprite2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
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


func _physics_process(_delta: float) -> void:
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
				queue_free()
				return
