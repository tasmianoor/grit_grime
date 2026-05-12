extends Sprite2D
## While **Lawrence** stands on **BuildingPink** / **BuildingYellow** / **BuildingGreen** roof (layer **16** strip) and holds **`drop_seed*`**, stamp holes in a CPU mask so **BStreet** alpha clears and **WBStreet** shows through.

const _BUILDING_LAYER := 16
const _ROOF_BUILDINGS: Array[StringName] = [&"BuildingPink", &"BuildingYellow", &"BuildingGreen"]

@export var feet_offset_y := 34.0
@export var stamp_radius_px := 88
@export var stamp_interval_sec := 0.06
@export var min_uv_move_to_stamp := 0.012

var _mask_img: Image
var _mask_tex: ImageTexture
var _mat: ShaderMaterial
var _stamp_accum := 0.0
var _last_stamp_uv := Vector2(-10, -10)
## At least one valid roof stamp while feet were on this facade (Pink / Yellow / Green).
var _roof_stamp_done: Dictionary = {}


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


func _physics_process(delta: float) -> void:
	if _mat == null or texture == null or _mask_img == null:
		return
	var tree := get_tree()
	if tree == null:
		return
	var stamped := false
	for n in tree.get_nodes_in_group(&"player"):
		if not n is CharacterBody2D:
			continue
		var p := n as CharacterBody2D
		if p.has_method(&"is_holding_trash") and bool(p.call(&"is_holding_trash")):
			continue
		var roof_b := _feet_on_target_roof_building(p)
		if roof_b == &"":
			continue
		var sfx := str(p.get(&"action_suffix"))
		if not Input.is_action_pressed(&"drop_seed" + sfx):
			continue
		var uv := _world_to_uv(p.global_position + Vector2(0, feet_offset_y))
		if not _uv_valid(uv):
			continue
		_stamp_accum += delta
		if _stamp_accum < stamp_interval_sec and _last_stamp_uv.distance_to(uv) < min_uv_move_to_stamp:
			continue
		_stamp_accum = 0.0
		_stamp_circle_uv(uv)
		_roof_stamp_done[roof_b] = true
		_last_stamp_uv = uv
		stamped = true
	if not stamped:
		_stamp_accum = stamp_interval_sec


func _feet_on_target_roof_building(p: CharacterBody2D) -> StringName:
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
				return nm
	return &""


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
