extends AIActionAbstract
class_name AILookAroundAction

func get_requirements() -> Dictionary:
	return {"near_sound": true}
	

func get_cost(world_state: Dictionary) -> float:
	return 1.0;
	

func get_effects() -> Dictionary:
	return {"investigated_sound": true}
	

func start_action(agent):
	agent.animate("look_around")
	

func finish_action(agent):
	agent.erase_world_state("sound_heard_at")
	

func get_action_name(): return "AILookAroundAction"
