extends Node
## Runs once all three AC upgrades are done and Lawrence has stamped each colored roof (Pink / Yellow / Green):
## floating bill props across the level (they stay forever), then after Lawrence is on the floor and a short pause, the van crosses the level (sorted like the player vs depth trees; stops at level world center X).

const _NOTE_FLOAT_SEC := 3.0
const _GROUND_THEN_VAN_DELAY_SEC := 3.0
const _NOTE_COUNT := 4
## Matches `level 2/level.gd` camera / scroll limits (world px).
const _LEVEL_LIMIT_LEFT := -1200.0
const _LEVEL_LIMIT_TOP := -250.0
const _LEVEL_LIMIT_RIGHT := 2200.0
const _LEVEL_LIMIT_BOTTOM := 1050.0
const _NOTE_BOUNDS_PAD := 48.0

## Matches `player/player.tscn` root **Player** `z_index` so depth vs `tree_depth_vs_player.gd` trees matches Lawrence.
const _VAN_SORT_Z_MATCH_PLAYER := 5

const _MNOTE_TEXTURES: Array[Texture2D] = [
	preload("res://level 2/props/mnotes/1@2x.png"),
	preload("res://level 2/props/mnotes/2@2x.png"),
	preload("res://level 2/props/mnotes/3@2x.png"),
	preload("res://level 2/props/mnotes/4@2x.png"),
]

const _VAN_FRAMES: Array[Texture2D] = [
	preload("res://level 2/props/van/van 1.png"),
	preload("res://level 2/props/van/van2.png"),
	preload("res://level 2/props/van/van3.png"),
	preload("res://level 2/props/van/van4.png"),
	preload("res://level 2/props/van/van5.png"),
]

@export var van_lane_y := 558.0
@export var van_height_px := 170.0
@export var van_enter_duration_sec := 2.2
@export var van_pause_at_center_sec := 0.45
@export var van_exit_duration_sec := 2.7
@export var van_frame_duration_sec := 0.09
@export var van_enter_offset_x := 1050.0
@export var van_exit_extra_x := 1300.0
@export var note_height_px := 32.0

var _sequence_started := false
var _note_holder: Node2D
var _note_entries: Array[Dictionary] = []
var _note_float_mid := Vector2.ZERO
var _note_float_half := Vector2.ZERO

var _van_sprite: Sprite2D
var _van_frame_index := 0
var _van_frame_timer: Timer


func _ready() -> void:
	set_process(false)


func _physics_process(_delta: float) -> void:
	if _sequence_started:
		return
	var tree := get_tree()
	if tree == null:
		return
	var bs := get_parent().get_node_or_null(^"BStreet") as Node
	if bs == null or not bs.has_method(&"are_all_roofs_complete"):
		return
	if not bool(bs.call(&"are_all_roofs_complete")):
		return
	if not _all_ac_upgrades_done(tree):
		return
	_sequence_started = true
	set_physics_process(false)
	_run_sequence.call_deferred()


func _run_sequence() -> void:
	await _float_money_notes_phase()
	await _wait_lawrence_grounded_then_van_delay()
	await _van_phase()


func _all_ac_upgrades_done(tree: SceneTree) -> bool:
	var units := tree.get_nodes_in_group(&"ac_old_unit")
	if units.is_empty():
		return false
	for n in units:
		if not n.has_method(&"is_ac_upgrade_complete"):
			return false
		if not bool(n.call(&"is_ac_upgrade_complete")):
			return false
	return true


func _lawrence() -> CharacterBody2D:
	var tree := get_tree()
	if tree == null:
		return null
	for n in tree.get_nodes_in_group(&"player"):
		if n is Player:
			return n as CharacterBody2D
	return null


func _note_float_bounds() -> Rect2:
	var L := _LEVEL_LIMIT_LEFT + _NOTE_BOUNDS_PAD
	var T := _LEVEL_LIMIT_TOP + _NOTE_BOUNDS_PAD
	var R := _LEVEL_LIMIT_RIGHT - _NOTE_BOUNDS_PAD
	var B := _LEVEL_LIMIT_BOTTOM - _NOTE_BOUNDS_PAD
	return Rect2(L, T, R - L, B - T)


func _float_money_notes_phase() -> void:
	var lv := get_parent() as Node2D
	if lv == null:
		return
	_note_holder = Node2D.new()
	_note_holder.z_index = 24
	lv.add_child(_note_holder)
	var nb := _note_float_bounds()
	_note_float_mid = nb.get_center()
	_note_float_half = nb.size * 0.5
	_note_entries.clear()
	var h_target := maxf(1.0, note_height_px)
	for i in _NOTE_COUNT:
		var wrap := Node2D.new()
		var spr := Sprite2D.new()
		var tex: Texture2D = _MNOTE_TEXTURES[i]
		spr.texture = tex
		var th := float(tex.get_height())
		var s := h_target / maxf(1.0, th)
		spr.scale = Vector2(s, s)
		wrap.add_child(spr)
		_note_holder.add_child(wrap)
		wrap.global_position = Vector2(
			randf_range(nb.position.x, nb.position.x + nb.size.x),
			randf_range(nb.position.y, nb.position.y + nb.size.y),
		)
		_note_entries.append({
			&"node": wrap,
			&"phase": randf() * TAU,
			&"freq_x": randf_range(0.085, 0.2),
			&"freq_y": randf_range(0.095, 0.22),
			&"off_x": randf() * TAU,
			&"off_y": randf() * TAU,
		})
	set_process(true)
	await get_tree().create_timer(_NOTE_FLOAT_SEC).timeout


func _process(_delta: float) -> void:
	if _note_holder == null or not is_instance_valid(_note_holder) or _note_entries.is_empty():
		return
	for e in _note_entries:
		var nd: Node2D = e[&"node"]
		if not is_instance_valid(nd):
			continue
		var ph: float = e[&"phase"]
		ph += _delta
		e[&"phase"] = ph
		var fx: float = e[&"freq_x"]
		var fy: float = e[&"freq_y"]
		var ox: float = e[&"off_x"]
		var oy: float = e[&"off_y"]
		nd.global_position = _note_float_mid + Vector2(
			sin(ph * fx + ox) * _note_float_half.x,
			sin(ph * fy + oy) * _note_float_half.y,
		)


func _wait_lawrence_grounded_then_van_delay() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var p := _lawrence()
	if p != null:
		while is_instance_valid(p) and not p.is_on_floor():
			await tree.physics_frame
	await tree.create_timer(_GROUND_THEN_VAN_DELAY_SEC).timeout


func _level_mid_x() -> float:
	return (_LEVEL_LIMIT_LEFT + _LEVEL_LIMIT_RIGHT) * 0.5


func _van_phase() -> void:
	var tree := get_tree()
	var lv := get_parent() as Node2D
	if tree == null or lv == null:
		return
	_van_sprite = Sprite2D.new()
	_van_sprite.texture = _VAN_FRAMES[0]
	_van_sprite_apply_height()
	lv.add_child(_van_sprite)
	_van_sprite.z_as_relative = true
	_van_sprite.z_index = _VAN_SORT_Z_MATCH_PLAYER
	var mid_x := _level_mid_x()
	var y := van_lane_y
	var start := Vector2(mid_x - van_enter_offset_x, y)
	var hold := Vector2(mid_x, y)
	var exit := Vector2(mid_x + van_exit_extra_x, y)
	_van_sprite.global_position = start
	_van_frame_index = 0
	_van_frame_timer = Timer.new()
	_van_frame_timer.wait_time = van_frame_duration_sec
	_van_frame_timer.one_shot = false
	_van_frame_timer.timeout.connect(_on_van_frame_tick)
	add_child(_van_frame_timer)
	_van_frame_timer.start()
	var tw := create_tween()
	tw.tween_property(_van_sprite, "global_position", hold, van_enter_duration_sec).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tw.finished
	await tree.create_timer(van_pause_at_center_sec).timeout
	var tw2 := create_tween()
	tw2.tween_property(_van_sprite, "global_position", exit, van_exit_duration_sec).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tw2.finished
	if is_instance_valid(_van_frame_timer):
		_van_frame_timer.stop()
		_van_frame_timer.queue_free()
	_van_frame_timer = null
	if is_instance_valid(_van_sprite):
		_van_sprite.queue_free()
	_van_sprite = null


func _van_sprite_apply_height() -> void:
	if not is_instance_valid(_van_sprite):
		return
	var tex := _van_sprite.texture
	if tex == null:
		return
	var th := float(tex.get_height())
	var s := van_height_px / maxf(1.0, th)
	_van_sprite.scale = Vector2(s, s)


func _on_van_frame_tick() -> void:
	if not is_instance_valid(_van_sprite):
		return
	_van_frame_index = (_van_frame_index + 1) % _VAN_FRAMES.size()
	_van_sprite.texture = _VAN_FRAMES[_van_frame_index]
	_van_sprite_apply_height()
