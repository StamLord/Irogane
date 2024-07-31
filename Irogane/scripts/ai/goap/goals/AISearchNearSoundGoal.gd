extends AIGoalAbstract
class_name AISearchNearSoundGoal

func get_requirements() -> Dictionary:
	return {"investigated_sound": true}
	

func get_priority(world_state: Dictionary) -> int:
	return 250;
	

func is_valid(world_state: Dictionary) -> bool:
	# We heard a sound AND we know an enemy is nearby
	return world_state.has("sound_heard_at") and world_state.has("enemy_last_seen_at");
	
