extends HSlider

@export var audio_bus_name = ""

func _value_changed(new_value):
	# Remap value percentage to the working db range: -60 to 0
	var t = new_value / max_value
	var db = linear_to_db(t)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(audio_bus_name), db)
	owner.save_system_settings()
	

