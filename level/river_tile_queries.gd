class_name RiverTileQueries
extends RefCounted

## Atlas source index for `rivertile` on `level/tileset.tres` / `level 2/tileset.tres` (`sources/21`).
const RIVER_SOURCE_ID := 21


## True once the player is falling and the bottom-center of the hitbox maps onto a river cell.
## River cells registered as Cypress bridge floor (`tilemap_cypress_river_floor.gd`) are not treated as open water.
static func player_started_river_plummet(tm: TileMap, player: Player) -> bool:
	if not player.can_trigger_river_submersion():
		return false
	if not _feet_bottom_center_cell_is_river(tm, player):
		return false
	if _feet_on_cypress_river_tile_floor(tm, player):
		return false
	return true


static func _feet_bottom_center_cell_is_river(tm: TileMap, player: Player) -> bool:
	var cs := player.get_node_or_null(^"CollisionShape2D") as CollisionShape2D
	if cs == null or cs.disabled:
		return false
	var rect_shape := cs.shape as RectangleShape2D
	if rect_shape == null:
		return false
	var half := rect_shape.size * 0.5
	var feet_global := cs.global_transform * Vector2(0.0, half.y)
	var cell := tm.local_to_map(tm.to_local(feet_global))
	return tm.get_cell_source_id(0, cell) == RIVER_SOURCE_ID


static func _feet_on_cypress_river_tile_floor(tm: TileMap, player: Player) -> bool:
	if not tm.has_meta(&"cypress_river_floor_cell_dict"):
		return false
	var cs := player.get_node_or_null(^"CollisionShape2D") as CollisionShape2D
	if cs == null or cs.disabled or not (cs.shape is RectangleShape2D):
		return false
	var half := (cs.shape as RectangleShape2D).size * 0.5
	var feet_global := cs.global_transform * Vector2(0.0, half.y)
	var feet_cell := tm.local_to_map(tm.to_local(feet_global))
	var d: Dictionary = tm.get_meta(&"cypress_river_floor_cell_dict")
	return d.has(feet_cell)


## True when the bottom of the player has passed below the bottom edge of this camera's view (world space).
static func player_feet_below_viewport(player: Player, margin_px: float = 80.0) -> bool:
	var cam := player.camera as Camera2D
	if cam == null or not cam.is_inside_tree():
		return false
	var vp := cam.get_viewport()
	if vp == null:
		return false
	var half_h: float = vp.get_visible_rect().size.y / (2.0 * cam.zoom.y)
	var world_bottom: float = cam.get_screen_center_position().y + half_h + margin_px
	return feet_world_y(player) > world_bottom


static func feet_world_y(player: Player) -> float:
	var cs := player.get_node_or_null(^"CollisionShape2D") as CollisionShape2D
	if cs != null and cs.shape is RectangleShape2D:
		var half := (cs.shape as RectangleShape2D).size * 0.5
		return (cs.global_transform * Vector2(0.0, half.y)).y
	return player.global_position.y
