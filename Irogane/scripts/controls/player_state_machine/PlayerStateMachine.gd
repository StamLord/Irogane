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

func _ready():
	PlayerEntity.set_player_node(self)
	for child in states_parent.get_children():
		if child is PlayerState:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	
	if default_state:
		default_state.Enter(self)
		current_state = default_state
	
func _process(delta):
	if current_state:
		current_state.Update(delta)

func _physics_process(delta):
	# State Process
	if current_state:
		current_state.PhysicsUpdate(self, delta)
	

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if not new_state:
		return
		
	#print("EXITING: " + current_state.name)
	if current_state: 
		current_state.Exit(self)
		on_state_exit.emit(current_state.name)
	
	#print("ENTERING: " + new_state.name)
	new_state.Enter(self)
	current_state = new_state
	on_state_enter.emit(new_state.name)
	

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
	
