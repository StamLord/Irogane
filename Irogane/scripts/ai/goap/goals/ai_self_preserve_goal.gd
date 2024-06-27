extends AIGoalAbstract
class_name AISelfPreserveGoal

func get_priority(world_state: Dictionary) -> int:
	if world_state.has("health"):
		return (100 - world_state["health"]) / 100.0 * 5 # At 80 HP priority = 1, at 60 HP = 2..
	
	return 0;
	
