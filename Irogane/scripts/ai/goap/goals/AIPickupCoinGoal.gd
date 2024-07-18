extends AIGoalAbstract
class_name AIPickupCoinGoal

func get_requirements() -> Dictionary:
	return {"picked_coin": true}
	

func get_priority(world_state: Dictionary) -> int:
	var priority = 0
	if world_state.has("nearest_coin") and world_state.has("self"):
		var distance = world_state["nearest_coin"].global_position.distance_to(world_state["self"].global_position)
		priority = ( 4 - distance ) * 50
	
	return priority
	
