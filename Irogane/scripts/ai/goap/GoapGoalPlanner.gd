extends Node
class_name GoapGoalPlanner

const debug = false

static func get_goal(world_state, all_goals):
	var highest_priority_goal = null
	var highest_priority_value = -INF
	
	for goal in all_goals:
		DEBUG("*** Checking goal: " + str(goal) + " ***")
		if not goal.is_valid(world_state):
			DEBUG("-- SKIPPING INVALID --")
			continue
		
		var priority = goal.get_priority(world_state)
		DEBUG("* Calculated Priority: " + str(priority))
		
		if highest_priority_goal == null or priority > highest_priority_value:
			highest_priority_goal = goal
			highest_priority_value = priority
	
	return highest_priority_goal
	
 
static func DEBUG(message):
	if not debug:
		return
	print(message)
	
