extends CanvasLayer

const _SHOW_SECONDS := 5.0
const _STRIP_HEIGHT := 52.0

var _root: Control
var _strip: ColorRect
var _label: Label
var _hide_timer: SceneTreeTimer


func _ready() -> void:
	layer = 110
	process_mode = Node.PROCESS_MODE_ALWAYS

	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_strip = ColorRect.new()
	_strip.color = Color(0, 0, 0, 0.92)
	_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_strip)

	_label = Label.new()
	_label.text = ""
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override(&"font_size", 15)
	_label.add_theme_color_override(&"font_color", Color(1, 1, 1))
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_label.add_theme_constant_override(&"line_spacing", 2)
	_strip.add_child(_label)

	_strip.visible = false

	get_viewport().size_changed.connect(_apply_strip_layout)
	_apply_strip_layout()


func _apply_strip_layout() -> void:
	if _strip == null:
		return
	var vw := get_viewport().get_visible_rect().size.x
	var w: float = vw / 3.0
	_strip.anchor_left = 0.5
	_strip.anchor_right = 0.5
	_strip.anchor_top = 1.0
	_strip.anchor_bottom = 1.0
	_strip.offset_left = -w * 0.5
	_strip.offset_right = w * 0.5
	_strip.offset_top = -_STRIP_HEIGHT
	_strip.offset_bottom = 0.0


func show_pickup(item_phrase: String) -> void:
	if _strip == null:
		return
	if _hide_timer != null and _hide_timer.timeout.is_connected(_on_hide_timer):
		_hide_timer.timeout.disconnect(_on_hide_timer)
		_hide_timer = null
	_apply_strip_layout()
	_label.text = "You picked up a %s" % item_phrase
	_strip.visible = true
	_hide_timer = get_tree().create_timer(_SHOW_SECONDS, false, true)
	_hide_timer.timeout.connect(_on_hide_timer)


func _on_hide_timer() -> void:
	_hide_timer = null
	if _strip:
		_strip.visible = false
