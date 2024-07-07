extends AIGoalAbstract
class_name AILightAreaGoal

func get_requirements() -> Dictionary:
	return {"in_dark": false}
	

func get_priority(world_state: Dictionary) -> int:
	var in_dark = world_state.has("in_dark") and world_state["in_dark"]
	if in_dark:
		return 150
	return 100;
	

func is_valid(world_state: Dictionary) -> bool:
	return world_state.has("light_off_nearby") and world_state["light_off_nearby"];
	
