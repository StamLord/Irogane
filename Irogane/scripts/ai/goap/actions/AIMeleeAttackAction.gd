extends AIActionAbstract
class_name AIMeleeAttackAction

func get_requirements() -> Dictionary:
	return {"near_enemy": true}
	

func get_cost(world_state: Dictionary) -> float:
	return 1.0;
	

func get_effects() -> Dictionary:
	return {"taget_dead": true}
	

# TODO: Figure out
func activate_action(agent):
	print("MELEE ATTACK!")
	

func cancel_action(data):
	pass
	
