extends Resource
class_name AIGraphNode
# This class represents the nodes in the graph we build for A*

var requirements: Dictionary
var Parent: AIGraphNode


func get_requirements() -> Dictionary:
	return requirements
	

# This represents the estimated cost of the node, not the cost of action!
# f(node) in A*
func get_estimated_cost() -> float:
	return get_path_cost() + heuristic();
	

# This represents the actual cost of the best path to this node 
# g(node) in A*
func get_path_cost() -> float:
	return 0.0
	

# h(node) in A*
func heuristic() -> float:
	return 0.0
	
