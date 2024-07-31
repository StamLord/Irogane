extends AIGoalAbstract
class_name AIPatrolGoal

func get_requirements() -> Dictionary:
	return {"finished_patrol_point": true}
	

func get_priority(world_state: Dictionary) -> int:
	return 50
	
