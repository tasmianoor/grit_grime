extends AnimatableBody2D
## When enabled, scrubs the move animation from the player’s horizontal velocity (right = forward, left = reverse, still = pause).
## When disabled, the animation plays on its own at normal speed (e.g. vertical loop with no player coupling).
## Requires an AnimationPlayer child when this is enabled.
## The player must be in the "player" group when enabled.

@export var drive_animation_with_player_velocity: bool = true
## When true, matches `CollisionShape2D.one_way_collision` (pass through from below). Turn off for vertical movers so the player keeps floor contact while the platform goes down.
@export var one_way_collision: bool = true

var _animation_player: AnimationPlayer
var _player: CharacterBody2D


func _ready() -> void:
	# AnimationPlayer may be added by the level scene as a child of this node
	_animation_player = get_node_or_null("AnimationPlayer") as AnimationPlayer
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape != null:
		collision_shape.one_way_collision = one_way_collision


func _physics_process(_delta: float) -> void:
	if _animation_player == null:
		_animation_player = get_node_or_null("AnimationPlayer") as AnimationPlayer
	if _animation_player == null:
		return
	if not drive_animation_with_player_velocity:
		_animation_player.speed_scale = 1.0
		return
	# Player is often added after Level (e.g. in game_singleplayer), so resolve lazily
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if _player == null:
		return
	if _player.velocity.x > 0.0:
		_animation_player.speed_scale = 1.0
	elif _player.velocity.x < 0.0:
		_animation_player.speed_scale = -1.0
	else:
		_animation_player.speed_scale = 0.0
