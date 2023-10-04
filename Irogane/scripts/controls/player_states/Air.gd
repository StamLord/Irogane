extends PlayerState
class_name Air

# Refs
@onready var ledge_check = $"../../ledge_check"
@onready var wall_check = $"../../wall_check"
@onready var rope_check = $"../../rope_check"
@onready var head_check = $"../../head_check"
@onready var water_check = $"../../water_check"

# Variables
@export var air_acceleration = 0.1
@export var air_move_acceleration = 10
@export var air_move_speed = 8
@export var max_air_jumps = 1;

@export var push_force = 4;

var direction = Vector3.ZERO
var speed = 0
var current_air_jump = 0

signal air_started()
signal air_ended()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func Enter(body):
	direction = body.last_direction
	speed = body.last_speed
	air_started.emit()

func Update(delta):
	pass

func PhysicsUpdate(body, delta):
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = (body.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var velocity = body.velocity
	
	# Apply gravity
	velocity.y -= gravity * delta
	
	# If we are moving in air, we want snappy acceleration
	if input_dir:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * air_move_acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * air_move_acceleration)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * air_acceleration)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * air_acceleration)
	
	body.velocity = velocity
	body.move_and_slide()
	
	# Collisions
	PerformCollisions(body, speed, push_force, delta)
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and current_air_jump < max_air_jumps:
		current_air_jump += 1
		Transitioned.emit(self, "jump")
		return
	
	# Climb Rope
	if rope_check.is_colliding():
		for i in range(rope_check.get_collision_count()):
			if rope_check.get_collider(i).get_parent() is Rope:
				Transitioned.emit(self, "climb_rope")
				return
	
	# Vault State
	if input_dir.y < 0 and ledge_check.is_colliding() and not wall_check.is_colliding():
		# Verify we have enough head room
		var ledge_position = ledge_check.get_collision_point()
		var query = PhysicsRayQueryParameters3D.create(ledge_position, ledge_position + Vector3.UP * 0.9)
		var collision = body.get_world_3d().direct_space_state.intersect_ray(query)
		
		if not collision:
			Transitioned.emit(self, "vault")
			return
	
	if Input.is_action_just_pressed("crouch"):
		Transitioned.emit(self, "glide")
		return
	
	# Ground State
	if body.is_on_floor():
		current_air_jump = 0
		if not head_check.is_colliding(): 
			Transitioned.emit(self, "walk")
			return
		else:
			Transitioned.emit(self, "crouch")
			return
	
	# Water State
	if water_check.is_colliding():
		Transitioned.emit(self, "swim")
		return
	
func Exit(body):
	body.last_direction = direction
	air_ended.emit()
