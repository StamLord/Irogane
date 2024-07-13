extends AIActionAbstract
class_name GotoAction

var target_node: Node3D = null
var effects = {}

func _init(_target_node: Node3D, _effects: Dictionary):
	target_node = _target_node
	effects = _effects
	

func get_cost(world_state: Dictionary) -> float:
	if target_node == null or not world_state.has("position"):
		return 0.0
	
	return world_state["position"].distance_to(target_node)
	

func get_effects() -> Dictionary:
	return effects
	

func start_action(agent):
	agent.goto(target_node)
	

func get_action_name(): return "GotoAction"

func equals(action):
	return super.equals(action) and action is GotoAction and action.target_node == target_node
	
