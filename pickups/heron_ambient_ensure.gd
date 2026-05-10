extends RefCounted
## Instantiates `heron_ambient.tscn` under `game_level` when absent (no `class_name` — avoids parse-order issues).

const _SCENE: PackedScene = preload("res://level/props/birds/Heron/heron_ambient.tscn")


static func ensure_under_game_level(tree: SceneTree) -> Node:
	if Engine.is_editor_hint() or tree == null:
		return null
	for n in tree.get_nodes_in_group(&"heron_ambient"):
		return n
	var level := tree.get_first_node_in_group(&"game_level") as Node2D
	if level == null:
		return null
	var root := _SCENE.instantiate()
	level.add_child(root)
	return root


static func notify_maybe_spawn(tree: SceneTree) -> void:
	var h: Node = ensure_under_game_level(tree)
	if h != null and h.has_method(&"notify_maybe_spawn"):
		h.notify_maybe_spawn()


static func notify_maybe_spawn_deferred(tree: SceneTree) -> void:
	var h: Node = ensure_under_game_level(tree)
	if h != null:
		h.call_deferred(&"notify_maybe_spawn")
