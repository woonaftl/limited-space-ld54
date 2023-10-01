extends HSlider


var master_bus = AudioServer.get_bus_index("Master")


func _on_value_changed(_value):
	AudioServer.set_bus_volume_db(master_bus, value)
	AudioServer.set_bus_mute(master_bus, value <= min_value + 0.1)
