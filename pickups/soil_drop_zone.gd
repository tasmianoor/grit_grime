extends Area2D

@export var accepts: SeedDefs.Type = SeedDefs.Type.WILLOW_1

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
	_label.add_theme_font_size_override(&"font_size", 13)
	_label.add_theme_color_override(&"font_shadow_color", Color(0, 0, 0, 0.9))
	_label.add_theme_constant_override(&"shadow_offset_x", 1)
	_label.add_theme_constant_override(&"shadow_offset_y", 1)
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
	if not player.consume_held_for_soil(accepts):
		return
	var soil := get_parent() as Sprite2D
	if soil:
		soil.modulate = Color(0.82, 1.0, 0.82)
	_planted = true
	if _label:
		_label.visible = false
	set_deferred(&"monitoring", false)
