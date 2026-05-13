extends RefCounted

## HUD strike logic for **Beale** mission copy when **`use_memphis_mission_hud`** is on **Level 2** (`gui/score_hud.gd`).

const _L2_COMPLETE_MSG_0 := "Beale Street is still baking. Memphis needs your grit."
const _L2_COMPLETE_MSG_1A := "The rooftops are cooler, but the street still swelters below."
const _L2_COMPLETE_MSG_1B := "Energy bills are dropping, but the cool air won't last."
const _L2_COMPLETE_MSG_2 := "Buildings are efficient and cool! Now the street needs life."
const _L2_COMPLETE_MSG_3 := (
	"Beale Street is alive again! Monarchs drift over cool rooftops as musicians walk around blooming plants below."
)
const _L2_COMPLETE_MSG_FALLBACK_2 := "Two Beale missions are done—finish the last to bring the street fully back."
const _L2_COMPLETE_MSG_FALLBACK_1 := "Good progress—keep pushing on the Beale checklist."


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


## Level-complete **stars** (0–3) and **caption** for **Beale** when **`use_memphis_mission_hud`** is on (`level 2/level.gd` → **`game.gd`**).
static func level2_completion_stars_and_message(tree: SceneTree, gl: Node) -> Dictionary:
	var g1 := roofs_weatherized_complete(gl)
	var g2 := ac_upgrades_all_complete(tree)
	var g3 := monarch_butterflies_present(tree)
	if g1 and g2 and g3:
		return {&"stars": 3, &"message": _L2_COMPLETE_MSG_3}
	if g1 and g2:
		return {&"stars": 2, &"message": _L2_COMPLETE_MSG_2}
	if g1 and not g2 and not g3:
		return {&"stars": 1, &"message": _L2_COMPLETE_MSG_1A}
	if not g1 and g2 and not g3:
		return {&"stars": 1, &"message": _L2_COMPLETE_MSG_1B}
	if not g1 and not g2 and not g3:
		return {&"stars": 0, &"message": _L2_COMPLETE_MSG_0}
	var n := int(g1) + int(g2) + int(g3)
	if n == 2:
		return {&"stars": 2, &"message": _L2_COMPLETE_MSG_FALLBACK_2}
	if n == 1:
		return {&"stars": 1, &"message": _L2_COMPLETE_MSG_FALLBACK_1}
	return {&"stars": 0, &"message": _L2_COMPLETE_MSG_0}
