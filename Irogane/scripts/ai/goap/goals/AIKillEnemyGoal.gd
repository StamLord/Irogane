extends AIGoalAbstract
class_name AIKillEnemyGoal

func get_requirements() -> Dictionary:
	return {"target_dead": true}
	

func get_priority(world_state: Dictionary) -> int:
	return 200;
	

func is_valid(world_state: Dictionary) -> bool:
	return world_state.has("enemy");
	

func _to_string():
	return Utils.get_resource_file_name(self)
	
