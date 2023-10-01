extends Node2D


func _process(_delta):
	resize()


func resize():
	var control_width: float = get_parent().get_parent().size.x
	var tilemap_width: float = %FleetTileMap.get_width()
	position.x = control_width / 2.0 - tilemap_width / 2.0
