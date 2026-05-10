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


## Layer `0` cell under `global_point` uses the river atlas source (`RIVER_SOURCE_ID`).
static func global_point_on_river_tile(tm: TileMap, global_point: Vector2, layer: int = 0) -> bool:
	if tm == null:
		return false
	var cell := tm.local_to_map(tm.to_local(global_point))
	return tm.get_cell_source_id(layer, cell) == RIVER_SOURCE_ID


## Top-center world position of a **random** river tile on layer `0`, preferring cells visible in `prefer_rect`.
## Uses the cell quad in **world space** (four corners) so **Y** matches the drawn tile top even with TileMap
## transform / orientation. **X** is the horizontal midpoint of that quad. Returns `Vector2.ZERO` if no river cells.
static func random_river_tile_top_center_world(
	tm: TileMap, prefer_rect: Rect2, layer: int = 0
) -> Vector2:
	if tm == null:
		return Vector2.ZERO
	if tm.tile_set == null:
		return Vector2.ZERO
	var in_view: Array[Vector2i] = []
	var all_cells: Array[Vector2i] = []
	for cell: Vector2i in tm.get_used_cells(layer):
		if tm.get_cell_source_id(layer, cell) != RIVER_SOURCE_ID:
			continue
		all_cells.append(cell)
		var wp := _river_cell_top_center_world(tm, cell)
		if prefer_rect.has_point(wp):
			in_view.append(cell)
	var pick_pool: Array[Vector2i] = in_view if not in_view.is_empty() else all_cells
	if pick_pool.is_empty():
		return Vector2.ZERO
	var chosen: Vector2i = pick_pool[randi() % pick_pool.size()]
	return _river_cell_top_center_world(tm, chosen)


static func _river_cell_top_center_world(tm: TileMap, cell: Vector2i) -> Vector2:
	var tl := tm.to_global(tm.map_to_local(cell))
	var tr := tm.to_global(tm.map_to_local(cell + Vector2i(1, 0)))
	var bl := tm.to_global(tm.map_to_local(cell + Vector2i(0, 1)))
	var br := tm.to_global(tm.map_to_local(cell + Vector2i(1, 1)))
	var xmin := minf(minf(tl.x, tr.x), minf(bl.x, br.x))
	var xmax := maxf(maxf(tl.x, tr.x), maxf(bl.x, br.x))
	var y_top := minf(minf(tl.y, tr.y), minf(bl.y, br.y))
	var x_mid := (xmin + xmax) * 0.5
	return Vector2(x_mid, y_top)
