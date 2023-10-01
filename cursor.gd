extends Sprite2D


const TILE_SET: TileSet = preload("res://ui/tile_set.tres")
const FREE_OFFSET: Vector2 = Vector2(-10, -10)


func get_coord() -> Vector2:
	return pos_to_coord(region_rect.position)


func set_tile(coord: Vector2) -> void:
	region_rect.position = coord_to_pos(coord)


func set_can_be_placed(new_value: bool) -> void:
	if new_value:
		modulate = Color.WHITE
	else:
		modulate = Color.DARK_RED


func pos_to_coord(pos: Vector2) -> Vector2:
	return Vector2(pos.x / TILE_SET.tile_size.x, pos.y / TILE_SET.tile_size.y)


func coord_to_pos(coord: Vector2) -> Vector2:
	return Vector2(coord.x * TILE_SET.tile_size.x, coord.y * TILE_SET.tile_size.y)
