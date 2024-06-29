extends Node
class_name AStarNode

var action : AIActionAbstract # Used for node comparison 
var g_cost = 0
var h_cost = 0
var state = {}
var parent = null

func _init(_action : AIActionAbstract = null, world_state: Dictionary = {}, _parent : AStarNode = null):
	parent = _parent
	
	if _action != null:
		action = _action
		g_cost = _action.get_cost(world_state)
		state = _action.get_effects()
	
	# We merge the current world state into our effects to create 
	# the new world state that will result from this action
	state.merge(world_state)
	

func f_cost():
	return g_cost + h_cost
	

func is_equal_to(node : AStarNode):
	return action == node.action and state.hash() == node.state.hash()
	

func get_action_name():
	if action == null:
		return "null"  
	if action is GotoAction:
		return "Goto"
	
	return Utils.get_resource_file_name(action)
	

func _to_string():
	var string = "------------\nid : {id} \naction: {action} \ng_cost: {g_cost} h_cost: {h_cost} \nstate: {state} \nparent: {parent}"
	var parent_name = "null" if parent == null else parent.get_action_name()
	string = string.format({
		"id" : get_instance_id(), "action" : get_action_name(), 
		"g_cost" : g_cost, "h_cost" : h_cost, "state" : state, 
		"parent" : parent_name})
	
	if action is GotoAction:
		var node_name = action.target_node.name
		if node_name == "":
			node_name = "[Nameless Node]"
		
		string += "\ndynamic: " + node_name
	
	string += "\n------------\n"
	
	return string
	
