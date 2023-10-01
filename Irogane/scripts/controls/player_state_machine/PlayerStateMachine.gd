extends CharacterBody3D
class_name PlayerStateMachine

# States Parent
@onready var states_parent = $states

# Variables
@export var push_force = 15
@export var default_state : PlayerState

var current_state : PlayerState
var states : Dictionary = {}

var last_direction = Vector3.ZERO
var last_speed = 0
var last_body_velocity

func _ready():
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
		last_direction = current_state.direction
		current_state.PhysicsUpdate(self, delta)
	
	var current_speed = 5
	if not current_state.get("speed") == null:
		current_speed = current_state.speed

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	print("EXITING: " + current_state.name)
	if current_state: 
		current_state.Exit(self)
	
	print("ENTERING: " + new_state.name)
	new_state.Enter(self)
	current_state = new_state
