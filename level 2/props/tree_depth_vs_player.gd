extends Sprite2D
## Draw this sprite in front of the player when they are **north** of the sort line (smaller `global_position.y`),
## so they can walk **behind** the canopy; otherwise draw under the player (`z_index` 4 vs player 5).

const _TREE_IN_FRONT_Z := 10
const _TREE_BEHIND_Z := 4


func _sprite_bottom_world_y(spr: Sprite2D) -> float:
	var r := spr.get_rect()
	var xf := spr.get_global_transform()
	var max_y := -INF
	for corner in [
		xf * r.position,
		xf * Vector2(r.end.x, r.position.y),
		xf * r.end,
		xf * Vector2(r.position.x, r.end.y),
	]:
		max_y = maxf(max_y, corner.y)
	return max_y


func _nearest_player() -> Node2D:
	var best: Node2D = null
	var best_dx := INF
	var tree_x := global_position.x
	for n in get_tree().get_nodes_in_group(&"player"):
		if not n is Node2D:
			continue
		var p := n as Node2D
		if not p.is_inside_tree():
			continue
		var dx := absf(p.global_position.x - tree_x)
		if dx < best_dx:
			best_dx = dx
			best = p
	return best


func _physics_process(_delta: float) -> void:
	var player := _nearest_player()
	if player == null:
		return
	var line_y := _sprite_bottom_world_y(self)
	var py := player.global_position.y
	z_as_relative = false
	# North of the tree base (smaller Y): behind foliage → tree on top.
	if py < line_y:
		z_index = _TREE_IN_FRONT_Z
	else:
		z_index = _TREE_BEHIND_Z
