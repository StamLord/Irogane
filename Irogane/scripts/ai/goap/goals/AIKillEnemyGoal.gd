extends AIGoalAbstract
class_name AIKillEnemyGoal

func get_requirements() -> Dictionary:
	return {"taget_dead": true}
	

func get_priority(world_state: Dictionary) -> int:
	return 100;
	

func is_valid(world_state: Dictionary) -> bool:
	return true;
	

func _to_string():
	return Utils.get_resource_file_name(self)
	
