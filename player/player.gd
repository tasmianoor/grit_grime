class_name Player extends CharacterBody2D

const _SEED_VISUAL_SCALE := 0.8 / 6.0
const _LAWRENCE_ATLAS := preload("res://player/lawrence.webp")
const _LAWRENCE_IDLE: Array[Texture2D] = [
	preload("res://player/Lawrence/idle/L_idle1.png"),
	preload("res://player/Lawrence/idle/L_idle2.png"),
	preload("res://player/Lawrence/idle/L_idle3.png"),
	preload("res://player/Lawrence/idle/L_idle4.png"),
]
const _LAWRENCE_WALK: Array[Texture2D] = [
	preload("res://player/Lawrence/walk/L_walk1.png"),
	preload("res://player/Lawrence/walk/L_walk2.png"),
	preload("res://player/Lawrence/walk/L_walk3.png"),
	preload("res://player/Lawrence/walk/L_walk4.png"),
	preload("res://player/Lawrence/walk/L_walk5.png"),
	preload("res://player/Lawrence/walk/L_walk6.png"),
]
## Idle / walk PNGs are ~320×321; atlas cells are 64×64 — scale HD art to match strip height.
const _LAWRENCE_HD_PIXEL_H := 321.0
const _LAWRENCE_ATLAS_CELL := 64.0
const _LAWRENCE_HD_SCALE := _LAWRENCE_ATLAS_CELL / _LAWRENCE_HD_PIXEL_H

const WALK_SPEED = 300.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -725.0
## On the ground, below this speed and with no move input we enter idle (Lawrence idle strip).
const IDLE_GROUND_SPEED := 40.0
## Once in idle, stay idle until speed reaches this (avoids idle/run flicker that restarts the clip on frame 0).
const IDLE_LEAVE_SPEED := 72.0
## Lawrence idle: `player/Lawrence/idle` PNGs, cycled in code (AnimationPlayer idle clip has no frame track).
const IDLE_FRAME_DURATION := 0.25
const IDLE_FRAME_COUNT := 4
## Lawrence walk: `player/Lawrence/walk` PNGs (six steps), cycled in code on the ground.
const WALK_FRAME_COUNT := 6
## One full walk loop at |velocity.x| == WALK_SPEED takes this long (before speed scaling).
const WALK_FRAME_DURATION := 0.12
## Walk cycle rate is multiplied by clamp(|vx| / WALK_SPEED, …) so slow steps crawl and fast steps sprint.
const WALK_ANIM_SPEED_MIN := 0.18
const WALK_ANIM_SPEED_MAX := 1.65
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
@onready var _trash_carry := $CarryTrashVisual as Polygon2D
var _double_jump_charged := false
var _idle_anim_time := 0.0
var _walk_anim_time := 0.0
var _held_seed: SeedDefs.Type = SeedDefs.Type.NONE
var _holding_trash := false
var _facing := 1.0


func _ready() -> void:
	add_to_group("player")
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	_update_carry_visual()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"pickup":
		_restore_lawrence_atlas()


func _restore_lawrence_atlas() -> void:
	sprite.texture = _LAWRENCE_ATLAS
	sprite.hframes = 11
	sprite.vframes = 1
	_apply_atlas_sprite_scale()


func _apply_atlas_sprite_scale() -> void:
	sprite.scale = Vector2(_facing, 1.0)


func _apply_hd_sprite_scale() -> void:
	sprite.scale = Vector2(_facing * _LAWRENCE_HD_SCALE, _LAWRENCE_HD_SCALE)


func _set_lawrence_hd_frame(tex: Texture2D) -> void:
	sprite.texture = tex
	sprite.hframes = 1
	sprite.vframes = 1
	sprite.frame = 0
	_apply_hd_sprite_scale()


func get_held_seed_kind() -> SeedDefs.Type:
	return _held_seed


func try_pickup_trash() -> bool:
	if _holding_trash or _held_seed != SeedDefs.Type.NONE:
		return false
	_holding_trash = true
	_update_carry_visual()
	return true


## Returns true if the player was carrying trash (deposit succeeded).
func deposit_trash() -> bool:
	if not _holding_trash:
		return false
	_holding_trash = false
	_update_carry_visual()
	return true


func is_holding_trash() -> bool:
	return _holding_trash


func try_pickup_seed(kind: SeedDefs.Type) -> bool:
	if _holding_trash or _held_seed != SeedDefs.Type.NONE:
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
	if _holding_trash:
		_carry_visual.visible = false
		_trash_carry.visible = true
		return
	_trash_carry.visible = false
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
		_facing = signf(velocity.x)
	if _carry_visual.visible:
		_carry_visual.scale.x = absf(_carry_visual.scale.x) * _facing
	if _trash_carry.visible:
		_trash_carry.scale.x = absf(_trash_carry.scale.x) * _facing

	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()

	var animation := get_new_animation()
	if animation != animation_player.current_animation:
		if animation == "idle":
			_idle_anim_time = 0.0
		elif animation == "walk":
			_walk_anim_time = 0.0
		if animation != "idle" and animation != "walk":
			_restore_lawrence_atlas()
		animation_player.play(animation)

	if animation == "idle":
		_idle_anim_time += delta
		var idle_cycle := IDLE_FRAME_DURATION * float(IDLE_FRAME_COUNT)
		_idle_anim_time = fposmod(_idle_anim_time, idle_cycle)
		var idle_i := clampi(int(_idle_anim_time / IDLE_FRAME_DURATION), 0, IDLE_FRAME_COUNT - 1)
		_set_lawrence_hd_frame(_LAWRENCE_IDLE[idle_i])
	elif animation == "walk":
		var speed_scale := clampf(absf(velocity.x) / WALK_SPEED, WALK_ANIM_SPEED_MIN, WALK_ANIM_SPEED_MAX)
		_walk_anim_time += delta * speed_scale
		var walk_cycle := WALK_FRAME_DURATION * float(WALK_FRAME_COUNT)
		_walk_anim_time = fposmod(_walk_anim_time, walk_cycle)
		var walk_i := clampi(int(_walk_anim_time / WALK_FRAME_DURATION), 0, WALK_FRAME_COUNT - 1)
		_set_lawrence_hd_frame(_LAWRENCE_WALK[walk_i])
	else:
		_apply_atlas_sprite_scale()
		match animation:
			"jumping", "jumping_weapon", "falling", "falling_weapon":
				sprite.frame = 4
			"crouch":
				sprite.frame = 0
			_:
				pass


func get_new_animation() -> String:
	if is_on_floor():
		var input_x := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix)
		var speed_x := absf(velocity.x)
		var cur := animation_player.current_animation
		# Hysteresis: flickering idle<->walk restarts clips and walk/idle frames never advance.
		if cur == "idle":
			if not is_zero_approx(input_x) or speed_x >= IDLE_LEAVE_SPEED:
				return "walk"
			return "idle"
		if is_zero_approx(input_x) and speed_x < IDLE_GROUND_SPEED:
			return "idle"
		return "walk"
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
