extends TileMap

## Same footprint as other ground tiles on this tileset (`physics_layer_0`, 64×64 cell).
var _river_floor_poly: PackedVector2Array = PackedVector2Array(
	[Vector2(-32, -22), Vector2(32, -22), Vector2(32, 32), Vector2(-32, 32)]
)

var _cypress_river_floor_cells: Dictionary = {}


func add_cypress_river_floor_cells(cells: Array[Vector2i]) -> void:
	for c in cells:
		_cypress_river_floor_cells[c] = true
	set_meta(&"cypress_river_floor_cell_dict", _cypress_river_floor_cells)
	notify_runtime_tile_data_update(0)


func _use_tile_data_runtime_update(layer: int, coords: Vector2i) -> bool:
	return layer == 0 and _cypress_river_floor_cells.has(coords)


func _tile_data_runtime_update(layer: int, coords: Vector2i, tile_data: TileData) -> void:
	if get_cell_source_id(0, coords) != RiverTileQueries.RIVER_SOURCE_ID:
		return
	tile_data.add_collision_polygon(0)
	var idx := tile_data.get_collision_polygons_count(0) - 1
	tile_data.set_collision_polygon_points(0, idx, _river_floor_poly)
	tile_data.set_collision_polygon_one_way(0, idx, false)
