extends AIActionAbstract
class_name GotoPositionAction

var target_position = null
var effects = {}

func _init(_target_position: Vector3, _effects: Dictionary):
	target_position = _target_position
	effects = _effects
	

func get_cost(world_state: Dictionary) -> float:
	if target_position == null or not world_state.has("position"):
		return 0.0
	
	return world_state["position"].distance_to(target_position)
	

func get_effects() -> Dictionary:
	return effects
	

func activate_action(agent):
	agent.goto_position(target_position)
	
