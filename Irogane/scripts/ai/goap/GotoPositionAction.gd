extends AIActionAbstract
class_name GotoPositionAction

var target_position = null
var effects = {}
var requirements = {}

func _init(_target_position: Vector3, _effects: Dictionary, _requirements : Dictionary = {}):
	target_position = _target_position
	effects = _effects
	requirements = _requirements
	

func get_requirements() -> Dictionary:
	return requirements
	

func get_cost(world_state: Dictionary) -> float:
	if target_position == null or not world_state.has("position"):
		return 0.0
	
	return world_state["position"].distance_to(target_position)
	

func get_effects() -> Dictionary:
	return effects
	

func start_action(agent):
	agent.goto_position(target_position)
	

func cancel_action(agent):
	agent.cancel_goto()
	

func get_action_name(): return "GotoPositionAction"

func equals(action):
	return super.equals(action) and action is GotoPositionAction and action.target_position == target_position
	

