extends Node3D
class_name Lock

@export var door: Switch

func unlock():
	# TODO: Implement better method
	if door != null:
		door.required_keys.clear()
		door.use(null)
	
