extends Resource
class_name AIActionAbstract


func get_requirements() -> Dictionary:
	return {}
	

func get_cost(world_state: Dictionary) -> float:
	return 0.0;
	

func get_effects() -> Dictionary:
	return {}
	

func is_valid(world_state: Dictionary) -> bool:
	var requirements = get_requirements()
	for req in requirements:
		if req not in world_state or requirements[req] != world_state[req]:
			return false
	
	return true
	

# TODO: Figure out
func start_action(agent):
	# agent.goto(pos) or agent.animate(clip)
	pass
	

func finish_action(agent):
	pass
	

func cancel_action(data):
	pass
	

func get_action_name(): return "AIActionAbstract"

func equals(action):
	var name = get_action_name() == action.get_action_name()
	var req = get_requirements().hash() == action.get_requirements().hash()
	var effects = get_effects().hash() == action.get_effects().hash()
	
	return name and req and effects
	
