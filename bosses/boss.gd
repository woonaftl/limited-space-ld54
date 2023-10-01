extends Sprite2D


signal arrived


var movement_speed: float = 250
@export var hp_max: int = 1
@onready var hp_bar: TextureProgressBar = $HPBar as TextureProgressBar
@onready var moving_towards: Vector2 = position


var hp_current: int = 1:
	set(new_value):
		hp_current = clamp(new_value, 0, 9999)
		if hp_bar is TextureProgressBar:
			hp_bar.update(hp_current, hp_max)


func _ready() -> void:
	hp_current = hp_max


func _process(delta: float):
	if position != moving_towards:
		position = position.move_toward(moving_towards, delta * movement_speed)
	else:
		arrived.emit()


func teleport_to_local(pos: Vector2) -> void:
	position = pos
	moving_towards = position


func explode() -> void:
	texture = null
	hp_bar.visible = false
	var explosion = preload("res://explosion.tscn").instantiate()
	explosion.position = Vector2(0, 128)
	explosion.scale = Vector2(3, 3)
	add_child(explosion)
	await explosion.animation_finished
	queue_free()


func attack_vertical() -> void:
	await get_tree().create_timer(0.25).timeout


func attack_horizontal() -> void:
	await get_tree().create_timer(0.25).timeout
