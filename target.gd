extends Node2D


func _process(_delta):
	resize()


func resize():
	var control_width: float = get_parent().get_parent().size.x
	var children = get_children()
	var child_width: float = 0
	if len(children) > 0:
		if children[0].texture != null:
			child_width = children[0].texture.get_width()
	position.x = control_width / 2.0 - child_width / 2.0
