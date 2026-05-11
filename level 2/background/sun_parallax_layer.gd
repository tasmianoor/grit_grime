extends ParallaxLayer

## Drawn **after** `Sky` and **before** `Clouds` in `parallax_background.tscn` so the sun sits behind cloud sprites.
const _SUN_TEX := preload("res://level/props/Sun.png")
## Horizontal gap from the player’s screen column to the sun’s **left** edge (canvas px).
const _RIGHT_OF_PLAYER_AXIS_PX := 40.0
## Vertical center of the sun in canvas space (middle of top third = 1/6 of viewport height).
const _TOP_THIRD_CENTER_FRAC := 1.0 / 6.0

@export_range(8.0, 1024.0, 1.0, "suffix:px") var sun_max_dimension_px := 80.0

var _sun: Sprite2D


func _ready() -> void:
	motion_scale = Vector2.ZERO
	_sun = Sprite2D.new()
	_sun.name = &"Sun"
	_sun.texture = _SUN_TEX
	_sun.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sun.centered = true
	add_child(_sun)
	_apply_pixel_scale()
	# After camera / player exist so first paint is already correct (not only from `_process`).
	call_deferred(&"_update_sun_from_player")


func _apply_pixel_scale() -> void:
	if _sun == null:
		return
	var im := _SUN_TEX.get_size()
	var s := sun_max_dimension_px / maxf(maxf(im.x, im.y), 1.0)
	_sun.scale = Vector2(s, s)


func _process(_delta: float) -> void:
	_update_sun_from_player()


func _update_sun_from_player() -> void:
	if _sun == null:
		return
	var player := _player_for_active_camera()
	if player == null:
		_sun.visible = false
		return
	var vp := get_viewport()
	var cam := vp.get_camera_2d()
	if cam == null:
		_sun.visible = false
		return
	_sun.visible = true
	var xf := vp.get_canvas_transform()
	var player_col: Vector2 = xf * player.global_position
	var vis := vp.get_visible_rect()
	# Midline of the **top third** of the visible viewport (band: vis.position.y … + size.y/3).
	var y_target := vis.position.y + vis.size.y * _TOP_THIRD_CENTER_FRAC
	var im := _SUN_TEX.get_size()
	var sc := sun_max_dimension_px / maxf(maxf(im.x, im.y), 1.0)
	var w := im.x * sc
	var inv := xf.affine_inverse()
	var center_canvas := Vector2(
		player_col.x + _RIGHT_OF_PLAYER_AXIS_PX + w * 0.5,
		y_target,
	)
	# ParallaxLayer applies an extra scroll transform; canvas XF alone is not enough for final screen Y.
	for _i in 6:
		_sun.global_position = inv * center_canvas
		var canvas_y := _sun.get_global_transform_with_canvas().origin.y
		var err := y_target - canvas_y
		if absf(err) < 0.75:
			break
		center_canvas.y += err


func _player_for_active_camera() -> Node2D:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return null
	for n in get_tree().get_nodes_in_group(&"player"):
		if not n is Node2D:
			continue
		var pl := n as Node2D
		var pl_cam := pl.get_node_or_null(^"Camera") as Camera2D
		if pl_cam != null and pl_cam == cam:
			return pl
	return null
