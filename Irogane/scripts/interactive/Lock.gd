extends Node3D
class_name Lock

@export var door: Switch
var is_unlocked = false

func unlock():
	if is_unlocked:
		return
	
	# TODO: Implement better method
	if door != null:
		door.required_keys.clear()
		if not door.state:
			door.use(null)
	
	is_unlocked = true
	
