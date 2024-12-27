extends AIActionAbstract
class_name AICallGuardAction

func get_requirements() -> Dictionary:
	return {"near_guard": true}
	

func get_cost(world_state: Dictionary) -> float:
	return 1.0;
	

func get_effects() -> Dictionary:
	return {"guard_called": true}
	

func start_action(agent):
	agent.animate("call_guard")
	

func finish_action(agent):
	# We don't need to perform AICallGuardGoal anymore
	agent.update_world_state("guard_called", true)
	
	var point = null
	if agent.world_state.has("enemy_last_seen_at"):
		point = agent.world_state["enemy_last_seen_at"]
	elif agent.world_state.has("enemy"):
		point = agent.world_state["enemy"].global_position
	
	agent.inform_agents(10, "enemy_last_seen_at", point)
	agent.inform_agents(10, "search_point", point)
	

func get_action_name(): return "AICallGuardAction"
