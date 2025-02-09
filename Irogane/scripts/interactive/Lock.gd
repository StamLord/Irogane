extends Node3D
class_name Lock

@export var door: Switch
@export var required_keys : Array[Key]

var is_unlocked = false

signal on_state_changed(new_state: bool)

func unlock():
	if is_unlocked:
		return
	
	is_unlocked = true
	on_state_changed.emit(is_unlocked)
	

func use_keys(interactor) -> bool:
	if interactor == null:
		return false
	
	for key in required_keys:
		var use_key = interactor.use_key(key.tower_id, key.color)
		if use_key == false:
			return false
	
	return true
	
