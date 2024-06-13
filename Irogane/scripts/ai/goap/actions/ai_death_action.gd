extends AIActionAbstract
class_name AIDeathAction

func get_preconditions() -> Dictionary:
	return {}
	

func get_cost() -> float:
	return 0.0;
	

func get_results() -> Dictionary:
	return {
		"is_dead": true
	}
	

func is_valid():
	return true;
	

func activate_action(data):
	pass;
	# die
	

func cancel_action(data):
	pass;
	


