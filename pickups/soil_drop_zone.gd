extends Area2D

const _WILLOW_TREE_FRAMES: Array[Texture2D] = [
	preload("res://level/props/Tree_Willow/Willow1.png"),
	preload("res://level/props/Tree_Willow/Willow2.png"),
	preload("res://level/props/Tree_Willow/Willow3.png"),
	preload("res://level/props/Tree_Willow/Willow4.png"),
]

const _CYPRESS_TREE_FRAMES: Array[Texture2D] = [
	preload("res://level/props/Tree_Cypress/Cypress1.png"),
	preload("res://level/props/Tree_Cypress/Cypress2.png"),
	preload("res://level/props/Tree_Cypress/Cypress3.png"),
	preload("res://level/props/Tree_Cypress/Cypress4.png"),
]

## Multiplier for on-screen tree art vs `final_growth_*` layout constants (hitbox / drops follow this).
const TREE_FRAME_SCREEN_SCALE := 13.0
## Divide growth visuals / layout so frames are this many times smaller on screen.
const TREE_GROWTH_SHRINK := 6.0
## Extra downward shift (world pixels) so the tree sits lower on the patch.
const GROWTH_ANCHOR_Y_OFFSET := 20.0
## First growth frame height as a fraction of the final frame; then linearly ramps to 1.0.
const GROWTH_HEIGHT_START_FRAC := 1.0 / 5.0
## Multiplier for `growth_step_delay_sec` (1.714... = 75% faster than baseline 3.0).
const GROWTH_STEP_DURATION_MULT := 1.7142857
const _GROWTH_FRAME_COUNT := 4
const _GROWTH_FULLY_GROWN_EPSILON := 0.0001

const _GAME_THEME: Theme = preload("res://gui/theme.tres")
const _SOIL_HINT_TEXT := "a patch of soil"
const _LABEL_OUTLINE_PX := 3

@export var accepts: SeedDefs.Type = SeedDefs.Type.WILLOW_1
## Seconds between each of the four growth steps after planting.
@export var growth_step_delay_sec := 0.45
## Final placeholder plant height in world pixels (step 4).
@export var final_growth_height_px := 128.0
## Width of the final pink placeholder rectangle.
@export var final_growth_width_px := 24.0

## First willow patch (soil 1 or 2) to finish the pink placeholder from **willow #1** drops seed 2 once.
static var _willow_seed_2_released := false

var _inside: Array[Player] = []
var _soil_hint_layer: CanvasLayer
var _soil_hint_label: Label
var _planted := false
var _planted_kind: SeedDefs.Type = SeedDefs.Type.NONE
var _level_time_direction := 0
var _growth_frames: Array[Texture2D] = []
var _growth_progress := 0.0
var _was_fully_grown := false
var _growth_maturity_locked := false
var _growth_anchor: Node2D
var _growth_sprite: Sprite2D
var _growth_prompt: Node2D
var _level_time_bound := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_bind_to_level_time_direction()
	_setup_soil_proximity_hint()


func _mature_tree_title() -> String:
	match accepts:
		SeedDefs.Type.WILLOW_1, SeedDefs.Type.WILLOW_2:
			return "Black Willow Tree"
		SeedDefs.Type.CYPRESS:
			return "Blue Cypress Tree"
		_:
			return ""


func _on_body_entered(body: Node2D) -> void:
	if body is Player and body not in _inside:
		_inside.append(body as Player)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_inside.erase(body as Player)


func _setup_soil_proximity_hint() -> void:
	_soil_hint_layer = CanvasLayer.new()
	_soil_hint_layer.layer = 58
	add_child(_soil_hint_layer)
	_soil_hint_label = Label.new()
	_soil_hint_label.name = &"SoilPatchHintLabel"
	_soil_hint_label.text = _SOIL_HINT_TEXT
	_soil_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_soil_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_soil_hint_label.add_theme_font_override(&"font", _GAME_THEME.default_font)
	_soil_hint_label.add_theme_font_size_override(&"font_size", 13)
	_soil_hint_label.add_theme_color_override(&"font_color", Color(1, 1, 1, 1))
	_soil_hint_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
	_soil_hint_label.add_theme_constant_override(&"outline_size", _LABEL_OUTLINE_PX)
	_soil_hint_label.visible = false
	_soil_hint_layer.add_child(_soil_hint_label)


func _free_soil_proximity_hint() -> void:
	if is_instance_valid(_soil_hint_layer):
		_soil_hint_layer.queue_free()
	_soil_hint_layer = null
	_soil_hint_label = null


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not _level_time_bound:
		_bind_to_level_time_direction()
	if not _planted and is_instance_valid(_soil_hint_label):
		var soil_node := get_parent() as Node2D
		var center := soil_node.global_position if soil_node != null else global_position
		var show := PickupNearPlayer.any_seed_carrier_within_glow_distance(get_tree(), center)
		_soil_hint_label.visible = show
		if show:
			var viewport := get_viewport()
			if viewport != null:
				var world_pos := _hint_world_position()
				var xf := viewport.get_canvas_transform()
				var screen_pos: Vector2 = xf * world_pos
				_soil_hint_label.reset_size()
				_soil_hint_label.position = screen_pos - _soil_hint_label.size * 0.5
	var dead: Array[Player] = []
	for p in _inside:
		if not is_instance_valid(p):
			dead.append(p)
	for p in dead:
		_inside.erase(p)

	if _planted:
		_update_growth_state(_delta)
		return
	for p in _inside:
		if Input.is_action_just_pressed(&"drop_seed" + p.action_suffix):
			var held := p.get_held_seed_kind()
			if _wrong_cross_family_held(held):
				PointsPopup.spawn_message(
					p,
					_hint_world_position(),
					"try a different seed",
				)
				continue
			_try_plant(p)


func _bind_to_level_time_direction() -> void:
	var level := get_tree().get_first_node_in_group(&"game_level")
	if level == null:
		return
	if level.has_signal(&"time_direction_changed"):
		level.connect(&"time_direction_changed", _on_level_time_direction_changed)
	if level.has_method(&"get_time_direction"):
		_level_time_direction = int(level.get_time_direction())
	_level_time_bound = true


func _on_level_time_direction_changed(direction: int) -> void:
	_level_time_direction = clampi(direction, -1, 1)


func _hint_world_position() -> Vector2:
	var soil := get_parent() as Node2D
	if soil != null:
		return soil.global_position + Vector2(0, -50)
	return global_position + Vector2(0, -50)


func _wrong_cross_family_held(held: SeedDefs.Type) -> bool:
	if held == SeedDefs.Type.NONE:
		return false
	if _is_willow_soil() and held == SeedDefs.Type.CYPRESS:
		return true
	if accepts == SeedDefs.Type.CYPRESS and (
		held == SeedDefs.Type.WILLOW_1 or held == SeedDefs.Type.WILLOW_2
	):
		return true
	return false


func _is_willow_soil() -> bool:
	match accepts:
		SeedDefs.Type.WILLOW_1, SeedDefs.Type.WILLOW_2:
			return true
		_:
			return false


func _held_compatible_with_soil(held: SeedDefs.Type) -> bool:
	match accepts:
		SeedDefs.Type.WILLOW_1, SeedDefs.Type.WILLOW_2:
			return held == SeedDefs.Type.WILLOW_1 or held == SeedDefs.Type.WILLOW_2
		SeedDefs.Type.CYPRESS:
			return held == SeedDefs.Type.CYPRESS
		_:
			return false


func _try_plant(planter: Player) -> void:
	if not _held_compatible_with_soil(planter.get_held_seed_kind()):
		return
	var planted_kind := planter.get_held_seed_kind()
	if not planter.consume_held_for_soil(accepts):
		return
	var soil := get_parent() as Sprite2D
	if soil:
		soil.modulate = Color(0.82, 1.0, 0.82)
	var pop_world := _hint_world_position()
	planter.add_score(Player.POINTS_SOIL_PLANT)
	PointsPopup.spawn(planter, pop_world, Player.POINTS_SOIL_PLANT)
	_planted = true
	_planted_kind = planted_kind
	set_deferred(&"monitoring", false)
	_start_growth_sequence(planted_kind)


func _retire_drop_zone_for_plant() -> void:
	_free_soil_proximity_hint()
	monitoring = false
	collision_layer = 0
	collision_mask = 0
	visible = false


func _tree_frame_textures() -> Array[Texture2D]:
	match accepts:
		SeedDefs.Type.WILLOW_1, SeedDefs.Type.WILLOW_2:
			return _WILLOW_TREE_FRAMES
		SeedDefs.Type.CYPRESS:
			return _CYPRESS_TREE_FRAMES
		_:
			return _WILLOW_TREE_FRAMES


func _apply_growth_frame(sprite: Sprite2D, tex: Texture2D, height_frac: float) -> void:
	sprite.texture = tex
	sprite.centered = true
	if tex == null:
		return
	var tex_h := float(tex.get_height())
	var target_h := (
		final_growth_height_px * height_frac * TREE_FRAME_SCREEN_SCALE / TREE_GROWTH_SHRINK
	)
	var s := target_h / tex_h if tex_h > 0.0 else 1.0
	sprite.scale = Vector2(s, s)
	# Anchor origin = this DropZone's origin in soil space; tree grows upward (negative Y).
	sprite.position = Vector2(0.0, -0.5 * tex_h * s)


func _start_growth_sequence(planted_kind: SeedDefs.Type) -> void:
	var soil := get_parent() as Node2D
	if soil == null:
		return

	_growth_frames = _tree_frame_textures()
	if _growth_frames.size() < _GROWTH_FRAME_COUNT:
		return

	_retire_drop_zone_for_plant()

	var anchor := Node2D.new()
	anchor.name = &"PlantedGrowth"
	# Keep cumulative z below the player (player root z=2 + sprite 0) so the tree never occludes the character.
	anchor.z_index = 1

	# Parent growth beside the soil patch so we can hide the soil texture (otherwise it draws on top of the tree).
	var holder := soil.get_parent() as Node2D
	var gpos := global_position
	var grot := global_rotation
	if holder != null:
		holder.add_child(anchor)
		anchor.global_position = gpos
		anchor.global_rotation = grot
		soil.visible = false
	else:
		soil.add_child(anchor)
		anchor.position = position
		anchor.rotation = rotation

	anchor.global_position += Vector2(0.0, GROWTH_ANCHOR_Y_OFFSET)

	# Willow trees use the same world Y as the cypress patch’s DropZone (plus the same nudge).
	if _is_willow_soil():
		var soils := holder if holder != null else soil.get_parent() as Node2D
		if soils != null:
			var cypress_dz := soils.get_node_or_null(^"CypressSoil/DropZone") as Node2D
			if cypress_dz != null and is_instance_valid(cypress_dz):
				anchor.global_position.y = (
					cypress_dz.global_position.y + GROWTH_ANCHOR_Y_OFFSET
				)

	var sprite := Sprite2D.new()
	sprite.name = &"GrowthSprite"
	sprite.z_index = 0
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	anchor.add_child(sprite)

	_growth_anchor = anchor
	_growth_sprite = sprite
	_growth_progress = 0.0
	_was_fully_grown = false
	_growth_maturity_locked = false
	_apply_growth_visual_frame()


func _growth_total_duration_sec() -> float:
	var segment_count := maxf(1.0, float(_growth_frames.size() - 1))
	return growth_step_delay_sec * GROWTH_STEP_DURATION_MULT * segment_count


func _update_growth_state(delta: float) -> void:
	if not is_instance_valid(_growth_sprite) or _growth_frames.is_empty():
		return
	if _growth_maturity_locked:
		_growth_progress = 1.0
		_apply_growth_visual_frame()
		return
	var total_duration := _growth_total_duration_sec()
	if total_duration > 0.0:
		var direction := float(clampi(_level_time_direction, -1, 1))
		_growth_progress = clampf(_growth_progress + direction * (delta / total_duration), 0.0, 1.0)
	_apply_growth_visual_frame()
	_update_growth_completion_state()


func _apply_growth_visual_frame() -> void:
	if not is_instance_valid(_growth_sprite) or _growth_frames.is_empty():
		return
	var last_i := _growth_frames.size() - 1
	var frame_t := _growth_progress * float(last_i)
	var frame_i := clampi(int(floor(frame_t + 0.000001)), 0, last_i)
	var height_frac := lerpf(GROWTH_HEIGHT_START_FRAC, 1.0, _growth_progress)
	_apply_growth_frame(_growth_sprite, _growth_frames[frame_i], height_frac)


func _update_growth_completion_state() -> void:
	var fully_grown := _growth_progress >= 1.0 - _GROWTH_FULLY_GROWN_EPSILON
	if fully_grown == _was_fully_grown:
		return
	_was_fully_grown = fully_grown
	if fully_grown:
		_growth_maturity_locked = true
		_notify_smog_tree_matured()
		_ensure_tree_prompt()
		_maybe_release_willow_seed_2()
	else:
		_remove_tree_prompt()


func _ensure_tree_prompt() -> void:
	if not is_instance_valid(_growth_anchor):
		return
	if is_instance_valid(_growth_prompt):
		return
	var prompt := Node2D.new()
	prompt.name = &"TreeNamePrompt"
	prompt.set_script(preload("res://pickups/planted_tree_prompt.gd"))
	prompt.title_text = _mature_tree_title()
	prompt.rect_width_px = final_growth_width_px * TREE_FRAME_SCREEN_SCALE / TREE_GROWTH_SHRINK
	prompt.rect_height_px = final_growth_height_px * TREE_FRAME_SCREEN_SCALE / TREE_GROWTH_SHRINK
	_growth_anchor.add_child(prompt)
	_growth_prompt = prompt


func _remove_tree_prompt() -> void:
	if not is_instance_valid(_growth_prompt):
		_growth_prompt = null
		return
	_growth_prompt.queue_free()
	_growth_prompt = null


func _maybe_release_willow_seed_2() -> void:
	if (
		not _is_willow_soil()
		or _planted_kind != SeedDefs.Type.WILLOW_1
		or _willow_seed_2_released
		or not is_instance_valid(_growth_anchor)
	):
		return
	_willow_seed_2_released = true
	var vis_h := final_growth_height_px * TREE_FRAME_SCREEN_SCALE / TREE_GROWTH_SHRINK
	var vis_w := final_growth_width_px * TREE_FRAME_SCREEN_SCALE / TREE_GROWTH_SHRINK
	var top_global: Vector2 = _growth_anchor.to_global(Vector2(0, -vis_h))
	# Beside the tree base; then nudge land 5px up (screen) and scatter X ±10–20px in world space.
	var land_local := Vector2(vis_w * 0.5 + 14.0, 16.0)
	var land_global: Vector2 = _growth_anchor.to_global(land_local)
	var x_scatter := (1.0 if randf() < 0.5 else -1.0) * randf_range(10.0, 20.0)
	land_global += Vector2(x_scatter, -5.0)
	var lv: Node = get_tree().get_first_node_in_group(&"game_level")
	if lv and lv.has_method(&"drop_willow_seed_2_from"):
		lv.drop_willow_seed_2_from(top_global, land_global)


func _notify_smog_tree_matured() -> void:
	get_tree().call_group(&"smog_parallax_fade", &"register_tree_matured")
