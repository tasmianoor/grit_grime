extends Area2D
## Same carry pipeline as **`pickups/trash_pickup.gd`** (**`try_pickup_trash`**) but **not** in the **`trash_pickup`** group (does not affect Memphis trash/heron tallies or **`level.gd`** max points).

@export var planter_texture: Texture2D

@onready var _sprite := $Sprite2D as Sprite2D

var _inside: Array[Node2D] = []
var _glow_sprite: Sprite2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if planter_texture != null:
		_sprite.texture = planter_texture
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
	if body is CharacterBody2D and body.is_in_group(&"player") and body not in _inside:
		_inside.append(body as Node2D)


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group(&"player"):
		_inside.erase(body as Node2D)


func _physics_process(_delta: float) -> void:
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
		if not p.has_method(&"try_pickup_trash"):
			continue
		var sfx := str(p.get(&"action_suffix"))
		if Input.is_action_just_pressed(&"drop_seed" + sfx):
			if bool(p.call(&"try_pickup_trash", _sprite.texture, _sprite.global_scale)):
				PickupNotifications.show_pickup("planter.")
				queue_free()
				return
