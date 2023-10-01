extends HBoxContainer


enum States {ACTION, FREE_SELECT}


const TILE_SET: TileSet = preload("res://ui/tile_set.tres")
const SHIP_NAMES: Array = [
	"Scout ($2 ❤️️1 †2)",
	"Interceptor ($2 ❤️️2 †1)",
	"Cruiser ($3 ❤️️2 †2)",
	"Fighter ($4 ❤️️3 †3)",
	"Assault ($4 ❤️️4 †2)",
	"Destroyer ($4 ❤️️2 †4)",
]
const SHIP_COST: Dictionary = {
	"Scout ($2 ❤️️1 †2)": 2,
	"Interceptor ($2 ❤️️2 †1)": 2,
	"Cruiser ($3 ❤️️2 †2)": 3,
	"Fighter ($4 ❤️️3 †3)": 4,
	"Assault ($4 ❤️️4 †2)": 4,
	"Destroyer ($4 ❤️️2 †4)": 4,
}
const SHIP_SCENES: Dictionary = {
	"Scout ($2 ❤️️1 †2)": preload("res://ships/scout.tscn"),
	"Interceptor ($2 ❤️️2 †1)": preload("res://ships/interceptor.tscn"),
	"Cruiser ($3 ❤️️2 †2)": preload("res://ships/cruiser.tscn"),
	"Fighter ($4 ❤️️3 †3)": preload("res://ships/fighter.tscn"),
	"Assault ($4 ❤️️4 †2)": preload("res://ships/assault.tscn"),
	"Destroyer ($4 ❤️️2 †4)": preload("res://ships/destroyer.tscn"),
}
const SHIP_SHAPES: Dictionary = {
	"Scout ($2 ❤️️1 †2)": [
			Vector2i(0, 0),
			Vector2i(0, 1),
		],
	"Interceptor ($2 ❤️️2 †1)": [
			Vector2i(0, 0),
			Vector2i(1, 0),
		],
	"Cruiser ($3 ❤️️2 †2)": [
			Vector2i(0, 0),
			Vector2i(0, 1),
			Vector2i(0, 2),
		],
	"Fighter ($4 ❤️️3 †3)": [
			Vector2i(1, 0),
			Vector2i(1, 1),
			Vector2i(0, 1),
			Vector2i(2, 1),
		],
	"Assault ($4 ❤️️4 †2)": [
			Vector2i(0, 0),
			Vector2i(1, 0),
			Vector2i(2, 0),
			Vector2i(1, 1),
		],
	"Destroyer ($4 ❤️️2 †4)": [
			Vector2i(0, 0),
			Vector2i(0, 1),
			Vector2i(1, 0),
			Vector2i(1, 1),
		],
}
const SHIP_TEXTURES: Dictionary = {
	"Scout ($2 ❤️️1 †2)": preload("res://ships/img/scout_icon.png"),
	"Interceptor ($2 ❤️️2 †1)": preload("res://ships/img/interceptor_icon.png"),
	"Cruiser ($3 ❤️️2 †2)": preload("res://ships/img/cruiser_icon.png"),
	"Fighter ($4 ❤️️3 †3)": preload("res://ships/img/fighter_icon.png"),
	"Assault ($4 ❤️️4 †2)": preload("res://ships/img/assault_icon.png"),
	"Destroyer ($4 ❤️️2 †4)": preload("res://ships/img/destroyer_icon.png"),
}

var level: int = 0

@onready var cursor = %Cursor
@onready var fleet_tile_map = %FleetTileMap
@onready var credits_label = %CreditsLabel
@onready var sell_ship_button = %SellShipButton
@onready var repair_ship_button = %RepairShipButton
@onready var reroll_button = %RerollButton
@onready var expand_x_button = %ExpandXButton
@onready var expand_y_button = %ExpandYButton
@onready var end_turn_button = %EndTurnButton
@onready var store_item_list = %StoreItemList
@onready var buttons_container = %ButtonsContainer
@onready var game_over_dialog = %GameOverDialog
@onready var about_dialog = %AboutDialog
@onready var fleet = %Fleet
@onready var target = %Target
@onready var target_label = %TargetLabel
@onready var boss


@onready var selected_ship:
	set(new_value):
		if is_instance_valid(selected_ship):
			selected_ship.deselect()
		selected_ship = new_value
		if is_instance_valid(selected_ship):
			selected_ship.select()
		reset_buttons()


@onready var credits: int = 0:
	set(new_value):
		credits = new_value
		credits_label.text = "YOUR CREDITS: %s" % credits
		reset_buttons()


@onready var state: States:
	set(new_value):
		state = new_value
		buttons_container.visible = state == States.FREE_SELECT
		fleet_tile_map.visible = state == States.FREE_SELECT


func _ready() -> void:
	get_window().min_size = Vector2i(1280, 720)
	state = States.ACTION
	end_turn_button.disabled = true
	new_turn()


func get_boss_scene():
	if level == 1:
		target_label.text = "TARGET: GOLIATH"
		return preload("res://bosses/goliath.tscn")
	elif level == 2:
		target_label.text = "TARGET: COLOSSUS"
		return preload("res://bosses/colossus.tscn")
	elif level == 3:
		target_label.text = "TARGET: DREADNOUGHT"
		return preload("res://bosses/dreadnought.tscn")
	elif level == 4:
		target_label.text = "TARGET: BEHEMOTH"
		return preload("res://bosses/behemoth.tscn")
	elif level == 5:
		target_label.text = "TARGET: TITAN (FINAL BOSS!)"
		return preload("res://bosses/titan.tscn")


func new_turn() -> void:
	level += 1
	set_up_store()
	var new_boss = get_boss_scene().instantiate()
	target.add_child(new_boss)
	boss = new_boss
	boss.teleport_to_local(Vector2(0, -300))
	boss.moving_towards = Vector2.ZERO
	await boss.arrived
	credits += 10
	state = States.FREE_SELECT


func reset_buttons():
	if is_instance_valid(selected_ship):
		sell_ship_button.disabled = false
		sell_ship_button.text = "SELL SELECTED SHIP ($1)"
	else:
		sell_ship_button.disabled = true
		sell_ship_button.text = "SELL SELECTED SHIP"
	if credits >= 1 and is_instance_valid(selected_ship) and selected_ship.hp_max > selected_ship.hp_current:
		repair_ship_button.disabled = false
		repair_ship_button.text = "REPAIR SELECTED SHIP ($1)"
	else:
		repair_ship_button.disabled = true
		repair_ship_button.text = "REPAIR SELECTED SHIP"
	for id in store_item_list.item_count:
		store_item_list.set_item_disabled(id, credits < SHIP_COST[store_item_list.get_item_text(id)])
		store_item_list.set_item_selectable(id, credits >= SHIP_COST[store_item_list.get_item_text(id)])
	reroll_button.disabled = credits < 1
	expand_x_button.disabled = credits < 6 and fleet_tile_map.x_max < 8
	expand_y_button.disabled = credits < 6 and fleet_tile_map.y_max < 4


func set_up_store():
	store_item_list.clear()
	for index in range(5):
		var ship_name = SHIP_NAMES.pick_random()
		store_item_list.add_item(ship_name, SHIP_TEXTURES[ship_name])


func _on_end_turn_button_pressed():
	selected_ship = null
	state = States.ACTION
	await check_lose()
	await fight_loop()
	await get_tree().create_timer(1.0).timeout
	%AudioBossAppears.play()
	await new_turn()


func fight_loop() -> void:
	while is_instance_valid(boss) and not boss.is_queued_for_deletion() and len(get_all_ships()) > 0:
		for ship in get_all_ships():
			%AudioLaserShoot.play()
			await ship.shoot()
			boss.modulate = Color.DARK_RED
			%AudioHitHurt.play()
			await get_tree().create_timer(0.05).timeout
			boss.modulate = Color.WHITE
			boss.hp_current -= ship.dmg
			if boss.hp_current <= 0:
				%AudioExplosion.play()
				await boss.explode()
				boss = null
				if level == 5:
					%AudioWin.play()
					game_over_dialog.popup_centered()
					game_over_dialog.title = "YOU WIN"
					game_over_dialog.dialog_text = "All enemy ships are destroyed."
					await game_over_dialog.confirmed
				break
		if is_instance_valid(boss) and not boss.is_queued_for_deletion():
			var rand = randf()
			if rand < 0.5:
				await boss.attack_vertical()
				var possible_rows = get_rows_with_ships()
				if len(possible_rows) > 0:
					var attacked_row = possible_rows.pick_random()
					var laser_horizontal = preload("res://laser_horizontal.tscn").instantiate()
					fleet.add_child(laser_horizontal)
					laser_horizontal.position.y = (attacked_row + 0.5) * TILE_SET.tile_size.y
					laser_horizontal.play("default")
					%AudioBossAttack.play()
					await laser_horizontal.animation_finished
					laser_horizontal.queue_free()
					await attack_ships(get_ships_in_row(attacked_row))
			else:
				await boss.attack_horizontal()
				var possible_columns = get_columns_with_ships()
				if len(possible_columns) > 0:
					var attacked_column = possible_columns.pick_random()
					var laser_vertical = preload("res://laser_vertical.tscn").instantiate()
					fleet.add_child(laser_vertical)
					laser_vertical.position.x = (attacked_column + 0.5) * TILE_SET.tile_size.x
					laser_vertical.play("default")
					%AudioBossAttack.play()
					await laser_vertical.animation_finished
					laser_vertical.queue_free()
					await attack_ships(get_ships_in_column(attacked_column))


func attack_ships(ships):
	for ship in ships:
		ship.modulate = Color.DARK_RED
	await get_tree().create_timer(0.05).timeout
	for ship in ships:
		ship.hp_current -= 1
		ship.modulate = Color.WHITE
	for ship in ships:
		if ship.hp_current <= 0:
			await explode_ship(ship)
	await get_tree().create_timer(0.1).timeout
	await check_lose()


func check_lose():
	if len(get_all_ships()) == 0:
		%AudioLose.play()
		game_over_dialog.popup_centered()
		await game_over_dialog.confirmed


func get_rows_with_ships():
	var result = []
	for row in fleet_tile_map.y_max + 1:
		if len(get_ships_in_row(row)) > 0:
			result.append(row)
	return result


func get_columns_with_ships():
	var result = []
	for column in fleet_tile_map.x_max + 1:
		if len(get_ships_in_column(column)) > 0:
			result.append(column)
	return result


func get_all_ships():
	return fleet.get_children().filter(func(x): return x.has_method("shoot") and not x.is_queued_for_deletion())


func get_ships_in_row(row: int):
	return fleet.get_children().filter(
		func(ship):
			if ship.has_method("shoot") and not ship.is_queued_for_deletion():
				var ship_name = ship.ship_name
				var positions = get_positions_filled_by_ship_name(ship.global_position, ship_name)
				var rows = positions.map(func(x): return fleet_tile_map.get_row_by_pos(x))
				return rows.any(func(x): return x == row)
			else:
				return false
				)


func get_ships_in_column(column: int):
	return fleet.get_children().filter(
		func(ship):
			if ship.has_method("shoot") and not ship.is_queued_for_deletion():
				var ship_name = ship.ship_name
				var positions = get_positions_filled_by_ship_name(ship.global_position, ship_name)
				var columns = positions.map(func(x): return fleet_tile_map.get_column_by_pos(x))
				return columns.any(func(x): return x == column)
			else:
				return false
				)


func _on_reroll_button_pressed():
	selected_ship = null
	if credits >= 1:
		%AudioBlipSelect.play()
		set_up_store()
		credits -= 1


func _on_sell_ship_button_pressed():
	if is_instance_valid(selected_ship) and not selected_ship.is_queued_for_deletion():
		%AudioPickupCoin.play()
		remove_ship(selected_ship)
		credits += 1
	selected_ship = null


func _on_repair_ship_button_pressed():
	if credits >= 1 and is_instance_valid(selected_ship) and not selected_ship.is_queued_for_deletion():
		selected_ship.hp_current = selected_ship.hp_max
		%AudioBlipSelect.play()
		credits -= 1
	selected_ship = null


func _on_expand_x_button_pressed():
	selected_ship = null
	if credits >= 6:
		fleet_tile_map.x_max += 1
		%AudioPowerUpBig.play()
		credits -= 6


func _on_expand_y_button_pressed():
	selected_ship = null
	if credits >= 6:
		fleet_tile_map.y_max += 1
		%AudioPowerUpBig.play()
		credits -= 6


func _on_ship_selected(ship):
	if get_selected_item_id() == -1 and state == States.FREE_SELECT:
		%AudioClick.play()
		selected_ship = ship


func _on_store_item_list_item_selected(_index):
	%AudioClick.play()
	selected_ship = null
	update_cursor()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		update_cursor()
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and state == States.FREE_SELECT:
			var selected_ship_in_store = get_selected_item_id()
			if selected_ship_in_store != -1:
				place_ship(get_global_mouse_position(), selected_ship_in_store)


func place_ship(pos: Vector2, id: int) -> void:
	if id != -1:
		var ship_name = store_item_list.get_item_text(id)
		var cost = SHIP_COST[ship_name]
		if credits >= cost:
			if can_ship_be_placed_at_pos_entirely(pos, id):
				var new_ship = SHIP_SCENES[ship_name].instantiate()
				fleet.add_child(new_ship)
				new_ship.ship_name = ship_name
				new_ship.teleport_to(fleet_tile_map.get_cell_origin_at_pos(pos))
				for erase_pos in get_positions_filled_by_ship_id(pos, id):
					fleet_tile_map.erase_pos(erase_pos)
				store_item_list.remove_item(id)
				credits -= cost
				%AudioPowerUp.play()
				end_turn_button.disabled = false
			store_item_list.deselect_all()
			update_cursor()


func explode_ship(ship) -> void:
	if is_instance_valid(ship) and not ship.is_queued_for_deletion():
		for pos in get_positions_filled_by_ship_name(ship.global_position, ship.ship_name):
			fleet_tile_map.set_free_pos(pos)
		%AudioExplosion.play()
		await ship.explode()


func remove_ship(ship) -> void:
	if is_instance_valid(ship) and not ship.is_queued_for_deletion():
		for pos in get_positions_filled_by_ship_name(ship.global_position, ship.ship_name):
			fleet_tile_map.set_free_pos(pos)
		ship.queue_free()


func get_positions_filled_by_ship_name(pos: Vector2, ship_name: String):
	return SHIP_SHAPES[ship_name].map(func(offset): return pos + Vector2(offset.x * TILE_SET.tile_size.x, offset.y * TILE_SET.tile_size.y))


func get_positions_filled_by_ship_id(pos: Vector2, id: int):
	return get_positions_filled_by_ship_name(pos, store_item_list.get_item_text(id))


func can_ship_be_placed_at_pos_entirely(pos: Vector2, id: int) -> bool:
	var positions = get_positions_filled_by_ship_id(pos, id)
	return positions.all(func(x): return fleet_tile_map.is_pos_empty(x))


func can_ship_be_placed_at_pos_partially(pos: Vector2, id: int) -> bool:
	var positions = get_positions_filled_by_ship_id(pos, id)
	return positions.any(func(x): return fleet_tile_map.is_pos_within_playable_area(x))


func update_cursor(pos: Vector2 = get_global_mouse_position()) -> void:
	var selected_ship_id = get_selected_item_id()
	if selected_ship_id != -1:
		cursor.texture = store_item_list.get_item_icon(selected_ship_id)
	else:
		cursor.texture = null
	fleet_tile_map.reset_highlighted_tiles()
	if selected_ship_id != -1:
		if can_ship_be_placed_at_pos_partially(pos, selected_ship_id):
			cursor.position = fleet_tile_map.get_cell_origin_at_pos(pos)
			for highlight_pos in get_positions_filled_by_ship_id(pos, selected_ship_id):
				fleet_tile_map.highlight_pos(highlight_pos)
		else:
			cursor.position = pos + cursor.FREE_OFFSET
		cursor.set_can_be_placed(can_ship_be_placed_at_pos_entirely(pos, selected_ship_id))


func get_selected_item_id() -> int:
	var all_selected_items = store_item_list.get_selected_items()
	if len(all_selected_items) > 0:
		return all_selected_items[0]
	else:
		return -1


func _on_game_over_dialog_confirmed():
	get_tree().reload_current_scene()


func _on_fleet_nine_patch_rect_mouse_entered():
	cursor.visible = get_selected_item_id() != -1


func _on_fleet_nine_patch_rect_mouse_exited():
	cursor.visible = false


func _on_credits_button_pressed():
	about_dialog.popup_centered()
