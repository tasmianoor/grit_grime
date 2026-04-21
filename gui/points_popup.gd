extends CanvasLayer
class_name PointsPopup

## Same typography as transient soil / score messages (theme font, 13px, outline).
const _GAME_THEME: Theme = preload("res://gui/theme.tres")
const _FONT_SIZE := 13
const _OUTLINE_PX := 3
const _CANVAS_LAYER := 62
const _LIFETIME_SEC := 2.4
const _RISE_PX_PER_SEC := 24.0

var _vp: Viewport
var _world_pos: Vector2
var _points_mode := true
var _amount: int
var _message: String
var _label: Label
var _elapsed := 0.0


static func spawn(player: Player, world_position: Vector2, amount: int) -> void:
	if not is_instance_valid(player):
		return
	var vp: Viewport = player.camera.custom_viewport as Viewport
	if vp == null:
		vp = player.get_viewport()
	if vp == null:
		return
	var inst := PointsPopup.new()
	inst._vp = vp
	inst._world_pos = world_position
	inst._points_mode = true
	inst._amount = amount
	vp.add_child(inst)


static func spawn_message(player: Player, world_position: Vector2, message: String) -> void:
	if not is_instance_valid(player):
		return
	var vp: Viewport = player.camera.custom_viewport as Viewport
	if vp == null:
		vp = player.get_viewport()
	if vp == null:
		return
	var inst := PointsPopup.new()
	inst._vp = vp
	inst._world_pos = world_position
	inst._points_mode = false
	inst._message = message
	vp.add_child(inst)


func _ready() -> void:
	layer = _CANVAS_LAYER
	process_mode = Node.PROCESS_MODE_ALWAYS

	_label = Label.new()
	if _points_mode:
		_label.text = "+%d points" % _amount
	else:
		_label.text = _message
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_override(&"font", _GAME_THEME.default_font)
	_label.add_theme_font_size_override(&"font_size", _FONT_SIZE)
	_label.add_theme_color_override(&"font_color", Color(1, 1, 1, 1))
	_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
	_label.add_theme_constant_override(&"outline_size", _OUTLINE_PX)
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_label)
	_label.reset_size()
	_apply_position(0.0)
	set_process(true)


func _process(delta: float) -> void:
	_elapsed += delta
	_apply_position(_elapsed * _RISE_PX_PER_SEC)
	var fade_start := _LIFETIME_SEC * 0.65
	if _elapsed > fade_start:
		var u := (_elapsed - fade_start) / (_LIFETIME_SEC - fade_start)
		_label.modulate.a = 1.0 - clampf(u, 0.0, 1.0)
	if _elapsed >= _LIFETIME_SEC:
		set_process(false)
		queue_free()


func _apply_position(rise_px: float) -> void:
	if not is_instance_valid(_label) or not is_instance_valid(_vp):
		return
	var xf := _vp.get_canvas_transform()
	var screen: Vector2 = xf * _world_pos
	_label.position = Vector2(
		screen.x - _label.size.x * 0.5,
		screen.y - _label.size.y * 0.5 - rise_px
	)
