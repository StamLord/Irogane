extends AIActionAbstract
class_name AIBuyHummus

func get_cost(world_state) -> float:
	return 1.0;
	

func get_requirements() -> Dictionary:
	return {
		"in_store" : true,
	}
	

func get_effects() -> Dictionary:
	return {
		"has_hummus" : true,
	}
	
