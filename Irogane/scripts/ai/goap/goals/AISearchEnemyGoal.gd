extends AIGoalAbstract
class_name AISearchEnemyGoal

func get_requirements() -> Dictionary:
	return {"near_enemy_last_seen": true}
	

func get_priority(world_state: Dictionary) -> int:
	return 200;
	

func is_valid(world_state: Dictionary) -> bool:
	return world_state.has("enemy_last_seen_at");
	
