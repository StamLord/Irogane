extends Node
class_name AStarGoap

var debug = false

func plan(initital_world_state, goal_state, actions):
	var open_list = []
	var closed_list = []
	var came_from = {}
	
	var initial_node = AStarNode.new(null, initital_world_state)
	var goal_node = AStarNode.new(null, goal_state)
	
	if debug:
		print("* INITIAL: *")
		print(initial_node._to_string())
		print("\n* GOAL *")
		print(goal_node._to_string())
	
	# Create initial node
	open_list.append(initial_node)
	
	while open_list.size() > 0:
		if debug:
			print("\n* BEFORE SORT:", open_list)
			
		open_list.sort_custom(compare_states) # Sort by lowest g_cost + h_cost
		
		if debug:
			print("* AFTER SORT:", open_list)
		
		var current = open_list.pop_front()
		closed_list.append(current)
		
		if debug:
			print("\n----- NEW ITERATION, CURRENT: -----")
			print(current._to_string(), '\n')
		
		# Reached goal
		if all_conditions_met(current.state, goal_node.state):
			return reconstruct_path(current)
		
		var neighbors = get_neighbors(current, actions)
		for neighbor in neighbors:
			if debug:
				print("\n----- GOT NEIGHBOR -----")
				print(neighbor._to_string())
			
			if contains_node(closed_list, neighbor): # Skip already visited
				if debug: 
					print("* IN CLOSED - SKIPPING *\n")
				continue
		
			var tentative_g_cost = current.g_cost + neighbor.g_cost
			
			if not contains_node(open_list, neighbor):
				open_list.append(neighbor)
				if debug: 
					print("* ADDED TO OPEN *")
			elif tentative_g_cost >= neighbor.g_cost: # Already in open and with a cheaper cost
				if debug: 
					print("* ALREADY LOWER COST - SKIPPING * ")
				continue
			
			neighbor.g_cost = tentative_g_cost
			neighbor.h_cost = heuristic(neighbor, goal_node)
			neighbor.parent = current
			
			if debug:
				print("* UPDATING VALUES * ")
				print(neighbor._to_string())
			
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
	
