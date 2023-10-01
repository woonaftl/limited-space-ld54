extends TextureProgressBar


func update(new_value, new_max_value):
	max_value = new_max_value
	value = new_value
	%Label.text = "%s/%s" % [value, max_value]
