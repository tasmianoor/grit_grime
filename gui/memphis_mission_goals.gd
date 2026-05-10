extends RefCounted

## Matches **`GameLevel.level_display_name`** for the Memphis level.
const DISPLAY_NAME := "Memphis Riverfront"

const _SOIL_DROP_SCRIPT := preload("res://pickups/soil_drop_zone.gd")

const _L1_MSG_NONE := "The riverfront remains untouched. Memphis needs your grit."
const _L1_MSG_RIVER_ONLY := "The river is cleaner, but smog still hangs in the air."
const _L1_MSG_SMOG_TRASH_REMAINING := "The air is clearer, but the river still suffers."
const _L1_MSG_SMOG_PARK_TRASH_DONE := "The park looks better, but the river and air need attention."
const _L1_MSG_2STAR_PARK_AIR_RIVER_DIRTY := (
	"Great job at restoring the park and clearing our air! Our polluted river will need some cleanup."
)
const _L1_MSG_2STAR_HERON_SKIES_WATER := (
	"The beautiful blue heron has returned! Clear skies and clean water brought her home."
)
const _L1_MSG_1STAR_ONLY_TRASH := (
	"The park and river are clean, but smog keeps the wildlife away."
)
const _L1_MSG_3STAR_ALL_DONE := (
	"Our ecosystem is thriving and the beautiful blue heron soars over a fully restored riverfront—all thanks to you!"
)


static func display_name() -> String:
	return DISPLAY_NAME


static func mature_tree_count(gl: Node) -> int:
	var n := 0
	for desc in gl.find_children("*", "", true, false):
		if desc.get_script() != _SOIL_DROP_SCRIPT:
			continue
		if desc.has_method(&"has_mature_locked_tree") and desc.has_mature_locked_tree():
			n += 1
	return n


static func trees_goal_met(gl: Node) -> bool:
	var soil_total := 3
	if gl.has_method(&"get_soil_drop_zone_count"):
		soil_total = maxi(1, int(gl.call(&"get_soil_drop_zone_count")))
	return mature_tree_count(gl) >= soil_total


static func trash_all_cleared(tree: SceneTree) -> bool:
	for n in tree.get_nodes_in_group(&"trash_pickup"):
		if is_instance_valid(n):
			return false
	return true


static func heron_goal_met(tree: SceneTree) -> bool:
	return not tree.get_nodes_in_group(&"heron_spawned").is_empty()


static func any_river_trash_remaining(tree: SceneTree) -> bool:
	for n in tree.get_nodes_in_group(&"trash_pickup"):
		if not is_instance_valid(n):
			continue
		if n.has_method(&"is_river_tile_trash") and bool((n as Object).call(&"is_river_tile_trash")):
			return true
	return false


static func any_ground_trash_remaining(tree: SceneTree) -> bool:
	for n in tree.get_nodes_in_group(&"trash_pickup"):
		if not is_instance_valid(n):
			continue
		if n.has_method(&"is_river_tile_trash") and not bool((n as Object).call(&"is_river_tile_trash")):
			return true
	return false


## Level 1 (Memphis) end-of-level stars (0–3) and caption under the star row.
## More outcomes can be added as mission logic expands.
static func level1_completion_stars_and_message(tree: SceneTree, gl: Node) -> Dictionary:
	var trees_ok := trees_goal_met(gl)
	var trash_ok := trash_all_cleared(tree)
	var heron_ok := heron_goal_met(tree)
	var river_dirty := any_river_trash_remaining(tree)
	var ground_dirty := any_ground_trash_remaining(tree)
	var river_clear := not river_dirty
	var ground_clear := not ground_dirty

	if trees_ok and trash_ok and heron_ok:
		return {&"stars": 3, &"message": _L1_MSG_3STAR_ALL_DONE}

	if trees_ok and heron_ok and river_clear and ground_dirty:
		return {&"stars": 2, &"message": _L1_MSG_2STAR_HERON_SKIES_WATER}

	if trees_ok and ground_clear and river_dirty:
		return {&"stars": 2, &"message": _L1_MSG_2STAR_PARK_AIR_RIVER_DIRTY}

	if trash_ok and not trees_ok and not heron_ok:
		return {&"stars": 1, &"message": _L1_MSG_1STAR_ONLY_TRASH}

	if not trees_ok and not heron_ok and river_clear and ground_dirty:
		return {&"stars": 1, &"message": _L1_MSG_RIVER_ONLY}

	if not trees_ok and not heron_ok and ground_clear and river_dirty:
		return {&"stars": 1, &"message": _L1_MSG_SMOG_PARK_TRASH_DONE}

	if trees_ok and trash_ok and not heron_ok:
		return {&"stars": 1, &"message": _L1_MSG_1STAR_ONLY_TRASH}

	if trees_ok and not trash_ok:
		return {&"stars": 1, &"message": _L1_MSG_SMOG_TRASH_REMAINING}

	if not trees_ok and not trash_ok and not heron_ok:
		return {&"stars": 0, &"message": _L1_MSG_NONE}

	return {&"stars": 0, &"message": _L1_MSG_NONE}
