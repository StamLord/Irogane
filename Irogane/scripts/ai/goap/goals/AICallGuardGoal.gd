extends AIGoalAbstract
class_name AICallGuardGoal

func get_requirements() -> Dictionary:
	return {"guard_called": true}
	

func get_priority(world_state: Dictionary) -> int:
	return 200
	

func is_valid(world_state: Dictionary) -> bool:
	# This goal is valid once we see an enemy,
	# but also after we lose sight of him
	return (world_state.has("enemy") or world_state.has("enemy_last_seen_at")) and not world_state.has("guard_called")
	
