extends AIActionAbstract
class_name AIPickupCoinAction

func get_requirements() -> Dictionary:
	return {"near_coin": true}
	

func get_cost(world_state: Dictionary) -> float:
	return 1.0;
	

func get_effects() -> Dictionary:
	return {"picked_coin": true}
	

func start_action(agent):
	agent.animate("Pickup Coin")
	

func finish_action(agent):
	agent.stop_look_at()
	agent.pickup_nearest_coin()
	

func get_action_name(): return "AIPickupCoinAction"

