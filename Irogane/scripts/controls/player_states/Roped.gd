extends PlayerState
class_name Roped

# Refs
@onready var ledge_check = %ledge_check
@onready var climb_check = %climb_check
@onready var head_check = %head_check
@onready var wall_check = %wall_check

@onready var stats = %stats

# Variables
@export var roped_acceleration = 0.1
@export var roped_move_acceleration = 40.0
@export var roped_move_speed = 8
@export var jump_force = 2.0
@export var push_force = 4
@export var swing_force = 4.0
@export var swing_burst = 6.0
@export var swing_rate = 1

var direction = Vector3.ZERO
var speed = 0

var wall_normal = Vector3.ZERO
var last_swing_input = 0
var last_swing_left = 0
var last_swing_right = 0
var last_swing_backward = 0
var last_swing_forward = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func Enter(body):
	direction = body.last_direction
	speed = body.last_speed
	last_swing_input = Time.get_ticks_msec()
	

func Update(_delta):
	pass
	

func PhysicsUpdate(body, delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = (body.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var velocity = body.velocity
	
	# Apply gravity
	velocity.y -= gravity * delta
	
	var grapple = state_machine.grapple_object
	if grapple and grapple.is_grappling:
		var to_grapple_point = grapple.end_target.global_position - grapple.start_target.global_position
		var distance = to_grapple_point.length()
		var force = 20.0 * max(0, distance - grapple.start_distance)	# Hooke's law + clamping to prevent rope pushing back when too close
		
		velocity += to_grapple_point.normalized() * force * delta 
		velocity *= (1.0 - 0.99 * delta)									# Dampening
		
		var forward = -state_machine.global_basis.z
		var horizontal = to_grapple_point.cross(forward).normalized()
		var vertical = horizontal.cross(to_grapple_point).normalized()
		
		if Input.is_action_just_pressed("left") and time_passed(last_swing_left, swing_rate):
			velocity += horizontal * swing_burst
			last_swing_left = Time.get_ticks_msec()
		elif Input.is_action_just_pressed("right") and time_passed(last_swing_right, swing_rate):
			velocity += horizontal * -swing_burst
			last_swing_right = Time.get_ticks_msec()
		elif Input.is_action_just_pressed("forward") and time_passed(last_swing_forward, swing_rate):
			velocity += vertical * swing_burst
			last_swing_forward = Time.get_ticks_msec()
		elif Input.is_action_just_pressed("backward") and time_passed(last_swing_backward, swing_rate):
			velocity += vertical * -swing_burst
			last_swing_backward = Time.get_ticks_msec()
		
		velocity += horizontal * -input_dir.x * swing_force * delta
		velocity += vertical * -input_dir.y * swing_force * delta
		
	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		body.velocity += direction * swing_burst
		state_machine.end_roped()
		Transitioned.emit(self, "jump")
		return
	
	# Longer Rope
	if Input.is_action_pressed("crouch"):
		if grapple:
			grapple.start_distance += 2.0 * delta
	
	# Shorter Rope
	if Input.is_action_pressed("sprint"):
		if grapple:
			grapple.start_distance -= 2.0 * delta
		
	
	body.velocity = velocity
	body.move_and_slide()
	
	# Collisions
	PerformCollisions(body, speed, push_force, delta)
	
	# Ground State
	if body.is_on_floor():
		if not head_check.is_colliding(): 
			Transitioned.emit(self, "walk")
			return
		else:
			Transitioned.emit(self, "crouch")
			return
	
	# Climb State
	if stats.stamina.get_value() >= 5 and climb_check.is_colliding() and input_dir.y < 0:
		Transitioned.emit(self, "climb")
		return
	

func Exit(body):
	body.last_direction = direction
	

func time_passed(last_time : int, minimum_time : int):
	return Time.get_ticks_msec() - last_time >= minimum_time * 1000
	
