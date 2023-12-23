extends Node3D
class_name NpcStateMachine

# References
@onready var states_parent = $states # States Parent
@onready var pathfinding = $character_body # Pathfinding agent
@onready var stats = $stats
@onready var awareness_agent = %AwarenessAgent
@onready var schedule_agent = $ScheduleAgent

# Variables
@export var default_state : NpcState

var current_state : NpcState
var states : Dictionary = {}

var blackboard = {}

signal on_state_enter(state_name)
signal on_state_exit(state_name)

func _ready():
	for child in states_parent.get_children():
		if child is NpcState:
			states[child.name.to_lower()] = child
			child.state_machine = self
			child.Transitioned.connect(on_child_transition)
	
	if default_state:
		default_state.enter(self)
		current_state = default_state
	

func _process(delta):
	if current_state:
		current_state.update(delta)
	

func _physics_process(delta):
	if current_state:
		current_state.physics_update(self, delta)
	

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	
	print("[{name}] EXITING: {state}".format({"name" : name, "state" : current_state.name}))
	
	if current_state: 
		current_state.exit(self)
		on_state_exit.emit(current_state.name)
	
	DebugCanvas.debug_text("Start " + new_state.name, pathfinding.global_position, Color.RED, 3)
	
	print("[{name}] ENTERING: {state}".format({"name" : name, "state" : new_state_name}))
	
	new_state.enter(self)
	new_state.enter_time = Time.get_ticks_msec()
	current_state = new_state
	on_state_enter.emit(new_state.name)
	

func set_target_position(target_position):
	pathfinding.set_target_position(target_position)
	

func reset_target_position():
	pathfinding.reset_target_position()
	

func set_target_rotation(target_rotation):
	pathfinding.set_target_rotation(target_rotation)
	

func reset_target_rotation():
	pathfinding.reset_target_rotation()
	

func save_data():
	var data = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"node_name" : name,
		"position" : global_position,
		"rotation" : rotation_degrees,
		"current_state" : current_state,
		"stats" : get_node("stats").save_data()
	}
	
	return data
	

func load_data(data):
	# Set transform
	global_position = Utils.str_to_vector3(data["position"])
	rotation_degrees = Utils.str_to_vector3(data["rotation"])
	
	# Transition to right state
	on_child_transition(current_state, data["current_state"])
	
	# Load stats
	get_node("stats").load_data(data["stats"])
	
