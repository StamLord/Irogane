extends AIActionAbstract
class_name AITurnLightOnAction

func get_requirements() -> Dictionary:
	return {"near_light": true}
	

func get_cost(world_state: Dictionary) -> float:
	return 1.0;
	

func get_effects() -> Dictionary:
	return {"in_dark": false}
	

func start_action(agent):
	agent.animate("Turn Light")
	

func finish_action(agent):
	agent.interact_nearest_light()
	
