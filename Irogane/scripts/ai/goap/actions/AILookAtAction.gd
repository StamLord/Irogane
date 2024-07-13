extends AIActionAbstract
class_name AILookAtAction

var target_position = null
var effects = {}

func _init(_target_position: Vector3, _effects: Dictionary):
	target_position = _target_position
	effects = _effects
	

func get_effects() -> Dictionary:
	return effects
	

func start_action(agent):
	agent.look_at(target_position)
	agent.animate("Look At")
	

func finish_action(agent):
	agent.stop_look_at()
	

func equals(action):
	return super.equals(action) and action is AILookAtAction and action.target_position == target_position
	
