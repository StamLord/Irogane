extends CharacterBody3D
class_name PlayerStateMachine

# States Parent
@onready var states_parent = $states
@onready var stats = $stats
@onready var model = $model/human_model

# Variables
@export var push_force = 15
@export var default_state : PlayerState

var current_state : PlayerState
var states : Dictionary = {}

var last_direction = Vector3.ZERO
var last_speed = 0
var last_body_velocity

signal on_state_enter(state_name)
signal on_state_exit(state_name)

var debug = false

func _ready():
	PlayerEntity.set_player_node(self)
	for child in states_parent.get_children():
		if child is PlayerState:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	
	if default_state:
		default_state.Enter(self)
		current_state = default_state
	
	stats.on_heavy_hit.connect(push_back)
	
	var args = [
		{
			"arg_name": "x",
			"arg_type": DebugCommandsManager.ArgumentType.FLOAT,
			"arg_desc": "X component of the force vector",
		},
		{
			"arg_name": "y",
			"arg_type": DebugCommandsManager.ArgumentType.FLOAT,
			"arg_desc": "Y component of the force vector",
		},
		{
			"arg_name": "z",
			"arg_type": DebugCommandsManager.ArgumentType.FLOAT,
			"arg_desc": "Y component of the force vector",
		},
	]
	
	DebugCommandsManager.add_command("push", debug_push_back, args)
	

func _process(delta):
	if current_state:
		current_state.Update(delta)
		
		if debug:
			var state_color_seed = current_state.name.to_utf8_buffer().hex_encode().hex_to_int()
			var state_color = Utils.random_color(state_color_seed)
			var state_debug_duration = 10.0
			DebugCanvas.debug_point(global_position, state_color,12.0, state_debug_duration)
	

func _physics_process(delta):
	# State Process
	if current_state:
		if not stats.is_staggered or current_state == states["pushed"]:
			current_state.PhysicsUpdate(self, delta)
	

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		return
		
	if debug:
		#print("EXITING: " + current_state.name)
		var new_state_color_seed = new_state_name.to_utf8_buffer().hex_encode().hex_to_int()
		var new_state_color = Utils.random_color(new_state_color_seed)
		var new_state_debug_duration = 10.0
		DebugCanvas.debug_point(global_position, new_state_color, 24.0, new_state_debug_duration)
		DebugCanvas.debug_text(new_state_name, global_position + Vector3.UP, new_state_color, new_state_debug_duration)
	
	if current_state: 
		current_state.Exit(self)
		on_state_exit.emit(current_state.name)
	
	#print("ENTERING: " + new_state.name)
	new_state.Enter(self)
	current_state = new_state
	on_state_enter.emit(new_state.name)
	

func transition(new_state_name):
	on_child_transition(current_state, new_state_name)
	

func push_back(force_vector : Vector3):
	transition("pushed")
	current_state.direction = force_vector.normalized()
	current_state.speed = force_vector.length()
	

func debug_push_back(args : Array):
	push_back(Vector3(args[0], args[1], args[2]))
	

func save_data():
	var data = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"node_name" : name,
		"position" : global_position,
		"rotation" : rotation_degrees,
		"current_state" : current_state,
		"velocity" : velocity,
		"last_direction" : last_direction,
		"head_rotation" : get_node("head").rotation,
		"last_speed" : last_speed,
		"stats" : stats.save_data(),
		"appearance": model.save_appearance(),
		"quests": QuestManager.save_quests_data(),
		"skills": PlayerEntity.get_learned_skills(),
	}
	
	return data
	

func load_data(data):
	# Set transform
	global_position = Utils.str_to_vector3(data["position"])
	rotation_degrees = Utils.str_to_vector3(data["rotation"])
	velocity = Utils.str_to_vector3(data["velocity"])
	
	# Set last direction vector
	last_direction = Utils.str_to_vector3(data["last_direction"])
	last_speed = data["last_speed"]
	
	# Rotate head
	get_node("head").rotation = Utils.str_to_vector3(data["head_rotation"])
	
	# Transition to right state
	on_child_transition(current_state, data["current_state"])
	
	# Load stats
	stats.load_data(data["stats"])
	
	#load appearance
	model.load_appearance(data["appearance"])
	
	QuestManager.load_quests_data(data["quests"])
	PlayerEntity.set_learned_skills(data["skills"])
	
