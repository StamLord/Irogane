extends AIActionAbstract
class_name AIScreamAction

func get_requirements() -> Dictionary:
	return {}
	

func get_cost(world_state: Dictionary) -> float:
	return 1.0;
	

func get_effects() -> Dictionary:
	return {"screamed": true}
	

func start_action(agent):
	agent.animate("scream")
	# TODO: Add voice line through agent.audio()
	

func finish_action(agent):
	agent.world_state["scream_time"] = Time.get_ticks_msec()
	agent.inform_agents(130, "scream_heard_at", agent.get_body().global_position)
	

func get_action_name(): return "AIScreamAction"
