extends AIActionAbstract
class_name AIBakePizza

func get_cost(world_state) -> float:
	return 3.0;
	

func get_effects() -> Dictionary:
	return {
		"has_pizza": true
	}
	
