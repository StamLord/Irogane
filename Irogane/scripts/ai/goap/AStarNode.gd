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
	

func _to_string():
	var action_name = "null" if action == null else Utils.get_resource_file_name(action)
	
	return {
		"id" : self,
		"action" : action_name,
		"g_cost" : g_cost, 
		"h_cost" : h_cost, 
		"state" : state,
		"requirements" : requirements,
		"parent" : parent }
	
