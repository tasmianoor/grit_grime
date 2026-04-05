extends Area2D

## Matches `player/player.tscn`: 64×64 atlas frame, root scale 0.8.
const _PLAYER_FRAME_PX := 64.0
const _PLAYER_ROOT_SCALE := 0.8
const _SEED_VS_PLAYER := 1.0 / 6.0

@onready var _sprite := $Sprite2D as Sprite2D
@onready var _collision := $CollisionShape2D as CollisionShape2D


func _ready() -> void:
	_apply_seed_size()
	body_entered.connect(_on_body_entered)


func _apply_seed_size() -> void:
	var quad := _PLAYER_FRAME_PX * _PLAYER_ROOT_SCALE * _SEED_VS_PLAYER
	var scale_factor := quad / _PLAYER_FRAME_PX
	_sprite.scale = Vector2(scale_factor, scale_factor)
	var circle := _collision.shape as CircleShape2D
	if circle:
		circle.radius = _PLAYER_FRAME_PX * 0.5 * scale_factor


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_pickup()


func _pickup() -> void:
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
