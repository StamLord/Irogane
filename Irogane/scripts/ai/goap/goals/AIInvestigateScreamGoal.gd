extends AIGoalAbstract
class_name AIInvestigateScreamGoal

func get_requirements() -> Dictionary:
	return {"investigated_sound": true} # Reusing LookAt to investigate 
										# both sound and screams
	

func get_priority(world_state: Dictionary) -> int:
	return 200
	

func is_valid(world_state: Dictionary) -> bool:
	return world_state.has("scream_heard_at")
	
