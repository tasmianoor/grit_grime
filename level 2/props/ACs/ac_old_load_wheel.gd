extends Control
class_name AcOldLoadWheel
## Circular hold-progress ring (0..1) drawn above an old AC unit.

var _ratio := 0.0


func set_progress_ratio(r: float) -> void:
	_ratio = clampf(r, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	var rad := minf(size.x, size.y) * 0.38
	draw_arc(c, rad, 0.0, TAU, 48, Color(0.12, 0.12, 0.14, 0.94), 6.0, true)
	if _ratio <= 0.001:
		return
	var from := -PI * 0.5
	var to := from + TAU * _ratio
	var segs := maxi(8, mini(64, int(48.0 * _ratio) + 4))
	draw_arc(c, rad, from, to, segs, Color(0.42, 0.88, 1.0, 1.0), 6.0, true)
