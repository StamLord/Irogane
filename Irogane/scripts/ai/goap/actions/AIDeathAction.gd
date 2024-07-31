extends AIActionAbstract
class_name AIDeathAction

func get_requirements() -> Dictionary:
	return {}
	

func get_cost(world_state) -> float:
	return 0.0;
	

func get_effects() -> Dictionary:
	return {
		"is_dead": true
	}
	

func is_valid(world_state) -> bool:
	return true
	

func activate_action(data):
	pass
	

func cancel_action(data):
	pass
	

func get_action_name(): return "AIDeathAction"
