extends RefCounted
## Instantiates `kingfisher_ambient.tscn` under `game_level` when absent (no `class_name` — avoids parse-order issues).

const _SCENE: PackedScene = preload("res://level/props/birds/Kfisher/kingfisher_ambient.tscn")


static func ensure_under_game_level(tree: SceneTree) -> Node:
	if Engine.is_editor_hint() or tree == null:
		return null
	for n in tree.get_nodes_in_group(&"kingfisher_ambient"):
		return n
	var level := tree.get_first_node_in_group(&"game_level") as Node2D
	if level == null:
		return null
	var root := _SCENE.instantiate()
	level.add_child(root)
	return root
