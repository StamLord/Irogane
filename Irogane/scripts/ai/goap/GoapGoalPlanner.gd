extends Node
class_name GoapGoalPlanner

var debug = false

func get_goal(world_state, all_goals):
	var highest_priority_goal = null
	var highest_priority_value = -INF
	
	for goal in all_goals:
		debug_message("*** Checking goal: " + str(goal) + " ***")
		if not goal.is_valid(world_state):
			debug_message("-- SKIPPING INVALID --")
			continue
		
		var priority = goal.get_priority(world_state)
		debug_message("* Calculated Priority: " + str(priority))
		
		if highest_priority_goal == null or priority > highest_priority_value:
			highest_priority_goal = goal
			highest_priority_value = priority
	
	return highest_priority_goal
	
 
func debug_message(message):
	if not debug:
		return
	print(message)
	

