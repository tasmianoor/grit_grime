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

const _CYPRESS_ROOT_FRAMES: Array[Texture2D] = [
	preload("res://level/props/Roots/Roots1.png"),
	preload("res://level/props/Roots/Roots2.png"),
	preload("res://level/props/Roots/Roots3.png"),
	preload("res://level/props/Roots/Roots4.png"),
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
const _CYPRESS_ROOT_STEP_SEC := 0.42

const _SPARROW_AMBIENT_SCENE: PackedScene = preload(
	"res://level/props/birds/Sparrow/sparrow_ambient.tscn"
)

const _KINGFISHER_AMBIENT_ENSURE := preload("res://pickups/kingfisher_ambient_ensure.gd")

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
var _roots_body: Node2D
var _roots_sprite: Sprite2D
var _roots_frame_idx: int = 0
var _roots_time_accum: float = 0.0
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
		_advance_cypress_roots_if_any(delta)
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
		_start_cypress_roots()
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


func _start_cypress_roots() -> void:
	if accepts != SeedDefs.Type.CYPRESS:
		return
	if _CYPRESS_ROOT_FRAMES.is_empty():
		return
	if _roots_body != null and is_instance_valid(_roots_body):
		return
	if not is_instance_valid(_growth_anchor) or not is_instance_valid(_growth_sprite):
		return
	var tex := _growth_sprite.texture
	if tex == null:
		return
	var s := _growth_sprite.scale
	var half_w := tex.get_width() * 0.5 * absf(s.x)
	var half_h := tex.get_height() * 0.5 * absf(s.y)
	var trunk_right_x := _growth_sprite.position.x + half_w
	var base_y := _growth_sprite.position.y + half_h

	var root_node := Node2D.new()
	root_node.name = &"CypressRoots"
	root_node.add_to_group(&"cypress_roots_prop")

	var rs := Sprite2D.new()
	rs.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rs.texture = _CYPRESS_ROOT_FRAMES[0]
	rs.centered = true
	var r0 := _CYPRESS_ROOT_FRAMES[0]
	var match_h := tex.get_height() * absf(s.y) * 0.48
	var rs_sc := match_h / maxf(1.0, float(r0.get_height())) * 0.75
	rs.scale = Vector2(rs_sc, rs_sc)
	var rw := float(r0.get_width()) * rs_sc
	var roots_local := Vector2(trunk_right_x + rw * 0.22, base_y - match_h * 0.38)
	var roots_global := _growth_anchor.to_global(roots_local)

	root_node.add_child(rs)

	var holder := _growth_anchor.get_parent() as Node2D
	var level := holder.get_parent() as Node2D if holder != null else null
	if level != null:
		level.add_child(root_node)
		root_node.global_position = roots_global
		# Above tilemap (z=1) and most props (z<=2); below trash pickups (z=4) and player (z=5).
		root_node.z_index = 3
		var trash_idx := _level_child_index_first_trash_pickup(level)
		if trash_idx >= 0:
			level.move_child(root_node, trash_idx)
	else:
		root_node.z_index = 3
		_growth_anchor.add_child(root_node)
		root_node.position = roots_local

	_roots_body = root_node
	_roots_sprite = rs
	_roots_frame_idx = 0
	_roots_time_accum = 0.0
	_update_cypress_roots_river_tile_floor()


func _level_child_index_first_trash_pickup(level: Node) -> int:
	for i in range(level.get_child_count()):
		var ch := level.get_child(i)
		if ch is Area2D:
			var path := String((ch as Area2D).scene_file_path)
			if path.contains("trash_pickup.tscn"):
				return i
	return -1


func _update_cypress_roots_river_tile_floor() -> void:
	if _roots_sprite == null or not is_instance_valid(_roots_sprite):
		return
	if _roots_body == null or not is_instance_valid(_roots_body):
		return
	var level := _roots_body.get_parent() as Node2D
	if level == null:
		return
	var tm := level.get_node_or_null(^"TileMap") as TileMap
	if tm == null or not tm.has_method(&"add_cypress_river_floor_cells"):
		return
	var cells := _river_cells_under_cypress_roots_sprite(tm)
	if cells.is_empty():
		return
	tm.call(&"add_cypress_river_floor_cells", cells)


func _river_cells_under_cypress_roots_sprite(tm: TileMap) -> Array[Vector2i]:
	var spr := _roots_sprite
	var rtex := spr.texture
	if rtex == null:
		return []
	var w := float(rtex.get_width()) * absf(spr.scale.x)
	var h := float(rtex.get_height()) * absf(spr.scale.y)
	var pad := 10.0
	var c := spr.global_position
	var world_rect := Rect2(c.x - w * 0.5 - pad, c.y - h * 0.5 - pad, w + pad * 2.0, h + pad * 2.0)
	var p0 := tm.local_to_map(tm.to_local(world_rect.position))
	var p1 := tm.local_to_map(tm.to_local(world_rect.position + Vector2(world_rect.size.x, 0.0)))
	var p2 := tm.local_to_map(tm.to_local(world_rect.end))
	var p3 := tm.local_to_map(tm.to_local(world_rect.position + Vector2(0.0, world_rect.size.y)))
	var min_x := mini(mini(p0.x, p1.x), mini(p2.x, p3.x))
	var max_x := maxi(maxi(p0.x, p1.x), maxi(p2.x, p3.x))
	var min_y := mini(mini(p0.y, p1.y), mini(p2.y, p3.y))
	var max_y := maxi(maxi(p0.y, p1.y), maxi(p2.y, p3.y))
	var rid := RiverTileQueries.RIVER_SOURCE_ID
	var out: Array[Vector2i] = []
	for x in range(min_x, max_x + 1):
		for y in range(min_y, max_y + 1):
			var cel := Vector2i(x, y)
			if tm.get_cell_source_id(0, cel) == rid:
				out.append(cel)
	return out


func _advance_cypress_roots_if_any(delta: float) -> void:
	if _roots_body == null or not is_instance_valid(_roots_body):
		return
	if _roots_sprite == null or not is_instance_valid(_roots_sprite):
		return
	if _CYPRESS_ROOT_FRAMES.is_empty():
		return
	if _roots_frame_idx >= _CYPRESS_ROOT_FRAMES.size() - 1:
		return
	_roots_time_accum += delta
	while _roots_time_accum >= _CYPRESS_ROOT_STEP_SEC:
		_roots_time_accum -= _CYPRESS_ROOT_STEP_SEC
		if _roots_frame_idx >= _CYPRESS_ROOT_FRAMES.size() - 1:
			break
		_roots_frame_idx += 1
		_roots_sprite.texture = _CYPRESS_ROOT_FRAMES[_roots_frame_idx]
		_update_cypress_roots_river_tile_floor()


func _notify_smog_tree_matured() -> void:
	get_tree().call_group(&"smog_parallax_fade", &"register_tree_matured")
	var ambient := _ensure_sparrow_ambient_node()
	if ambient != null and ambient.has_method(&"notify_one_tree_matured"):
		ambient.notify_one_tree_matured()
	var kf: Node = _KINGFISHER_AMBIENT_ENSURE.ensure_under_game_level(get_tree())
	if kf != null and kf.has_method(&"notify_tree_matured"):
		kf.notify_tree_matured()


func _ensure_sparrow_ambient_node() -> Node:
	if Engine.is_editor_hint():
		return null
	var tree := get_tree()
	if tree == null:
		return null
	for n in tree.get_nodes_in_group(&"sparrows_ambient"):
		return n
	var level := tree.get_first_node_in_group(&"game_level") as Node2D
	if level == null:
		return null
	var root := _SPARROW_AMBIENT_SCENE.instantiate()
	level.add_child(root)
	return root
