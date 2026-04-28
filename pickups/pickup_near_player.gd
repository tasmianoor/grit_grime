class_name PickupNearPlayer extends RefCounted

## Distance from any player at which seed/trash pickups show their proximity glow.
const GLOW_DISTANCE_PX := 80.0

static var _radial_glow_tex: Texture2D


static func any_player_within_glow_distance(tree: SceneTree, world_pos: Vector2) -> bool:
	if tree == null:
		return false
	for n in tree.get_nodes_in_group(&"player"):
		if n is Player:
			var p := n as Player
			if is_instance_valid(p) and p.is_inside_tree():
				if p.global_position.distance_to(world_pos) <= GLOW_DISTANCE_PX:
					return true
	return false


## Same radius as pickups; true only if a player is close and holding a seed (not trash / empty).
static func any_seed_carrier_within_glow_distance(tree: SceneTree, world_pos: Vector2) -> bool:
	if tree == null:
		return false
	for n in tree.get_nodes_in_group(&"player"):
		if n is Player:
			var p := n as Player
			if not is_instance_valid(p) or not p.is_inside_tree():
				continue
			if p.get_held_seed_kind() == SeedDefs.Type.NONE:
				continue
			if p.global_position.distance_to(world_pos) <= GLOW_DISTANCE_PX:
				return true
	return false


static func radial_glow_texture() -> Texture2D:
	if _radial_glow_tex != null:
		return _radial_glow_tex
	var grad := Gradient.new()
	# Faint light yellow at center, transparent at edge.
	grad.set_color(0, Color(1.0, 0.96, 0.78, 0.42))
	grad.set_color(1, Color(1.0, 0.96, 0.78, 0.0))
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.width = 128
	tex.height = 128
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	_radial_glow_tex = tex
	return _radial_glow_tex
