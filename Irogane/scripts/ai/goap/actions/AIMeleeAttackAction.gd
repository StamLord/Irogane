extends AIActionAbstract
class_name AIMeleeAttackAction

func get_requirements() -> Dictionary:
	return {"near_enemy": true}
	

func get_cost(world_state: Dictionary) -> float:
	return 1.0;
	

func get_effects() -> Dictionary:
	return {"target_dead": true}
	

# TODO: Figure out
func start_action(agent):
	agent.animate("Melee")
	

func cancel_action(data):
	pass
	
