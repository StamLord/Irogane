extends AIGoalAbstract
class_name AIDeathGoal

func get_desired_state() -> Dictionary:
	return {
		"is_dead": true
	}
	

func get_priority() -> int:
	return 100;
	

func is_valid(data = null) -> bool:
	return data["agent"].get_health() <= 0
	
