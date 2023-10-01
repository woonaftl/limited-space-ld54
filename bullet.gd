extends AnimatedSprite2D


signal arrived


var movement_speed: float = 500


@onready var moving_towards: Vector2 = position


func _process(delta: float):
	if position != moving_towards:
		position = position.move_toward(moving_towards, delta * movement_speed)
	else:
		arrived.emit()
		queue_free()


func teleport_to_local(pos: Vector2) -> void:
	position = pos
	moving_towards = position
