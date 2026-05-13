extends Button
## Idle: dark blue label. Hot (mouse over or keyboard focus): slightly brighter navy (no glow, no white fill).

const _FONT_IDLE := Color(0.02, 0.16, 0.42, 1.0)
const _FONT_HOT := Color(0.0, 0.11, 0.32, 1.0)
const _OUTLINE_IDLE_SIZE := 0
const _OUTLINE_HOT_SIZE := 0

var _mouse_over := false


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	_refresh_visual()


func _on_mouse_entered() -> void:
	_mouse_over = true
	_refresh_visual()


func _on_mouse_exited() -> void:
	_mouse_over = false
	_refresh_visual()


func _on_focus_entered() -> void:
	_refresh_visual()


func _on_focus_exited() -> void:
	_refresh_visual()


func _refresh_visual() -> void:
	var hot := _mouse_over or has_focus()
	if hot:
		add_theme_color_override(&"font_color", _FONT_HOT)
		remove_theme_color_override(&"font_outline_color")
		add_theme_constant_override(&"outline_size", _OUTLINE_HOT_SIZE)
		remove_theme_color_override(&"font_shadow_color")
		remove_theme_constant_override(&"shadow_offset_x")
		remove_theme_constant_override(&"shadow_offset_y")
	else:
		add_theme_color_override(&"font_color", _FONT_IDLE)
		remove_theme_color_override(&"font_outline_color")
		add_theme_constant_override(&"outline_size", _OUTLINE_IDLE_SIZE)
		remove_theme_color_override(&"font_shadow_color")
		remove_theme_constant_override(&"shadow_offset_x")
		remove_theme_constant_override(&"shadow_offset_y")


## Call after changing **`text`** / **`icon`** from another script so label colors match focus/hover.
func refresh_after_content_change() -> void:
	_refresh_visual()
