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
@export var roped_move_acceleration = 40
@export var roped_move_speed = 8
@export var jump_force = 2.0
@export var push_force = 4
@export var swing_force = 4.0
@export var swing_rate = 1

var direction = Vector3.ZERO
var speed = 0

var wall_normal = Vector3.ZERO
var last_swing_left = 0
var last_swing_right = 0
var last_swing_backward = 0
var last_swing_forward = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func Enter(body):
	direction = body.last_direction
	speed = body.last_speed
	

func Update(_delta):
	pass
	

func PhysicsUpdate(body, delta):
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = (body.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var velocity = body.velocity
	
	# Apply gravity
	velocity.y -= gravity * delta
	
	# If we are moving near wall, we want snappy acceleration
	if wall_check.is_colliding():
		if input_dir:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * roped_move_acceleration)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * roped_move_acceleration)
	else:
		# One time boost for swinging in air
		if Input.is_action_just_pressed("left") and time_passed(last_swing_left, swing_rate):
			velocity += body.basis * Vector3(-swing_force, 0.0, 0.0)
			last_swing_left = Time.get_ticks_msec()
		elif Input.is_action_just_pressed("right") and time_passed(last_swing_right, swing_rate):
			velocity += body.basis * Vector3(swing_force, 0.0, 0.0)
			last_swing_right = Time.get_ticks_msec()
		elif Input.is_action_just_pressed("forward") and time_passed(last_swing_forward, swing_rate):
			velocity += body.basis * Vector3(0.0, 0.0, -swing_force)
			last_swing_forward = Time.get_ticks_msec()
		elif Input.is_action_just_pressed("backward") and time_passed(last_swing_backward, swing_rate):
			velocity += body.basis * Vector3(0.0, 0.0, swing_force)
			last_swing_backward = Time.get_ticks_msec()
	
	var rope = state_machine.rope_object
	if rope and rope.is_grappling:
		var dir_to_rope = rope.end_target.global_position - rope.global_position
		var distance_from_rope = dir_to_rope.length()
		var force = 20.0 * max(0, distance_from_rope - rope.start_distance)	# Hooke's law + clamping to prevent rope pushing back when too close
		velocity += dir_to_rope.normalized() * force * delta 
		velocity *= (1.0 - 0.99 * delta)									# Dampening
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and wall_check.is_colliding():
		velocity += wall_check.get_collision_normal() * jump_force
		if rope:
			rope.start_distance += 2.5
			
	
	body.velocity = velocity
	body.move_and_slide()
	
	# Collisions
	PerformCollisions(body, speed, push_force, delta)
	
	if Input.is_action_just_pressed("crouch"):
		state_machine.end_roped()
		Transitioned.emit(self, "air")
		return
	
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
	
