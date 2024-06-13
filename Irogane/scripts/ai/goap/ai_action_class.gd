extends Resource
class_name AIActionAbstract


func get_preconditions() -> Dictionary:
	return {}
	

func get_cost() -> float:
	return 0.0;
	

func get_results() -> Dictionary:
	return {}
	

func is_valid():
	return true;
	

func activate_action(data):
	pass;
	

func cancel_action(data):
	pass;
	

