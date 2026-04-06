extends Node2D

const _GAME_THEME: Theme = preload("res://gui/theme.tres")
const _LABEL_OUTLINE_PX := 3

## Shown when the player overlaps the mature (pink) placeholder.
@export var title_text: String = ""
@export var rect_width_px: float = 24.0
@export var rect_height_px: float = 128.0

var _players_inside: Array[Player] = []
var _layer: CanvasLayer
var _label: Label


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1
	area.monitorable = false
	add_child(area)
	var hit := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(rect_width_px, rect_height_px)
	hit.shape = rect
	hit.position = Vector2(0, -rect_height_px * 0.5)
	area.add_child(hit)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	_layer = CanvasLayer.new()
	_layer.layer = 60
	add_child(_layer)
	_label = Label.new()
	_label.text = title_text
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_override(&"font", _GAME_THEME.default_font)
	_label.add_theme_font_size_override(&"font_size", 13)
	_label.add_theme_color_override(&"font_color", Color(1, 1, 1, 1))
	_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 1))
	_label.add_theme_constant_override(&"outline_size", _LABEL_OUTLINE_PX)
	_label.visible = false
	_layer.add_child(_label)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or _label == null:
		return
	var dead: Array[Player] = []
	for p in _players_inside:
		if not is_instance_valid(p):
			dead.append(p)
	for p in dead:
		_players_inside.erase(p)

	var show := not _players_inside.is_empty()
	_label.visible = show
	if not show:
		return
	var viewport := get_viewport()
	if viewport == null:
		return
	var world_pos := to_global(Vector2(0, -rect_height_px - 14))
	var xf := viewport.get_canvas_transform()
	var screen_pos: Vector2 = xf * world_pos
	_label.reset_size()
	_label.position = screen_pos - _label.size * 0.5


func _on_body_entered(body: Node2D) -> void:
	if body is Player and body not in _players_inside:
		_players_inside.append(body as Player)


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		_players_inside.erase(body as Player)
