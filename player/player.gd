class_name Player extends CharacterBody2D

## Same basis as `pickups/seed_pickup.gd` (64×64 cell × player root 0.8 × 1/6); fallback if scale not passed.
const _SEED_VISUAL_SCALE := 0.8 / 6.0
## In-world trash props are `Trash/*.png` at 320×321; `trash_pickup` scales sprites by this — fallback only.
const _TRASH_PICKUP_VISUAL_SCALE := 0.125
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
const _LAWRENCE_JUMP: Array[Texture2D] = [
	preload("res://player/Lawrence/jump/L_jump1.png"),
	preload("res://player/Lawrence/jump/L_jump2.png"),
]
const _LAWRENCE_CLIMB: Array[Texture2D] = [
	preload("res://player/Lawrence/climb2/Climb1.png"),
	preload("res://player/Lawrence/climb2/Climb2.png"),
	preload("res://player/Lawrence/climb2/Climb3.png"),
]
## Lawrence HD strips (idle / walk / jump) are ~320×321; atlas cells are 64×64 — scale to match strip height.
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
## Second frame (L_idle2) holds for one third of this; all others use the full duration.
const IDLE_FRAME_DURATION := 7.0
const IDLE_FRAME_COUNT := 4
## Lawrence walk: `player/Lawrence/walk` PNGs (six steps), cycled in code on the ground.
const WALK_FRAME_COUNT := 6
## One full walk loop at |velocity.x| == WALK_SPEED takes this long (before speed scaling).
const WALK_FRAME_DURATION := 0.12
## Walk cycle rate is multiplied by clamp(|vx| / WALK_SPEED, …) so slow steps crawl and fast steps sprint.
const WALK_ANIM_SPEED_MIN := 0.18
const WALK_ANIM_SPEED_MAX := 1.65
## Lawrence climb: three frames on `Grass/Vine*` overlap.
const CLIMB_FRAME_COUNT := 3
const CLIMB_FRAME_DURATION := 0.14
## Extra padding around vine sprite rects for overlap with the player hitbox.
const VINE_CLIMB_RECT_GROW := 14.0
## Vertical speed while holding `move_up` / `move_down` on a vine (`move_up` + action_suffix).
const CLIMB_SPEED := 200.0
## Reduced horizontal acceleration while on a vine.
const CLIMB_SIDE_SPEED := 110.0
## Horizontal padding beyond the combined vine column where climb latch releases.
const CLIMB_COLUMN_PAD_X := 36.0
## End climb when the player sprite vertical midpoint is at/above `Grass/Vine2` top (world Y); small slack in +Y.
const CLIMB_VINE2_STOP_MARGIN := 3.0
## New climb latch only after a jump; first contact must be while falling at least this fast (pixels/sec, downward = positive Y).
const CLIMB_VINE_LATCH_MIN_DESCENT_VY := 45.0
## After jump-off the vine, ignore new vine latch briefly (seconds).
const CLIMB_REATTACH_COOLDOWN := 0.32
## While ascending (`jumping`), use L_jump1 until upward speed is below this (then L_jump2 / fall).
const JUMP_ASCENT_FRAME_0_WHILE_VY_LESS := -280.0
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
@onready var _trash_carry := $CarryTrashVisual as Sprite2D
var _double_jump_charged := false
var _idle_anim_time := 0.0
var _walk_anim_time := 0.0
var _held_seed: SeedDefs.Type = SeedDefs.Type.NONE
var _holding_trash := false
var _carried_trash_tex: Texture2D
## `Sprite2D.global_scale` on the pickup at grab time (carry icon matches that world size).
var _carried_seed_ground_global_scale := Vector2.ZERO
var _carried_trash_ground_global_scale := Vector2.ZERO
var _facing := 1.0
var _pickup_anim_playing := false
var _pending_seed_visual_refresh := false
var _vine_climb_latched := false
var _vine_climb_col_left := 0.0
var _vine_climb_col_right := 0.0
var _vine_climb_cooldown := 0.0
## After climb ends at vine top: show idle, no gravity, until floor / jump / horizontal move.
var _vine_crest_idle := false
## True after any jump impulse until landing; required to start a new vine climb latch.
var _vine_latch_eligible_after_jump := false
var _climb_anim_time := 0.0


func _ready() -> void:
	add_to_group("player")
	animation_player.animation_finished.connect(_on_animation_player_animation_finished)
	_update_carry_visual()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"pickup":
		_pickup_anim_playing = false
		if _pending_seed_visual_refresh:
			_pending_seed_visual_refresh = false
			_update_carry_visual()
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


func try_pickup_trash(tex: Texture2D, ground_sprite_global_scale: Vector2 = Vector2.ZERO) -> bool:
	if _holding_trash or _held_seed != SeedDefs.Type.NONE:
		return false
	if tex == null:
		return false
	var g := ground_sprite_global_scale
	if g == Vector2.ZERO:
		g = Vector2(_TRASH_PICKUP_VISUAL_SCALE, _TRASH_PICKUP_VISUAL_SCALE)
	_carried_trash_ground_global_scale = g
	_holding_trash = true
	_carried_trash_tex = tex
	_update_carry_visual()
	return true


## Returns true if the player was carrying trash (deposit succeeded).
func deposit_trash() -> bool:
	if not _holding_trash:
		return false
	_holding_trash = false
	_carried_trash_tex = null
	_carried_trash_ground_global_scale = Vector2.ZERO
	_update_carry_visual()
	return true


func is_holding_trash() -> bool:
	return _holding_trash


func try_pickup_seed(kind: SeedDefs.Type, ground_sprite_global_scale: Vector2 = Vector2.ZERO) -> bool:
	if _holding_trash or _held_seed != SeedDefs.Type.NONE:
		return false
	var g := ground_sprite_global_scale
	if g == Vector2.ZERO:
		g = Vector2(_SEED_VISUAL_SCALE, _SEED_VISUAL_SCALE)
	_carried_seed_ground_global_scale = g
	_held_seed = kind
	_start_seed_pickup_animation()
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
	_carried_seed_ground_global_scale = Vector2.ZERO
	_update_carry_visual()
	return true


func _carry_local_scale_from_ground_pickup(ground_sprite_global_scale: Vector2) -> Vector2:
	var g := Vector2(absf(ground_sprite_global_scale.x), absf(ground_sprite_global_scale.y))
	var pg := global_scale
	return Vector2(
		g.x / maxf(absf(pg.x), 1e-6),
		g.y / maxf(absf(pg.y), 1e-6)
	)


func _update_carry_visual() -> void:
	if _holding_trash:
		_carry_visual.visible = false
		_trash_carry.texture = _carried_trash_tex
		_trash_carry.scale = _carry_local_scale_from_ground_pickup(_carried_trash_ground_global_scale)
		_trash_carry.visible = true
		return
	_trash_carry.visible = false
	if _held_seed == SeedDefs.Type.NONE:
		_carry_visual.visible = false
		return
	var tex: Texture2D
	match _held_seed:
		SeedDefs.Type.WILLOW_1, SeedDefs.Type.WILLOW_2:
			tex = preload("res://level/props/Willow_seed.png")
		SeedDefs.Type.CYPRESS:
			tex = preload("res://level/props/Cypress_seed.png")
		_:
			_carry_visual.visible = false
			return
	_carry_visual.texture = tex
	_carry_visual.scale = _carry_local_scale_from_ground_pickup(_carried_seed_ground_global_scale)
	_carry_visual.visible = true


func _start_seed_pickup_animation() -> void:
	if animation_player == null or not animation_player.has_animation(&"pickup"):
		_update_carry_visual()
		return
	_pickup_anim_playing = true
	_pending_seed_visual_refresh = true
	_carry_visual.visible = false
	animation_player.play(&"pickup")


func _player_collision_global_rect() -> Rect2:
	var cs := $CollisionShape2D as CollisionShape2D
	if cs == null or cs.shape == null:
		return Rect2(global_position, Vector2.ZERO)
	var rect_shape := cs.shape as RectangleShape2D
	if rect_shape == null:
		return Rect2(global_position, Vector2.ZERO)
	var half := rect_shape.size * 0.5
	return Rect2(cs.global_position - half, rect_shape.size)


func _sprite_global_bounds_rect(sprite: Sprite2D) -> Rect2:
	var r := sprite.get_rect()
	var p0 := sprite.to_global(r.position)
	var p1 := sprite.to_global(r.position + Vector2(r.size.x, 0.0))
	var p2 := sprite.to_global(r.position + r.size)
	var p3 := sprite.to_global(r.position + Vector2(0.0, r.size.y))
	var min_x := minf(minf(p0.x, p1.x), minf(p2.x, p3.x))
	var max_x := maxf(maxf(p0.x, p1.x), maxf(p2.x, p3.x))
	var min_y := minf(minf(p0.y, p1.y), minf(p2.y, p3.y))
	var max_y := maxf(maxf(p0.y, p1.y), maxf(p2.y, p3.y))
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))


func _all_vine_bounds_grown() -> Array[Rect2]:
	var out: Array[Rect2] = []
	var tree := get_tree()
	if tree == null:
		return out
	for node in tree.get_nodes_in_group(&"vine_climb"):
		if not (node is Sprite2D):
			continue
		out.append(_sprite_global_bounds_rect(node as Sprite2D).grow(VINE_CLIMB_RECT_GROW))
	return out


func _player_intersects_any_vine_rect(player_rect: Rect2, rects: Array[Rect2]) -> bool:
	for r in rects:
		if player_rect.intersects(r):
			return true
	return false


func _vine_union_horizontal(rects: Array[Rect2]) -> void:
	if rects.is_empty():
		return
	var l := rects[0].position.x
	var r := rects[0].position.x + rects[0].size.x
	for i in range(1, rects.size()):
		l = minf(l, rects[i].position.x)
		r = maxf(r, rects[i].position.x + rects[i].size.x)
	_vine_climb_col_left = l
	_vine_climb_col_right = r


func _player_frame_global_bounds_rect() -> Rect2:
	return _sprite_global_bounds_rect(sprite)


## World-space top Y of `Grass/Vine2` sprite AABB (level root must be in group `game_level`).
func _grass_vine2_sprite_top_y() -> float:
	var tree := get_tree()
	if tree == null:
		return 1e9
	var lvl := tree.get_first_node_in_group(&"game_level")
	if lvl == null:
		return 1e9
	var v2 := lvl.get_node_or_null(^"Grass/Vine2")
	if v2 == null or not (v2 is Sprite2D):
		return 1e9
	return _sprite_global_bounds_rect(v2 as Sprite2D).position.y


func _refresh_vine_climb_latch() -> void:
	var player_rect := _player_collision_global_rect()
	var rects := _all_vine_bounds_grown()

	if is_on_floor():
		_vine_climb_latched = false
		_vine_crest_idle = false
		return

	var touching_sprite := _player_intersects_any_vine_rect(player_rect, rects)
	if (
		touching_sprite
		and _vine_climb_cooldown <= 0.0
		and not _vine_crest_idle
		and _vine_latch_eligible_after_jump
		and velocity.y > CLIMB_VINE_LATCH_MIN_DESCENT_VY
	):
		_vine_latch_eligible_after_jump = false
		_vine_crest_idle = false
		_vine_climb_latched = true
		_vine_union_horizontal(rects)
		return

	if not _vine_climb_latched:
		return

	var cx := player_rect.get_center().x
	if cx < _vine_climb_col_left - CLIMB_COLUMN_PAD_X or cx > _vine_climb_col_right + CLIMB_COLUMN_PAD_X:
		_vine_climb_latched = false


func _is_vine_climbing_active() -> bool:
	return _vine_climb_latched and not is_on_floor()


func _physics_process(delta: float) -> void:
	if is_on_floor():
		_double_jump_charged = true
		_vine_crest_idle = false

	_vine_climb_cooldown = maxf(0.0, _vine_climb_cooldown - delta)

	var climbing_for_jump := _is_vine_climbing_active()
	var climb_axis_v := Input.get_axis("move_down" + action_suffix, "move_up" + action_suffix)
	var input_x := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix)

	if _vine_crest_idle and not is_on_floor() and not is_zero_approx(input_x):
		_vine_crest_idle = false

	# Jump before vine latch refresh so `_vine_latch_eligible_after_jump` can apply the same frame.
	# Arrow Up is bound to both `jump` and `move_up`; on a vine, prefer climb over jump-off.
	if Input.is_action_just_pressed("jump" + action_suffix):
		if not climbing_for_jump or climb_axis_v < 0.35:
			try_jump()
	elif not climbing_for_jump and not _vine_crest_idle and Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6

	_refresh_vine_climb_latch()

	var climbing := _is_vine_climbing_active()

	if climbing:
		var frame_rect := _player_frame_global_bounds_rect()
		var frame_mid_y := frame_rect.position.y + frame_rect.size.y * 0.5
		var vine2_top := _grass_vine2_sprite_top_y()
		if vine2_top < 1e8 and frame_mid_y <= vine2_top + CLIMB_VINE2_STOP_MARGIN:
			_vine_climb_latched = false
			_vine_climb_cooldown = CLIMB_REATTACH_COOLDOWN
			_vine_crest_idle = true
			velocity.y = 0.0
			velocity.x = move_toward(velocity.x, 0.0, ACCELERATION_SPEED * delta)
		else:
			velocity.y = -climb_axis_v * CLIMB_SPEED
			var side_target := input_x * CLIMB_SIDE_SPEED
			velocity.x = move_toward(velocity.x, side_target, ACCELERATION_SPEED * 0.4 * delta)
	elif _vine_crest_idle and not is_on_floor():
		velocity.y = 0.0
		velocity.x = move_toward(velocity.x, 0.0, ACCELERATION_SPEED * delta)
	else:
		velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)
		var direction := input_x * WALK_SPEED
		velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)

	if not is_zero_approx(velocity.x):
		_facing = signf(velocity.x)
	if _carry_visual.visible:
		_carry_visual.scale.x = absf(_carry_visual.scale.x) * _facing
	if _trash_carry.visible:
		_trash_carry.scale.x = absf(_trash_carry.scale.x) * _facing

	floor_stop_on_slope = not climbing and not _vine_crest_idle and not platform_detector.is_colliding()
	move_and_slide()
	if is_on_floor():
		_vine_latch_eligible_after_jump = false

	if _pickup_anim_playing:
		return

	var animation := get_new_animation()
	if animation != animation_player.current_animation:
		if animation == "idle":
			_idle_anim_time = 0.0
		elif animation == "walk":
			_walk_anim_time = 0.0
		elif animation == "climbing":
			_climb_anim_time = 0.0
		if animation != "idle" and animation != "walk" and animation != "jumping" and animation != "jumping_weapon" and animation != "falling" and animation != "falling_weapon" and animation != "climbing":
			_restore_lawrence_atlas()
		animation_player.play(animation)

	if animation == "idle":
		_idle_anim_time += delta
		var d_full := IDLE_FRAME_DURATION
		var d_second := d_full / 3.0
		var idle_cycle := d_full * 3.0 + d_second
		_idle_anim_time = fposmod(_idle_anim_time, idle_cycle)
		var t := _idle_anim_time
		var idle_i: int
		if t < d_full:
			idle_i = 0
		elif t < d_full + d_second:
			idle_i = 1
		elif t < d_full + d_second + d_full:
			idle_i = 2
		else:
			idle_i = 3
		_set_lawrence_hd_frame(_LAWRENCE_IDLE[idle_i])
	elif animation == "walk":
		var speed_scale := clampf(absf(velocity.x) / WALK_SPEED, WALK_ANIM_SPEED_MIN, WALK_ANIM_SPEED_MAX)
		_walk_anim_time += delta * speed_scale
		var walk_cycle := WALK_FRAME_DURATION * float(WALK_FRAME_COUNT)
		_walk_anim_time = fposmod(_walk_anim_time, walk_cycle)
		var walk_i := clampi(int(_walk_anim_time / WALK_FRAME_DURATION), 0, WALK_FRAME_COUNT - 1)
		_set_lawrence_hd_frame(_LAWRENCE_WALK[walk_i])
	elif animation == "jumping" or animation == "jumping_weapon":
		var jump_i := 0 if velocity.y < JUMP_ASCENT_FRAME_0_WHILE_VY_LESS else 1
		_set_lawrence_hd_frame(_LAWRENCE_JUMP[jump_i])
	elif animation == "falling" or animation == "falling_weapon":
		_set_lawrence_hd_frame(_LAWRENCE_JUMP[1])
	elif animation == "climbing":
		_climb_anim_time += delta
		var climb_cycle := CLIMB_FRAME_DURATION * float(CLIMB_FRAME_COUNT)
		_climb_anim_time = fposmod(_climb_anim_time, climb_cycle)
		var climb_i := clampi(int(_climb_anim_time / CLIMB_FRAME_DURATION), 0, CLIMB_FRAME_COUNT - 1)
		_set_lawrence_hd_frame(_LAWRENCE_CLIMB[climb_i])
	else:
		_apply_atlas_sprite_scale()
		match animation:
			"crouch":
				sprite.frame = 0
			_:
				pass


func get_new_animation() -> String:
	if _is_vine_climbing_active():
		return "climbing"
	if _vine_crest_idle and not is_on_floor():
		return "idle"
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
	if _vine_crest_idle and not is_on_floor():
		_vine_crest_idle = false
		velocity.y = JUMP_VELOCITY
		_vine_latch_eligible_after_jump = true
		jump_sound.pitch_scale = 1.0
		jump_sound.play()
		return
	if _vine_climb_latched and not is_on_floor():
		_vine_climb_latched = false
		_vine_climb_cooldown = CLIMB_REATTACH_COOLDOWN
		velocity.y = JUMP_VELOCITY
		_vine_latch_eligible_after_jump = true
		jump_sound.pitch_scale = 1.0
		jump_sound.play()
		return
	if is_on_floor():
		jump_sound.pitch_scale = 1.0
	elif _double_jump_charged:
		_double_jump_charged = false
		velocity.x *= 2.5
		jump_sound.pitch_scale = 1.5
	else:
		return
	velocity.y = JUMP_VELOCITY
	_vine_latch_eligible_after_jump = true
	jump_sound.play()
