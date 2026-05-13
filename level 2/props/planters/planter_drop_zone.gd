extends Area2D
## Convex **polygon** drop spot for **planter1.png** carried as trash. Shows **“Missing plant”** when a player is nearby until a planter is placed here. After deposit, growth **planter1→4** tracks **`game_level`** time direction like cypress trees.

const _POST_DROP_GROWTH_SCRIPT: GDScript = preload(
	"res://level 2/props/planters/planter_post_drop_growth.gd"
)
const _PLANTER1_TEX: Texture2D = preload("res://level 2/props/planters/planter1.png")
const _GAME_THEME: Theme = preload("res://gui/theme.tres")
const _HINT_TEXT := "Missing plant"
const _LABEL_OUTLINE_PX := 3
## Planted **planter1** at the zone is this much larger than the carry-size target (**`planted_sprite_height_px`**).
const _PLANTED_VISUAL_SCALE_MULT := 1.25

@export var planted_sprite_height_px := 56.0

@onready var _polygon: Polygon2D = $PolygonFill

var _filled := false
var _inside: Array[Node2D] = []
var _hint_layer: CanvasLayer
var _hint_label: Label


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	add_to_group(&"planter_drop_zone")
	collision_layer = 4
	collision_mask = 1
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_setup_hint()


func _setup_hint() -> void:
	_hint_layer = CanvasLayer.new()
	_hint_layer.layer = 58
	add_child(_hint_layer)
	_hint_label = Label.new()
	_hint_label.name = &"PlanterDropHintLabel"
	_hint_label.text = _HINT_TEXT
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hint_label.add_theme_font_override(&"font", _GAME_THEME.default_font)
	_hint_label.add_theme_font_size_override(&"font_size", 13)
	_hint_label.add_theme_color_override(&"font_color", Color(1, 1, 1, 1))
	_hint_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
	_hint_label.add_theme_constant_override(&"outline_size", _LABEL_OUTLINE_PX)
	_hint_label.visible = false
	_hint_layer.add_child(_hint_label)


func _hint_world_position() -> Vector2:
	return global_position + Vector2(0, -52)


func _free_hint() -> void:
	if is_instance_valid(_hint_layer):
		_hint_layer.queue_free()
	_hint_layer = null
	_hint_label = null


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group(&"player") and body not in _inside:
		_inside.append(body as Node2D)


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group(&"player"):
		_inside.erase(body as Node2D)


func _carried_tex_is_planter1(p: Node) -> bool:
	if not p.has_method(&"get_carried_trash_texture"):
		return false
	var t: Variant = p.call(&"get_carried_trash_texture")
	if not (t is Texture2D):
		return false
	return (t as Texture2D).resource_path == _PLANTER1_TEX.resource_path


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or _filled:
		return
	var dead: Array[Node2D] = []
	for p in _inside:
		if not is_instance_valid(p):
			dead.append(p)
	for p in dead:
		_inside.erase(p)

	if is_instance_valid(_hint_label):
		var tree := get_tree()
		var show := false
		if tree != null:
			show = PickupNearPlayer.any_player_within_glow_distance(tree, global_position)
		_hint_label.visible = show
		if show:
			var viewport := get_viewport()
			if viewport != null:
				var world_pos := _hint_world_position()
				var screen_pos: Vector2 = viewport.get_canvas_transform() * world_pos
				_hint_label.reset_size()
				_hint_label.position = screen_pos - _hint_label.size * 0.5

	for p in _inside:
		if not p.has_method(&"is_holding_trash") or not bool(p.call(&"is_holding_trash")):
			continue
		if not _carried_tex_is_planter1(p):
			continue
		var sfx := str(p.get(&"action_suffix"))
		if not Input.is_action_just_pressed(&"drop_seed" + sfx):
			continue
		if not p.has_method(&"deposit_trash"):
			continue
		if not bool(p.call(&"deposit_trash")):
			continue
		_complete_zone()
		return


func _complete_zone() -> void:
	_filled = true
	set_physics_process(false)
	monitoring = false
	collision_layer = 0
	collision_mask = 0
	_free_hint()
	if is_instance_valid(_polygon):
		_polygon.visible = false
	var grower := Node2D.new()
	grower.name = &"PlantedPlanterGrowth"
	grower.set_script(_POST_DROP_GROWTH_SCRIPT)
	grower.planted_sprite_height_px = planted_sprite_height_px
	grower.planted_visual_scale_mult = _PLANTED_VISUAL_SCALE_MULT
	grower.global_position = global_position
	# Player uses **`z_index = 5`** on the level; draw growth behind Lawrence (match grass / props under player).
	grower.z_as_relative = false
	grower.z_index = 4
	get_parent().add_child(grower)
