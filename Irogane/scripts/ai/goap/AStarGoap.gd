extends Node
class_name AStarGoap

var debug = false

func plan(initital_world_state, goal_state, actions):
	var open_list = []
	var closed_list = []
	var came_from = {}
	
	var initial_node = AStarNode.new(null, initital_world_state)
	var goal_node = AStarNode.new(null, goal_state)
	
	DEBUG("* INITIAL: ")
	DEBUG(initial_node._to_string())
	DEBUG("\n* GOAL: ")
	DEBUG(goal_node._to_string())
	
	# Create initial node
	open_list.append(initial_node)
	
	while open_list.size() > 0:
		DEBUG("\n* BEFORE SORT:" + str(open_list))
			
		open_list.sort_custom(compare_states) # Sort by lowest g_cost + h_cost
		
		DEBUG("* AFTER SORT:" + str(open_list))
		
		var current = open_list.pop_front()
		closed_list.append(current)
		
		DEBUG("\n----- NEW ITERATION, CURRENT: -----")
		DEBUG(current._to_string())
		
		# Reached goal
		if all_conditions_met(current.state, goal_node.state):
			return reconstruct_path(current)
		
		var neighbors = get_neighbors(current, actions)
		for neighbor in neighbors:
			DEBUG("\n----- GOT NEIGHBOR -----")
			DEBUG(neighbor._to_string())
			
			if contains_node(closed_list, neighbor): # Skip already visited
				DEBUG("* IN CLOSED - SKIPPING *\n")
				continue
		
			var tentative_g_cost = current.g_cost + neighbor.g_cost
			
			if not contains_node(open_list, neighbor):
				open_list.append(neighbor)
				DEBUG("* ADDED TO OPEN *")
			elif tentative_g_cost >= neighbor.g_cost: # Already in open and with a cheaper cost
				DEBUG("* ALREADY LOWER COST - SKIPPING * ")
				continue
			
			neighbor.g_cost = tentative_g_cost
			neighbor.h_cost = heuristic(neighbor, goal_node)
			neighbor.parent = current
			
			DEBUG("* UPDATING VALUES * ")
			DEBUG(neighbor._to_string())
			
	return []
	

func compare_states(node_1 : AStarNode, node_2 : AStarNode):
	return node_1.f_cost() < node_2.f_cost()
	

func get_neighbors(node : AStarNode, all_actions):
	var neighbors = []
	for action in all_actions:
		if action.is_valid(node.state):
			neighbors.append(AStarNode.new(action, node.state))
		
	return neighbors
	

# Count differences between states
func heuristic(node : AStarNode, goal_node : AStarNode):
	var diff = 0
	for key in goal_node.state:
		if not node.state.has(key) or node.state[key] != goal_node.state[key]:
			diff += 1
	
	return diff
	

func all_conditions_met(state, conditions):
	for key in conditions:
		if not state.has(key) or state[key] != conditions[key]:
			return false
	
	return true
	

func reconstruct_path(node : AStarNode):
	var path = []
	var current = node
	
	while current != null:
		path.append(current)
		current = current.parent
	
	path.reverse()
	return path
	

# TODO: Increase performance by switching to dict
func contains_node(array, node : AStarNode):
	for n in array:
		if n.is_equal_to(node):
			return true
	return false
	

func DEBUG(message):
	if not debug:
		return
	print(message)
	
