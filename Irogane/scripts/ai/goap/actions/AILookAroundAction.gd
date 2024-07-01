extends AIActionAbstract
class_name AILookAroundAction

func get_requirements() -> Dictionary:
	return {"near_sound": true}
	

func get_cost(world_state: Dictionary) -> float:
	return 1.0;
	

func get_effects() -> Dictionary:
	return {"investigated_sound": true}
	

# TODO: Figure out
func activate_action(agent):
	agent.animate("Look Around")
	agent.erase_world_state("sound_heard_at")
	
