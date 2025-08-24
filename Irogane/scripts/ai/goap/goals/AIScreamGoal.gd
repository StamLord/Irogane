extends AIGoalAbstract
class_name AIScreamGoal

func get_requirements() -> Dictionary:
	return {"screamed": true}
	

func get_priority(world_state: Dictionary) -> int:
	return 300
	

func is_valid(world_state: Dictionary) -> bool:
	# This goal is valid once we see an enemy
	# and didn't scream for the last 4 seconds
	var enemy = world_state.has("enemy")
	var screamed = world_state.has("scream_time")
	return enemy and (not screamed or Time.get_ticks_msec() - world_state["scream_time"] >= 4000)
	
