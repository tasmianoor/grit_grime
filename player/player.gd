class_name Player extends CharacterBody2D

const _SEED_VISUAL_SCALE := 0.8 / 6.0

const WALK_SPEED = 300.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -725.0
## Maximum speed at which the player can fall.
const TERMINAL_VELOCITY = 700

## The player listens for input actions appended with this suffix.[br]
## Used to separate controls for multiple players in splitscreen.
@export var action_suffix := ""

var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var sprite := $Sprite2D as Sprite2D
@onready var jump_sound := $Jump as AudioStreamPlayer2D
@onready var camera := $Camera as Camera2D
@onready var _carry_visual := $CarryVisual as Sprite2D
var _double_jump_charged := false
var _held_seed: SeedDefs.Type = SeedDefs.Type.NONE


func _ready() -> void:
	add_to_group("player")
	_update_carry_visual()


func get_held_seed_kind() -> SeedDefs.Type:
	return _held_seed


func try_pickup_seed(kind: SeedDefs.Type) -> bool:
	if _held_seed != SeedDefs.Type.NONE:
		return false
	_held_seed = kind
	_update_carry_visual()
	return true


## Clears held seed if it matches this soil patch (either willow seed on any willow soil; cypress on cypress).
func consume_held_for_soil(soil_kind: SeedDefs.Type) -> bool:
	var held := _held_seed
	if held == SeedDefs.Type.NONE:
		return false
	var ok := false
	match soil_kind:
		SeedDefs.Type.WILLOW_1, SeedDefs.Type.WILLOW_2:
			ok = held == SeedDefs.Type.WILLOW_1 or held == SeedDefs.Type.WILLOW_2
		SeedDefs.Type.CYPRESS:
			ok = held == SeedDefs.Type.CYPRESS
		_:
			ok = false
	if not ok:
		return false
	_held_seed = SeedDefs.Type.NONE
	_update_carry_visual()
	return true


func _update_carry_visual() -> void:
	if _held_seed == SeedDefs.Type.NONE:
		_carry_visual.visible = false
		return
	var tex: Texture2D
	match _held_seed:
		SeedDefs.Type.WILLOW_1:
			tex = preload("res://level/props/willow_seed_1.webp")
		SeedDefs.Type.WILLOW_2:
			tex = preload("res://level/props/willow_seed_2.webp")
		SeedDefs.Type.CYPRESS:
			tex = preload("res://level/props/cypress_seed.webp")
		_:
			_carry_visual.visible = false
			return
	_carry_visual.texture = tex
	_carry_visual.scale = Vector2(_SEED_VISUAL_SCALE, _SEED_VISUAL_SCALE)
	_carry_visual.visible = true


func _physics_process(delta: float) -> void:
	if is_on_floor():
		_double_jump_charged = true
	if Input.is_action_just_pressed("jump" + action_suffix):
		try_jump()
	elif Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6
	# Fall.
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)

	var direction := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix) * WALK_SPEED
	velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)

	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			sprite.scale.x = 1.0
		else:
			sprite.scale.x = -1.0
	if _carry_visual.visible:
		_carry_visual.scale.x = absf(_carry_visual.scale.x) * signf(sprite.scale.x)

	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()

	var animation := get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)


func get_new_animation() -> String:
	if is_on_floor():
		if absf(velocity.x) > 0.1:
			return "run"
		return "idle"
	if velocity.y > 0.0:
		return "falling"
	return "jumping"


func try_jump() -> void:
	if is_on_floor():
		jump_sound.pitch_scale = 1.0
	elif _double_jump_charged:
		_double_jump_charged = false
		velocity.x *= 2.5
		jump_sound.pitch_scale = 1.5
	else:
		return
	velocity.y = JUMP_VELOCITY
	jump_sound.play()
