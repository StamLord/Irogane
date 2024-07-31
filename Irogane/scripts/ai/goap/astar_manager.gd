extends Node
class_name AStarManager

func run_astar(goal: AIGoalAbstract):
	var open_nodes = []
	var closed_nodes = {}
	
	var goal_node = AIGraphNode.new()
	open_nodes.push_back(goal_node)
	
	while (open_nodes.keys().size() > 0):
		var curr_node = get_cheapest_node(open_nodes)
		print("open nodes ", open_nodes)
	
	#open_nodes.erase(key)
	

func get_cheapest_node(node_dict):
	var cheapest: AIGraphNode = null
	
	for node in node_dict:
		var cost = node.get_estimated_cost()
		if not cheapest || cost < cheapest.get_estimated_cost():
			cheapest = node
		
	return cheapest
	
