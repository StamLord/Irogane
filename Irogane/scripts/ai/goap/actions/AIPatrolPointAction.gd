extends AIActionAbstract
class_name AIPatrolPointAction

func get_requirements() -> Dictionary:
	return {"near_patrol_point": true}
	

func get_cost(world_state: Dictionary) -> float:
	return 0.0;
	

func get_effects() -> Dictionary:
	return {"finished_patrol_point": true}
	

# TODO: Figure out
func start_action(agent):
	# This action is a blank; We don't goto or animate.
	# We make agent complete this action immediately:
	agent.complete_action() 
	

func finish_action(agent):
	agent.erase_world_state("near_patrol_point")
	agent.set_next_patrol_point()
	
