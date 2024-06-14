extends Resource
class_name AIGoalAbstract


func get_requirements() -> Dictionary:
	return {}
	

func get_priority() -> int:
	return 1;
	

func is_valid(world_state: Dictionary) -> bool:
	return true;
	

