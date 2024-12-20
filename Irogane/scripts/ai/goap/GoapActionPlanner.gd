extends Node
class_name GoapActionPlanner

const reverse = false
const debug = false

static func plan(initital_world_state, goal_state, actions):
	var open_list = []
	var closed_list = []
	
	var initial_node = AStarNode.new(null, initital_world_state) if not reverse else AStarNode.new(null, goal_state)
	var goal_node = AStarNode.new(null, goal_state) if not reverse else AStarNode.new(null, initital_world_state)
	DEBUG("* INITIAL:")
	DEBUG(initial_node._to_string())
	DEBUG("* GOAL:")
	DEBUG(goal_node._to_string())
	DEBUG("* ACTIONS :")
	DEBUG(actions)
	# Create initial node
	open_list.append(initial_node)
	
	while open_list.size() > 0:
		DEBUG("* BEFORE SORT:\n" + str(open_list))
		
		open_list.sort_custom(GoapActionPlanner.compare_states) # Sort by lowest g_cost + h_cost
		
		DEBUG("* AFTER SORT:\n" + str(open_list))
		
		var current = open_list.pop_front()
		closed_list.append(current)
		
		DEBUG("\n****** NEW ITERATION,******\n")
		DEBUG("* CURRENT:")
		DEBUG(current._to_string())
		
		# Reached goal
		if all_conditions_met(current.state, goal_node.state):
			return reconstruct_path(current)
		
		var neighbors = get_neighbors(current, actions) if not reverse else get_neighbors_reverse(current, actions)
		for neighbor in neighbors:
			DEBUG("* GOT NEIGHBOR:")
			DEBUG(neighbor._to_string())
			
			if contains_node(closed_list, neighbor): # Skip already visited
				DEBUG("* IN CLOSED - SKIPPING *")
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
			
			DEBUG("* UPDATING VALUES:")
			DEBUG(neighbor._to_string())
			
	return []
	

static func compare_states(node_1: AStarNode, node_2: AStarNode):
	return node_1.f_cost() < node_2.f_cost()
	

# Gets neighbors according to possible actions from out current state
static func get_neighbors(node: AStarNode, all_actions):
	var neighbors = []
	for action in all_actions:
		if action.is_valid(node.state):
			neighbors.append(AStarNode.new(action, node.state))
		
	return neighbors
	

# Gets neighbors according to actions that lead to our current state
static func get_neighbors_reverse(node: AStarNode, all_actions):
	var neighbors = []
	for action in all_actions:
		for effect in action.get_effects():
			if effect in node.state:
				neighbors.append(AStarNode.new(action, node.state))
				break
		
	return neighbors
	

# Count differences between states
static func heuristic(node: AStarNode, goal_node: AStarNode):
	var diff = 0
	for key in goal_node.state:
		if not node.state.has(key) or node.state[key] != goal_node.state[key]:
			diff += 1
	
	return diff
	

static func all_conditions_met(state, conditions):
	for key in conditions:
		if not state.has(key) or state[key] != conditions[key]:
			return false
	
	return true
	

static func reconstruct_path(node: AStarNode):
	var path = []
	var current = node
	
	while current != null:
		path.append(current)
		current = current.parent
	
	path.reverse()
	path.pop_front() # Get rid of initial state node
	
	return path
	

# TODO: Increase performance by switching to dict
static func contains_node(array, node: AStarNode):
	for n in array:
		if n.is_equal_to(node):
			return true
	return false
	

static func DEBUG(message):
	if not debug:
		return
	print(message)
	
