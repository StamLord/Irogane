extends AIGoalAbstract
class_name AISearchEnemyGoal

func get_requirements() -> Dictionary:
	return {"searched": true}
	

func get_priority(world_state: Dictionary) -> int:
	return 200;
	

func is_valid(world_state: Dictionary) -> bool:
	return world_state.has("search_point");
	
