extends AIActionAbstract
class_name AIEatHummus

func get_cost(world_state) -> float:
	return 1.0;
	

func get_requirements() -> Dictionary:
	return {
		"has_hummus" : true,
	}
	

func get_effects() -> Dictionary:
	return {
		"has_hummus" : false,
		"is_hungry" : false
	}
	
