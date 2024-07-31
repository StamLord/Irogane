extends AIActionAbstract
class_name AIGotoStore

func get_cost(world_state) -> float:
	return 1.0;
	

func get_effects() -> Dictionary:
	return {
		"in_store" : true,
	}
	
