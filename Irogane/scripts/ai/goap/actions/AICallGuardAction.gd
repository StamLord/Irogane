extends AIActionAbstract
class_name AICallGuardAction

func get_requirements() -> Dictionary:
	return {"near_guard": true}
	

func get_cost(world_state: Dictionary) -> float:
	return 1.0;
	

func get_effects() -> Dictionary:
	return {"guard_called": true}
	

func start_action(agent):
	agent.animate("Calling Guard")
	

func finish_action(agent):
	# We don't need to perform AICallGuardGoal anymore
	agent.update_world_state("guard_called", true)
	
	if agent.world_state.has("enemy_last_seen_at"):
		agent.inform_agents(10, "enemy_last_seen_at", agent.world_state["enemy_last_seen_at"])
	elif agent.world_state.has("enemy"):
		agent.inform_agents(10, "enemy_last_seen_at", agent.world_state["enemy"].global_position)
	
