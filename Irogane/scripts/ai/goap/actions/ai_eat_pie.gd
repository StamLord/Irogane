extends AIActionAbstract
class_name AIEatPie

func get_cost(world_state) -> float:
	return 1.0;
	

func get_requirements() -> Dictionary:
	return {
		"has_pie" : true,
	}
	

func get_effects() -> Dictionary:
	return {
		"has_pie" : false,
		"is_hungry" : false
	}
	
