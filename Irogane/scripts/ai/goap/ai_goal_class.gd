extends Resource
class_name AIGoalAbstract


func get_requirements() -> Dictionary:
	return {}
	

func get_priority(world_state: Dictionary) -> int:
	return 1;
	

func is_valid(world_state: Dictionary) -> bool:
	return true;
	

func _to_string():
	return Utils.get_resource_file_name(self)
	
