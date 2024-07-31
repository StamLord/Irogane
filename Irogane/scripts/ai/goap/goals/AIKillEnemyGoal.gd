extends AIGoalAbstract
class_name AIKillEnemyGoal

func get_requirements() -> Dictionary:
	return {"target_dead": true}
	

func get_priority(world_state: Dictionary) -> int:
	return 400;
	

func is_valid(world_state: Dictionary) -> bool:
	return world_state.has("enemy");
	

func get_states_to_erase():
	return ["sound_heard_at"]
	

func _to_string():
	return Utils.get_resource_file_name(self)
	
