extends AnimatableBody2D
## Reverses this platform's move animation when the player moves left.
## Requires the platform to have an AnimationPlayer child (e.g. added in the level scene)
## and the player to be in the "player" group.


var _animation_player: AnimationPlayer
var _player: CharacterBody2D


func _ready() -> void:
	# AnimationPlayer may be added by the level scene as a child of this node
	_animation_player = get_node_or_null("AnimationPlayer") as AnimationPlayer


func _physics_process(_delta: float) -> void:
	# Player is often added after Level (e.g. in game_singleplayer), so resolve lazily
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if _animation_player == null:
		_animation_player = get_node_or_null("AnimationPlayer") as AnimationPlayer
	if _player == null or _animation_player == null:
		return
	# Move forward when player moves right, backward when left, and pause when player is still
	if _player.velocity.x > 0.0:
		_animation_player.speed_scale = 1.0
	elif _player.velocity.x < 0.0:
		_animation_player.speed_scale = -1.0
	else:
		_animation_player.speed_scale = 0.0
