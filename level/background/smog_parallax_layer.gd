extends Node2D
## Foreground smog stack: fades as each soil tree reaches **fully locked** maturity. Progress only increases and reaches 1 when the last patch matures.

const GROUP := &"smog_parallax_fade"

## If > 0, used as how many adult-tree milestones divide the fade (default: count `soil_drop_zone` nodes under `GameLevel`).
@export var maturity_slots_override: int = 0

var _total_slots := 1
var _mature_count := 0
## 0 = full smog, 1 = fully faded.
var _progress := 0.0
var _base_modulate := Color.WHITE
var _slots_resolved := false


func _ready() -> void:
	_base_modulate = modulate
	add_to_group(GROUP)
	if not Engine.is_editor_hint():
		call_deferred(&"_resolve_maturity_slots")
	_apply_modulate()


func _resolve_maturity_slots() -> void:
	if _slots_resolved:
		return
	if maturity_slots_override > 0:
		_total_slots = maxi(1, maturity_slots_override)
	else:
		var lv := get_tree().get_first_node_in_group(&"game_level")
		if lv != null and lv.has_method(&"get_soil_drop_zone_count"):
			_total_slots = maxi(1, int(lv.get_soil_drop_zone_count()))
		else:
			_total_slots = 1
	_slots_resolved = true
	_recompute_progress()
	_apply_modulate()


func register_tree_matured() -> void:
	if Engine.is_editor_hint() or not visible:
		return
	if not _slots_resolved:
		_resolve_maturity_slots()
	_mature_count = mini(_mature_count + 1, _total_slots)
	_recompute_progress()
	_apply_modulate()


func _recompute_progress() -> void:
	_progress = clampf(float(_mature_count) / float(_total_slots), 0.0, 1.0)


func get_fade_progress() -> float:
	return _progress


func _apply_modulate() -> void:
	var vis := 1.0 - _progress
	modulate = Color(_base_modulate.r, _base_modulate.g, _base_modulate.b, _base_modulate.a * vis)
