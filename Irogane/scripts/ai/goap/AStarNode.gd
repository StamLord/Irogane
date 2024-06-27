extends Node
class_name AStarNode

var action : AIActionAbstract # Used for node comparison 
var g_cost = 0
var h_cost = 0
var state = {}
var requirements = {}
var parent = null

func _init(_action : AIActionAbstract = null, world_state: Dictionary = {}, _parent : AStarNode = null):
	parent = _parent
	
	if _action != null:
		action = _action
		g_cost = _action.get_cost(world_state)
		requirements = _action.get_requirements()
		state = _action.get_effects()
	
	# We merge the current world state into our effects to create 
	# the new world state that will result from this action
	state.merge(world_state)
	

func f_cost():
	return g_cost + h_cost
	

func is_equal_to(node : AStarNode):
	return action == node.action
	

func get_action_name():
	return "null" if action == null else Utils.get_resource_file_name(action)
	

func _to_string():
	var string = "------------\nid : {id} \naction: {action} \ng_cost: {g_cost} h_cost: {h_cost} \nstate: {state} \nrequirements: {reqs} \nparent: {parent}\n------------\n"
	var parent_name = "null" if parent == null else parent.get_action_name()
	return string.format({
		"id" : get_instance_id(), "action" : get_action_name(), 
		"g_cost" : g_cost, "h_cost" : h_cost, "state" : state, 
		"reqs" : requirements, "parent" : parent_name})
	
