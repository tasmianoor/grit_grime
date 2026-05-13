extends Sprite2D
## While **Lawrence** stands on **BuildingPink** / **BuildingYellow** / **BuildingGreen** roof (layer **16** strip) and holds **`drop_seed*`**, stamp holes in a CPU mask so **BStreet** alpha clears and **WBStreet** shows through.
## Requires Lawrence's post-bag outfit (`Lawrence/bag_*`); otherwise shows a blocked hint (same typography as soil patch hint in Level 1).

const _BUILDING_LAYER := 16
const _ROOF_BUILDINGS: Array[StringName] = [&"BuildingPink", &"BuildingYellow", &"BuildingGreen"]

const _GAME_THEME: Theme = preload("res://gui/theme.tres")
const _BLOCKED_HINT_TEXT := "Special tools needed to weatherize building"
const _LABEL_OUTLINE_PX := 3

@export var feet_offset_y := 34.0
@export var stamp_radius_px := 88
@export var stamp_interval_sec := 0.06
@export var min_uv_move_to_stamp := 0.012
@export var blocked_hint_world_offset := Vector2(0, -50)

var _mask_img: Image
var _mask_tex: ImageTexture
var _mat: ShaderMaterial
var _stamp_accum := 0.0
var _last_stamp_uv := Vector2(-10, -10)
## At least one valid roof stamp while feet were on this facade (Pink / Yellow / Green).
var _roof_stamp_done: Dictionary = {}
var _hint_layer: CanvasLayer
var _hint_label: Label


func are_all_roofs_complete() -> bool:
	for k in _ROOF_BUILDINGS:
		if not bool(_roof_stamp_done.get(k, false)):
			return false
	return true


func _ready() -> void:
	if texture == null:
		return
	var sz := Vector2i(texture.get_width(), texture.get_height())
	_mask_img = Image.create(sz.x, sz.y, false, Image.FORMAT_RGBA8)
	_mask_img.fill(Color(1, 1, 1, 1))
	_mask_tex = ImageTexture.create_from_image(_mask_img)
	var sh := load("res://level 2/bstreet_roof_mask.gdshader") as Shader
	if sh == null:
		push_error("bstreet_roof_reveal: missing bstreet_roof_mask.gdshader")
		return
	_mat = ShaderMaterial.new()
	_mat.shader = sh
	_mat.set_shader_parameter(&"mask", _mask_tex)
	material = _mat
	if not Engine.is_editor_hint():
		_setup_blocked_hint()


func _setup_blocked_hint() -> void:
	_hint_layer = CanvasLayer.new()
	_hint_layer.layer = 58
	add_child(_hint_layer)
	_hint_label = Label.new()
	_hint_label.name = &"RoofBlockedToolsHint"
	_hint_label.text = _BLOCKED_HINT_TEXT
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.custom_minimum_size = Vector2(300, 0)
	_hint_label.add_theme_font_override(&"font", _GAME_THEME.default_font)
	_hint_label.add_theme_font_size_override(&"font_size", 13)
	_hint_label.add_theme_color_override(&"font_color", Color(1, 1, 1, 1))
	_hint_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
	_hint_label.add_theme_constant_override(&"outline_size", _LABEL_OUTLINE_PX)
	_hint_label.visible = false
	_hint_layer.add_child(_hint_label)


func _set_blocked_hint_visible(on: bool, world_anchor: Vector2 = Vector2.ZERO) -> void:
	if _hint_label == null:
		return
	_hint_label.visible = on
	if not on:
		return
	var viewport := get_viewport()
	if viewport == null:
		return
	var screen_pos: Vector2 = viewport.get_canvas_transform() * world_anchor
	_hint_label.reset_size()
	_hint_label.position = screen_pos - _hint_label.size * 0.5


## Returns `{"building": StringName, "feet": Vector2}` when feet overlap a stamped roof collider, else `{}`.
func _roof_overlap_state(p: CharacterBody2D) -> Dictionary:
	var base := p.global_position + Vector2(0, feet_offset_y)
	var space := get_world_2d().direct_space_state
	var q := PhysicsPointQueryParameters2D.new()
	q.collision_mask = _BUILDING_LAYER
	q.collide_with_areas = false
	q.collide_with_bodies = true
	for dy in [-18.0, 0.0, 10.0, 22.0]:
		q.position = base + Vector2(0, dy)
		var hits := space.intersect_point(q, 12)
		for hit in hits:
			var c: Variant = hit.get(&"collider")
			if c == null or not (c is StaticBody2D):
				continue
			var nm := (c as Node).name
			if nm == &"BuildingPink" or nm == &"BuildingYellow" or nm == &"BuildingGreen":
				return {&"building": nm, &"feet": base}
	return {}


func _feet_on_target_roof_building(p: CharacterBody2D) -> StringName:
	var st := _roof_overlap_state(p)
	if st.is_empty():
		return &""
	return st[&"building"] as StringName


func _physics_process(delta: float) -> void:
	if _mat == null or texture == null or _mask_img == null:
		return
	var tree := get_tree()
	if tree == null:
		return
	var stamped := false
	var blocked_feet: Variant = null

	for n in tree.get_nodes_in_group(&"player"):
		if not n is CharacterBody2D:
			continue
		var p := n as CharacterBody2D
		if p.has_method(&"is_holding_trash") and bool(p.call(&"is_holding_trash")):
			continue
		var st := _roof_overlap_state(p)
		if st.is_empty():
			continue
		var sfx := str(p.get(&"action_suffix"))
		if not Input.is_action_pressed(&"drop_seed" + sfx):
			continue
		var has_bag := p.has_method(&"has_lawrence_bag_outfit_active") and bool(
			p.call(&"has_lawrence_bag_outfit_active")
		)
		if not has_bag:
			blocked_feet = st[&"feet"]
			continue
		var uv := _world_to_uv(p.global_position + Vector2(0, feet_offset_y))
		if not _uv_valid(uv):
			continue
		_stamp_accum += delta
		if _stamp_accum < stamp_interval_sec and _last_stamp_uv.distance_to(uv) < min_uv_move_to_stamp:
			continue
		_stamp_accum = 0.0
		_stamp_circle_uv(uv)
		_roof_stamp_done[st[&"building"]] = true
		_last_stamp_uv = uv
		stamped = true

	if blocked_feet != null and not stamped:
		_set_blocked_hint_visible(true, blocked_feet as Vector2 + blocked_hint_world_offset)
	else:
		_set_blocked_hint_visible(false)

	if not stamped:
		_stamp_accum = stamp_interval_sec


func _world_to_uv(world: Vector2) -> Vector2:
	var inv := global_transform.affine_inverse()
	var lp: Vector2 = inv * world
	var r := get_rect()
	return (lp - r.position) / r.size


func _uv_valid(uv: Vector2) -> bool:
	return uv.x >= 0.0 and uv.x <= 1.0 and uv.y >= 0.0 and uv.y <= 1.0


func _stamp_circle_uv(uv: Vector2) -> void:
	var w := _mask_img.get_width()
	var h := _mask_img.get_height()
	var cx := clampi(int(uv.x * float(w)), 0, w - 1)
	var cy := clampi(int(uv.y * float(h)), 0, h - 1)
	var r := stamp_radius_px
	var rr := r * r
	var x0 := maxi(0, cx - r)
	var y0 := maxi(0, cy - r)
	var x1 := mini(w - 1, cx + r)
	var y1 := mini(h - 1, cy + r)
	for y in range(y0, y1 + 1):
		var dy := y - cy
		for x in range(x0, x1 + 1):
			var dx := x - cx
			if dx * dx + dy * dy > rr:
				continue
			_mask_img.set_pixel(x, y, Color(0, 0, 0, 1))
	_mask_tex.set_image(_mask_img)
