extends Area2D

const _GAME_THEME: Theme = preload("res://gui/theme.tres")

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
## Multiplier for `growth_step_delay_sec` (3 = thrice as long between frames).
const GROWTH_STEP_DURATION_MULT := 3.0

@export var accepts: SeedDefs.Type = SeedDefs.Type.WILLOW_1
## Seconds between each of the four growth steps after planting.
@export var growth_step_delay_sec := 0.45
## Final placeholder plant height in world pixels (step 4).
@export var final_growth_height_px := 128.0
## Width of the final pink placeholder rectangle.
@export var final_growth_width_px := 24.0

## First willow patch (soil 1 or 2) to finish the pink placeholder from **willow #1** drops seed 2 once.
static var _willow_seed_2_released := false

const _LABEL_OUTLINE_PX := 3

var _inside: Array[Player] = []
var _layer: CanvasLayer
var _label: Label
var _planted := false


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_setup_label()


func _setup_label() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 60
	add_child(_layer)
	_label = Label.new()
	_label.text = _prompt_text()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_override(&"font", _GAME_THEME.default_font)
	_label.add_theme_font_size_override(&"font_size", 13)
	_label.add_theme_color_override(&"font_color", Color(1, 1, 1, 1))
	_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
	_label.add_theme_constant_override(&"outline_size", _LABEL_OUTLINE_PX)
	_label.visible = false
	_layer.add_child(_label)


func _prompt_text() -> String:
	match accepts:
		SeedDefs.Type.WILLOW_1, SeedDefs.Type.WILLOW_2:
			return "Plant Willow Seed Here"
		SeedDefs.Type.CYPRESS:
			return "Plant Cypress Seed Here"
		_:
			return ""


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


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var dead: Array[Player] = []
	for p in _inside:
		if not is_instance_valid(p):
			dead.append(p)
	for p in dead:
		_inside.erase(p)

	_update_prompt_label()

	if _planted:
		return
	for p in _inside:
		if Input.is_action_just_pressed(&"drop_seed" + p.action_suffix):
			_try_plant(p)


func _update_prompt_label() -> void:
	if _label == null or _planted:
		return
	var show := not _inside.is_empty()
	_label.visible = show
	if not show:
		return
	var soil := get_parent() as Node2D
	if soil == null:
		return
	var viewport := get_viewport()
	if viewport == null:
		return
	var world_pos := soil.global_position + Vector2(0, -50)
	var xf := viewport.get_canvas_transform()
	var screen_pos: Vector2 = xf * world_pos
	_label.reset_size()
	_label.position = screen_pos - _label.size * 0.5


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


func _try_plant(player: Player) -> void:
	if not _held_compatible_with_soil(player.get_held_seed_kind()):
		return
	var planted_kind := player.get_held_seed_kind()
	if not player.consume_held_for_soil(accepts):
		return
	var soil := get_parent() as Sprite2D
	if soil:
		soil.modulate = Color(0.82, 1.0, 0.82)
	_planted = true
	if _label:
		_label.visible = false
	set_deferred(&"monitoring", false)
	_start_growth_sequence(planted_kind)


func _retire_drop_zone_for_plant() -> void:
	set_physics_process(false)
	monitoring = false
	collision_layer = 0
	collision_mask = 0
	visible = false
	if is_instance_valid(_layer):
		_layer.visible = false


func _remove_drop_zone_node_when_done() -> void:
	if is_instance_valid(self):
		queue_free()


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

	var frames := _tree_frame_textures()
	if frames.size() < 4:
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

	# Four frames: scale from 1/5 of final height to full height, evenly stepped.
	var last_i := frames.size() - 1
	for step in frames.size():
		if not is_instance_valid(sprite):
			_remove_drop_zone_node_when_done()
			return
		var t := float(step) / float(last_i) if last_i > 0 else 0.0
		var height_frac := lerpf(GROWTH_HEIGHT_START_FRAC, 1.0, t)
		_apply_growth_frame(sprite, frames[step], height_frac)
		if step < last_i:
			await get_tree().create_timer(
				growth_step_delay_sec * GROWTH_STEP_DURATION_MULT
			).timeout

	if is_instance_valid(anchor):
		var prompt := Node2D.new()
		prompt.name = &"TreeNamePrompt"
		prompt.set_script(preload("res://pickups/planted_tree_prompt.gd"))
		prompt.title_text = _mature_tree_title()
		prompt.rect_width_px = final_growth_width_px * TREE_FRAME_SCREEN_SCALE / TREE_GROWTH_SHRINK
		prompt.rect_height_px = final_growth_height_px * TREE_FRAME_SCREEN_SCALE / TREE_GROWTH_SHRINK
		anchor.add_child(prompt)

	if (
		_is_willow_soil()
		and planted_kind == SeedDefs.Type.WILLOW_1
		and not _willow_seed_2_released
		and is_instance_valid(anchor)
	):
		_willow_seed_2_released = true
		var vis_h := final_growth_height_px * TREE_FRAME_SCREEN_SCALE / TREE_GROWTH_SHRINK
		var vis_w := final_growth_width_px * TREE_FRAME_SCREEN_SCALE / TREE_GROWTH_SHRINK
		var top_global: Vector2 = anchor.to_global(Vector2(0, -vis_h))
		# Beside the tree base; then nudge land 5px up (screen) and scatter X ±10–20px in world space.
		var land_local := Vector2(vis_w * 0.5 + 14.0, 16.0)
		var land_global: Vector2 = anchor.to_global(land_local)
		var x_scatter := (1.0 if randf() < 0.5 else -1.0) * randf_range(10.0, 20.0)
		land_global += Vector2(x_scatter, -5.0)
		var lv: Node = get_tree().get_first_node_in_group(&"game_level")
		if lv and lv.has_method(&"drop_willow_seed_2_from"):
			lv.drop_willow_seed_2_from(top_global, land_global)

	_remove_drop_zone_node_when_done()
