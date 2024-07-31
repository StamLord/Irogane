extends AIActionAbstract
class_name AIEatPizza

func get_cost(world_state) -> float:
	return 1.0;
	

func get_requirements() -> Dictionary:
	return {
		"has_pizza" : true,
	}
	

func get_effects() -> Dictionary:
	return {
		"has_pizza" : false,
		"is_hungry" : false
	}
	
