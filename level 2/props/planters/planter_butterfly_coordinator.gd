extends Node
## When every **`planter_drop_zone`** has a fully mature **`PlantedPlanterGrowth`**, spawns four butterflies, then **Christie** after **2 s** (**`level2_christie_npc.gd`**). **Christie** is not in **`level_2.tscn`**, so she never appears in the **2D editor** for that scene alone — run **`game_level_2.tscn`** (or full flow) after both planters mature.

const _BUTTERFLY_SCRIPT: GDScript = preload("res://level 2/props/butterfly/level2_butterfly.gd")
const _CHRISTIE_SCRIPT: GDScript = preload("res://level 2/props/Christie/level2_christie_npc.gd")

var _expected_planters := 0
var _mature_planters := 0
var _butterflies_released := false


func _ready() -> void:
	add_to_group(&"planter_butterfly_coordinator")
	if Engine.is_editor_hint():
		return
	call_deferred(&"_count_drop_zones")


func _count_drop_zones() -> void:
	var tree := get_tree()
	if tree == null:
		return
	_expected_planters = tree.get_nodes_in_group(&"planter_drop_zone").size()


func register_planter_fully_mature() -> void:
	if Engine.is_editor_hint() or _butterflies_released:
		return
	if _expected_planters <= 0:
		_count_drop_zones()
	if _expected_planters <= 0:
		return
	_mature_planters += 1
	if _mature_planters < _expected_planters:
		return
	_butterflies_released = true
	_spawn_four_butterflies()


func _spawn_four_butterflies() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var lv := tree.get_first_node_in_group(&"game_level") as Node2D
	if lv == null:
		return
	for slot in range(4):
		var bf := Sprite2D.new()
		bf.name = &"Level2Butterfly_%d" % slot
		bf.set_script(_BUTTERFLY_SCRIPT)
		lv.add_child(bf)
		bf.call_deferred(&"setup_flight", slot)
	tree.create_timer(2.0).timeout.connect(_spawn_christie, CONNECT_ONE_SHOT)


func _spawn_christie() -> void:
	var tree := get_tree()
	if tree == null:
		return
	var lv := tree.get_first_node_in_group(&"game_level") as Node2D
	if lv == null:
		return
	if lv.get_node_or_null(^"Christie") != null:
		return
	var christie := Node2D.new()
	christie.name = &"Christie"
	christie.set_script(_CHRISTIE_SCRIPT)
	lv.add_child(christie)
	christie.call_deferred(&"begin_walk_sequence")
