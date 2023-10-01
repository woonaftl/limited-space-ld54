extends Area2D


var outline_material: Material = load("res://shaders/outline_material.tres")


signal arrived
signal selected(ship)


var ship_name: String
var mouse_inside: bool = false
var movement_speed: float = 450
@export var dimensions: Vector2 = Vector2(64, 64)
@export var dmg: int = 1
@export var hp_max: int = 1
@onready var hp_bar: TextureProgressBar = %HPBar as TextureProgressBar
@onready var moving_towards: Vector2 = position
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


var hp_current: int = 1:
	set(new_value):
		hp_current = clamp(new_value, 0, 9999)
		if hp_bar is TextureProgressBar:
			hp_bar.update(hp_current, hp_max)


func _ready() -> void:
	selected.connect(get_tree().current_scene._on_ship_selected)
	hp_current = hp_max


func _process(delta: float):
	if position != moving_towards:
		position = position.move_toward(moving_towards, delta * movement_speed)
	else:
		arrived.emit()


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton and mouse_inside and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selected.emit(self)


func shoot() -> void:
	sprite.play("shoot")
	await sprite.animation_finished
	sprite.play("default")
	var bullet = preload("res://bullet.tscn").instantiate()
	add_child(bullet)
	move_child(bullet, 0)
	var pos = dimensions / 2.0
	bullet.teleport_to_local(pos)
	bullet.moving_towards = pos + Vector2(0, -300)
	await bullet.arrived


func explode() -> void:
	sprite.visible = false
	var explosion = preload("res://explosion.tscn").instantiate()
	explosion.position = dimensions / 2.0
	add_child(explosion)
	await explosion.animation_finished
	queue_free()


func _on_mouse_entered() -> void:
	mouse_inside = true


func _on_mouse_exited() -> void:
	mouse_inside = false


func is_able_to_use_abilities() -> bool:
	return true


func teleport_to(global_pos: Vector2) -> void:
	position = to_local(global_pos)
	moving_towards = position


func select() -> void:
	sprite.material = outline_material


func deselect() -> void:
	sprite.material = null
