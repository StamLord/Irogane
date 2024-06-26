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
func activate_action(data):
	pass;
	

func cancel_action(data):
	pass;
	

