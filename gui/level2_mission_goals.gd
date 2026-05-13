extends RefCounted

## HUD strike logic for **Beale** mission copy when **`use_memphis_mission_hud`** is on **Level 2** (`gui/score_hud.gd`).


static func roofs_weatherized_complete(gl: Node) -> bool:
	var bs := gl.get_node_or_null(^"BStreet")
	if bs == null or not bs.has_method(&"are_all_roofs_complete"):
		return false
	return bool(bs.call(&"are_all_roofs_complete"))


static func ac_upgrades_all_complete(tree: SceneTree) -> bool:
	var units := tree.get_nodes_in_group(&"ac_old_unit")
	if units.is_empty():
		return false
	for n in units:
		if not n.has_method(&"is_ac_upgrade_complete"):
			return false
		if not bool(n.call(&"is_ac_upgrade_complete")):
			return false
	return true


static func monarch_butterflies_present(tree: SceneTree) -> bool:
	return not tree.get_nodes_in_group(&"level2_monarch_butterfly").is_empty()


## **Christie** adds herself to **`christie_performance_complete`** after her final **PLAY** sprite beats (`level2_christie_npc.gd`).
static func christie_performance_complete(tree: SceneTree) -> bool:
	return not tree.get_nodes_in_group(&"christie_performance_complete").is_empty()
