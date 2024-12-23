extends AIGoalAbstract
class_name AILightAreaGoal

func get_requirements() -> Dictionary:
	return {"in_dark": false}
	

func get_priority(world_state: Dictionary) -> int:
	var in_dark = world_state.has("in_dark") and world_state["in_dark"]
	var priority = 100 if in_dark else 50
	
	# Increase priority the closer a potential light source is
	if world_state.has("distance_light_off"):
		var distance = world_state["distance_light_off"]
		priority += ( 10 - distance ) * 10
	
	# Double priority if there is something to search
	if world_state.has("search_point"):
		priority *= 2
	
	return priority
	

func is_valid(world_state: Dictionary) -> bool:
	return world_state.has("light_off_nearby") and world_state["light_off_nearby"];
	
