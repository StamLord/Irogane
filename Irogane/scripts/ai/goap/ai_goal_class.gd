extends Resource
class_name AIGoalAbstract


func get_desired_state() -> Dictionary:
	return {}
	

func get_priority() -> int:
	return 1;
	

func is_valid(data = null) -> bool:
	return true;
	

