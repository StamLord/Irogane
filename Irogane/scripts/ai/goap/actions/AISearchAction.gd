extends AIActionAbstract
class_name AISearchAction

func get_requirements() -> Dictionary:
	return {"near_search_point": true}
	

func get_cost(world_state: Dictionary) -> float:
	return 1.0;
	

func get_effects() -> Dictionary:
	return {"searched": true}
	

func start_action(agent):
	agent.animate("Search Action")
	

func finish_action(agent):
	if not agent.world_state.has("search_counter"):
		agent.world_state["search_counter"] = 0
		agent.generate_new_search_point()
		return
	
	agent.world_state["search_counter"] += 1
	
	# First point is the last seen position of the enemy,
	# And we want to generate 3 points after that so 4 in total
	if agent.world_state["search_counter"] >= 4:
		agent.erase_world_state("search_point")
		agent.erase_world_state("search_counter")
		return
	
	agent.generate_new_search_point()
	

func get_action_name(): return "AILookAroundAction"
