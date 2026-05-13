extends Control

const LEVEL_1_ENTRY_SCENE := "res://game_singleplayer.tscn"
const LEVEL_2_ENTRY_SCENE := "res://game_level_2.tscn"
const MEMPHIS_AQUIFER_PLACEHOLDER_SCENE := "res://map/memphis_aquifer_placeholder.tscn"

## Normalized coords on `InteractiveMap.png` (0–1 from top-left). Tuned to pyramid / guitar / aquifer art.
const RIVERFRONT_MAP_UV := Vector2(0.068, 0.386)
const BEALE_MAP_UV := Vector2(0.458, 0.402)
const AQUIFER_MAP_UV := Vector2(0.49, 0.898)

@export var auto_position_buttons := true
const MAP_BUTTON_OUTLINE_SIZE_DEFAULT := 1
const MAP_BUTTON_OUTLINE_SIZE_HOVER := 2

@onready var _map_background := $MapBackground as TextureRect
@onready var _level_1_button := $LevelButton as Button
@onready var _level_2_button := $Level2Button as Button
@onready var _memphis_aquifer_button := $MemphisAquiferButton as Button


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and auto_position_buttons:
		_layout_map_buttons()


func _ready() -> void:
	_apply_map_button_letter_spacing()
	_wire_map_button_hover_outline()

	if _level_1_button != null and not _level_1_button.pressed.is_connected(_on_level_pressed):
		_level_1_button.pressed.connect(_on_level_pressed)
	if _level_2_button != null and not _level_2_button.pressed.is_connected(_on_level_2_pressed):
		_level_2_button.pressed.connect(_on_level_2_pressed)
	if _memphis_aquifer_button != null and not _memphis_aquifer_button.pressed.is_connected(
		_on_memphis_aquifer_pressed
	):
		_memphis_aquifer_button.pressed.connect(_on_memphis_aquifer_pressed)

	await get_tree().process_frame
	if auto_position_buttons:
		_layout_map_buttons()


func _layout_map_buttons() -> void:
	if _map_background == null:
		return
	_place_button_at_texture_uv(_level_1_button, RIVERFRONT_MAP_UV)
	_place_button_at_texture_uv(_level_2_button, BEALE_MAP_UV)
	_place_button_at_texture_uv(_memphis_aquifer_button, AQUIFER_MAP_UV)


static func _texture_uv_to_control_local(tex_rect: TextureRect, uv: Vector2) -> Vector2:
	var tex := tex_rect.texture as Texture2D
	if tex == null:
		return Vector2.ZERO
	var ts := tex.get_size()
	var cs := tex_rect.size
	if ts.x <= 0.0 or ts.y <= 0.0 or cs.x <= 0.0 or cs.y <= 0.0:
		return Vector2.ZERO
	# Matches TextureRect stretch KEEP_ASPECT_COVERED (texture fills control, may crop).
	var zoom := maxf(cs.x / ts.x, cs.y / ts.y)
	var drawn := ts * zoom
	var origin := (cs - drawn) * 0.5
	return origin + Vector2(uv.x * ts.x, uv.y * ts.y) * zoom


func _place_button_at_texture_uv(button: Button, uv: Vector2) -> void:
	if button == null or _map_background == null:
		return
	button.reset_size()
	var sz := button.get_combined_minimum_size()
	var center_bg := _texture_uv_to_control_local(_map_background, uv)
	var bg_origin := _map_background.position
	button.position = bg_origin + center_bg - sz * 0.5
	button.size = sz


func _apply_map_button_letter_spacing() -> void:
	var map_buttons: Array[Button] = [_level_1_button, _level_2_button, _memphis_aquifer_button]
	for button in map_buttons:
		if button == null:
			continue
		var base_font: Font = button.get_theme_font(&"font")
		if base_font == null:
			continue
		var font_size: int = button.get_theme_font_size(&"font_size")
		var spacing_px: int = max(1, int(round(float(font_size) * 0.05)))
		var font_with_spacing := FontVariation.new()
		font_with_spacing.base_font = base_font
		font_with_spacing.spacing_glyph = spacing_px
		button.add_theme_font_override(&"font", font_with_spacing)


func _wire_map_button_hover_outline() -> void:
	var map_buttons: Array[Button] = [_level_1_button, _level_2_button, _memphis_aquifer_button]
	for button in map_buttons:
		if button == null:
			continue
		button.add_theme_constant_override(&"outline_size", MAP_BUTTON_OUTLINE_SIZE_DEFAULT)
		if not button.mouse_entered.is_connected(_on_map_button_mouse_entered):
			button.mouse_entered.connect(_on_map_button_mouse_entered.bind(button))
		if not button.mouse_exited.is_connected(_on_map_button_mouse_exited):
			button.mouse_exited.connect(_on_map_button_mouse_exited.bind(button))


func _on_map_button_mouse_entered(button: Button) -> void:
	if button == null:
		return
	button.add_theme_constant_override(&"outline_size", MAP_BUTTON_OUTLINE_SIZE_HOVER)


func _on_map_button_mouse_exited(button: Button) -> void:
	if button == null:
		return
	button.add_theme_constant_override(&"outline_size", MAP_BUTTON_OUTLINE_SIZE_DEFAULT)


func _on_level_pressed() -> void:
	_open_scene(LEVEL_1_ENTRY_SCENE)


func _on_level_2_pressed() -> void:
	_open_scene(LEVEL_2_ENTRY_SCENE)


func _on_memphis_aquifer_pressed() -> void:
	_open_scene(MEMPHIS_AQUIFER_PLACEHOLDER_SCENE)


func _open_scene(scene_path: String) -> void:
	var err: Error = get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_error("Failed to open map target scene: %s (error %d)" % [scene_path, err])
