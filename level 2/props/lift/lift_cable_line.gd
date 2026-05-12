extends Node2D
## Connects the moving lift top to the static cab (fill + 1px outline).

const FILL_WIDTH := 12.0
const OUTLINE_WIDTH := FILL_WIDTH + 2.0

const _FILL := Color(0.898039, 0.580392, 0.141176, 1.0)
const _OUTLINE := Color(0.160784, 0.105882, 0.039216, 1.0)

@onready var _body: Sprite2D = $"../PlatformLiftBody"
@onready var _top: Sprite2D = $"../Platform/Sprite2D"
@onready var _outline: Line2D = $Outline
@onready var _fill: Line2D = $Fill


func _ready() -> void:
	_configure(_outline, _OUTLINE, OUTLINE_WIDTH)
	_configure(_fill, _FILL, FILL_WIDTH)


func _configure(line: Line2D, col: Color, w: float) -> void:
	line.default_color = col
	line.width = w
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND


func _process(_delta: float) -> void:
	if _body == null or _top == null or _body.texture == null or _top.texture == null:
		return
	var deck_bottom := _top.global_position + Vector2(0.0, _tex_half_h(_top))
	var cab_top := _body.global_position - Vector2(0.0, _tex_half_h(_body))
	_set_segment(_outline, deck_bottom, cab_top)
	_set_segment(_fill, deck_bottom, cab_top)


func _set_segment(line: Line2D, p0: Vector2, p1: Vector2) -> void:
	line.clear_points()
	line.add_point(line.to_local(p0))
	line.add_point(line.to_local(p1))


func _tex_half_h(sprite: Sprite2D) -> float:
	return sprite.texture.get_height() * absf(sprite.scale.y) * 0.5
