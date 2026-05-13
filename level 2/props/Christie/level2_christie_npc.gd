extends Node2D
## **Runtime-only** NPC: not saved in **`level_2.tscn`**, so she does **not** appear in the **2D editor** for that scene. Spawned after both planter zones mature → butterflies release → **2 s** delay (**`planter_butterfly_coordinator.gd`**). Uses **`BuildingPink`** for spawn anchor.

const _FWD1: Texture2D = preload("res://level 2/props/Christie/fwd1.png")
const _FWD2: Texture2D = preload("res://level 2/props/Christie/fwd2.png")
const _RITE1: Texture2D = preload("res://level 2/props/Christie/rite1.png")
const _RITE2: Texture2D = preload("res://level 2/props/Christie/rite2.png")
const _PLAY1: Texture2D = preload("res://level 2/props/Christie/play1.png")
const _PLAY2: Texture2D = preload("res://level 2/props/Christie/play2.png")

const _SPRITE_TARGET_HEIGHT_PX := 132.0
## **1.5** → all walk / idle timings **50 % longer** (slower animation).
const _CHRISTIE_ANIM_TIMING_MULT := 1.5
const _WALK_FRAME_SEC := 0.16 * _CHRISTIE_ANIM_TIMING_MULT
## One **round** through **fwd1 → fwd2 → fwd1 → fwd2** (four steps at **`_WALK_FRAME_SEC`** each).
const _FWD_STEP_COUNT := 4
const _FWD_MOVE_PX := 96.0
const _RITE_STEP_COUNT := 6
const _RITE_MOVE_PX := 160.0
const _PLAY_FRAME_SEC := 0.38 * _CHRISTIE_ANIM_TIMING_MULT
## After this many **PLAY** sprite holds (**play1** / **play2** alternation), Christie has finished her performance for the mission HUD congrats line.
const _PLAY_HOLDS_BEFORE_PERFORMANCE_COMPLETE := 8
## Toward the street / down-screen (**+Y**) from the pink façade.
const _FWD_MOVE_DIR := Vector2(0.0, 1.0)

const _CHRISTIE_Z := 6

enum _Phase { FWD, RITE, PLAY }

var _spr: Sprite2D
var _phase := _Phase.FWD
var _phase_time := 0.0
var _fwd_anchor := Vector2.ZERO
var _rite_anchor := Vector2.ZERO
var _christie_performance_reported := false


func begin_walk_sequence() -> void:
	if Engine.is_editor_hint():
		return
	_spr = Sprite2D.new()
	_spr.name = &"Sprite2D"
	_spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_spr.centered = true
	_spr.z_as_relative = true
	_spr.z_index = _CHRISTIE_Z
	add_child(_spr)
	_apply_height_scale(_FWD1)
	_place_at_building_pink_bottom_center()
	_fwd_anchor = global_position
	_phase = _Phase.FWD
	_phase_time = 0.0
	_christie_performance_reported = false
	_spr.texture = _FWD1
	set_physics_process(true)


func _apply_height_scale(tex: Texture2D) -> void:
	if tex == null:
		return
	var th := float(tex.get_height())
	var s := _SPRITE_TARGET_HEIGHT_PX / maxf(1.0, th)
	_spr.scale = Vector2(s, s)


func _place_at_building_pink_bottom_center() -> void:
	var lv := get_parent() as Node2D
	if lv == null:
		push_warning("Christie: no parent Level node; cannot place.")
		return
	var pink_spr := lv.get_node_or_null(^"Buildings/BuildingPink/Sprite2D") as Sprite2D
	if pink_spr != null and pink_spr.texture != null:
		var r := pink_spr.get_rect()
		var xf := pink_spr.get_global_transform()
		var bottom_mid := xf * Vector2(r.get_center().x, r.end.y)
		global_position = bottom_mid + Vector2(0.0, -_sprite_half_height_world())
		return
	var pink_body := lv.get_node_or_null(^"Buildings/BuildingPink") as Node2D
	if pink_body != null:
		global_position = pink_body.global_position + Vector2(0.0, 120.0)
		push_warning("Christie: BuildingPink/Sprite2D missing; using BuildingPink origin fallback.")
		return
	push_warning("Christie: BuildingPink not found; staying at spawn origin (may be off-screen).")


func _sprite_half_height_world() -> float:
	if _spr == null or _spr.texture == null:
		return _SPRITE_TARGET_HEIGHT_PX * 0.5
	var th := float(_spr.texture.get_height())
	var sy := absf(_spr.scale.y)
	return th * sy * 0.5


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or _spr == null:
		return
	_phase_time += delta
	match _phase:
		_Phase.FWD:
			_process_walk(
				_FWD1,
				_FWD2,
				_WALK_FRAME_SEC,
				_FWD_STEP_COUNT,
				_FWD_MOVE_PX,
				_FWD_MOVE_DIR.normalized(),
				_fwd_anchor,
				_Phase.RITE,
			)
		_Phase.RITE:
			_process_walk(
				_RITE1,
				_RITE2,
				_WALK_FRAME_SEC,
				_RITE_STEP_COUNT,
				_RITE_MOVE_PX,
				Vector2(1.0, 0.0),
				_rite_anchor,
				_Phase.PLAY,
			)
		_Phase.PLAY:
			_process_play_idle()


func _process_walk(
	tex_a: Texture2D,
	tex_b: Texture2D,
	frame_sec: float,
	step_count: int,
	move_px: float,
	move_dir: Vector2,
	anchor: Vector2,
	next: _Phase,
) -> void:
	var dur := float(step_count) * frame_sec
	var t := clampf(_phase_time / maxf(0.0001, dur), 0.0, 1.0)
	global_position = anchor + move_dir * (move_px * t)
	var fi := clampi(int(floor(_phase_time / frame_sec)), 0, step_count - 1)
	_spr.texture = tex_a if (fi % 2) == 0 else tex_b
	if _phase_time + 0.0001 >= dur:
		global_position = anchor + move_dir * move_px
		if next == _Phase.RITE:
			_rite_anchor = global_position
		_phase = next
		_phase_time = 0.0
		if next == _Phase.PLAY:
			_spr.texture = _PLAY1


func _process_play_idle() -> void:
	var fi := int(floor(_phase_time / _PLAY_FRAME_SEC))
	_spr.texture = _PLAY1 if (fi % 2) == 0 else _PLAY2
	if _christie_performance_reported:
		return
	if _phase_time + 0.0001 >= _PLAY_FRAME_SEC * float(_PLAY_HOLDS_BEFORE_PERFORMANCE_COMPLETE):
		_christie_performance_reported = true
		add_to_group(&"christie_performance_complete")
