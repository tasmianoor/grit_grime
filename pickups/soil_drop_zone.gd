extends Area2D

const _GAME_THEME: Theme = preload("res://gui/theme.tres")

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


func _soil_surface_local_y(soil: Node2D) -> float:
	var spr := soil as Sprite2D
	if spr != null and spr.texture != null:
		return -spr.texture.get_height() * 0.5 * absf(spr.scale.y)
	return -20.0


func _rect_polygon(width: float, height: float) -> PackedVector2Array:
	var hw := width * 0.5
	return PackedVector2Array([
		Vector2(-hw, 0),
		Vector2(hw, 0),
		Vector2(hw, -height),
		Vector2(-hw, -height),
	])


func _start_growth_sequence(planted_kind: SeedDefs.Type) -> void:
	var soil := get_parent() as Node2D
	if soil == null:
		return

	var anchor := Node2D.new()
	anchor.name = &"PlantedGrowth"
	anchor.z_index = 2
	anchor.position = Vector2(0, _soil_surface_local_y(soil))
	soil.add_child(anchor)

	var poly := Polygon2D.new()
	anchor.add_child(poly)

	# Step 1: seed just under surface (small, dark).
	poly.polygon = _rect_polygon(12.0, 5.0)
	poly.color = Color(0.35, 0.22, 0.12)
	await get_tree().create_timer(growth_step_delay_sec).timeout
	if not is_instance_valid(poly):
		return

	# Step 2: early sprout.
	poly.polygon = _rect_polygon(7.0, 22.0)
	poly.color = Color(0.32, 0.62, 0.28)
	await get_tree().create_timer(growth_step_delay_sec).timeout
	if not is_instance_valid(poly):
		return

	# Step 3: growing stem.
	var h3 := final_growth_height_px * 0.45
	var w3 := lerpf(10.0, final_growth_width_px, 0.55)
	poly.polygon = _rect_polygon(w3, h3)
	poly.color = Color(0.28, 0.72, 0.34)
	await get_tree().create_timer(growth_step_delay_sec).timeout
	if not is_instance_valid(poly):
		return

	# Step 4: full placeholder — 128px tall pink rectangle.
	poly.polygon = _rect_polygon(final_growth_width_px, final_growth_height_px)
	poly.color = Color(1.0, 0.45, 0.78)

	if is_instance_valid(anchor):
		var prompt := Node2D.new()
		prompt.name = &"TreeNamePrompt"
		prompt.set_script(preload("res://pickups/planted_tree_prompt.gd"))
		prompt.title_text = _mature_tree_title()
		prompt.rect_width_px = final_growth_width_px
		prompt.rect_height_px = final_growth_height_px
		anchor.add_child(prompt)

	if (
		_is_willow_soil()
		and planted_kind == SeedDefs.Type.WILLOW_1
		and not _willow_seed_2_released
	):
		if not is_instance_valid(anchor):
			return
		_willow_seed_2_released = true
		var top_global: Vector2 = anchor.to_global(Vector2(0, -final_growth_height_px))
		# Beside the rectangle base (anchor origin = bottom center of pink stem).
		var land_local := Vector2(final_growth_width_px * 0.5 + 14.0, 16.0)
		var land_global: Vector2 = anchor.to_global(land_local)
		var lv: Node = get_tree().get_first_node_in_group(&"game_level")
		if lv and lv.has_method(&"drop_willow_seed_2_from"):
			lv.drop_willow_seed_2_from(top_global, land_global)
