extends TileMap


var x_max: int = 3:
	set(new_value):
		x_max = new_value
		for y in y_max + 1:
			set_free_cell(Vector2i(x_max, y))


var y_max: int = 2:
	set(new_value):
		y_max = new_value
		for x in x_max + 1:
			set_free_cell(Vector2i(x, y_max))


func _ready() -> void:
	for x in x_max + 1:
		for y in y_max + 1:
			set_free_cell(Vector2i(x, y))


func get_width() -> float:
	return (x_max + 1) * tile_set.tile_size.x


func erase_pos(global_pos: Vector2) -> void:
	return erase_cell(0, local_to_map(to_local(global_pos)))


func set_free_pos(global_pos: Vector2) -> void:
	return set_free_cell(local_to_map(to_local(global_pos)))


func set_free_cell(cell: Vector2i) -> void:
	if is_cell_within_playable_area(cell):
		set_cell(0, cell, 0, Vector2i.ZERO)


func get_cell_origin_at_pos(global_pos: Vector2) -> Vector2:
	return to_global(map_to_local(local_to_map(to_local(global_pos)))) - tile_set.tile_size / 2.0


func is_pos_used(global_pos: Vector2) -> bool:
	return is_cell_used(local_to_map(to_local(global_pos)))


func is_cell_used(cell: Vector2) -> bool:
	return get_cell_source_id(0, cell) != -1


func is_pos_empty(global_pos: Vector2) -> bool:
	return is_cell_empty(local_to_map(to_local(global_pos)))


func is_cell_empty(cell: Vector2) -> bool:
	var source_id = get_cell_source_id(0, cell)
	return source_id == 0 or source_id == 1


func is_pos_within_playable_area(global_pos: Vector2) -> bool:
	return is_cell_within_playable_area(local_to_map(to_local(global_pos)))


func is_cell_within_playable_area(cell: Vector2) -> bool:
	return cell.x >= 0 and cell.x <= x_max and cell.y >= 0 and cell.y <= y_max


func get_row_by_pos(global_pos: Vector2) -> int:
	return local_to_map(to_local(global_pos)).y


func get_column_by_pos(global_pos: Vector2) -> int:
	return local_to_map(to_local(global_pos)).x


func reset_highlighted_tiles() -> void:
	for selected_cell in get_used_cells_by_id(0, 1):
		set_free_cell(selected_cell)
	for error_cell in get_used_cells_by_id(0, 2):
		erase_cell(0, error_cell)


func highlight_pos(global_pos: Vector2) -> void:
	highlight_cell(local_to_map(to_local(global_pos)))


func highlight_cell(cell: Vector2i) -> void:
	if is_cell_within_playable_area(cell):
		if not is_cell_used(cell):
			set_cell(0, cell, 2, Vector2i.ZERO)
		elif get_cell_source_id(0, cell) == 0:
			set_cell(0, cell, 1, Vector2i.ZERO)
