extends AIGoalAbstract
class_name AIInvestigateGoal

func get_requirements() -> Dictionary:
	return {"investigated_sound": true}
	

func get_priority(world_state: Dictionary) -> int:
	return 150
	

func is_valid(world_state: Dictionary) -> bool:
	return world_state.has("sound_heard_at")
	
