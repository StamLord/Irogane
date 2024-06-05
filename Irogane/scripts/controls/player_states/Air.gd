extends PlayerState
class_name Air

# Refs
@onready var ledge_check = $"%ledge_check"
@onready var wall_check = $"%wall_check"
@onready var climb_check = %climb_check
@onready var rope_check = $"%rope_check"
@onready var head_check = $"%head_check"
@onready var head_check_2 = $"%head_check_2"
@onready var water_check = $"%water_check"
@onready var vault_state = $"../vault"
@onready var stats = %stats
@onready var rope = $"../../head/main_camera/weapon_manager/rope"

# Variables
@export var air_acceleration = 0.1
@export var air_move_acceleration = 10
@export var air_move_speed = 8
@export var max_air_jumps = 1;

@export var push_force = 4;

var direction = Vector3.ZERO
var speed = 0
var current_air_jump = 0

@export var fall_damage_threshold = Vector2(-7.0, -14.0)
@export var fall_damage_death = 5
var prev_velocity = Vector3.ZERO
var apply_fall_damage = false

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
	if state_machine.rope_object != null:
		Transitioned.emit(self, "roped")
		return
	
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
	
	# Dash State
	if InputUtils.is_action_just_double_pressed("forward"):
		direction = body.basis * Vector3(0, 0, -1)
		Transitioned.emit(self, "dash")
		return
	elif InputUtils.is_action_just_double_pressed("backward"):
		direction = body.basis * Vector3(0, 0, 1)
		Transitioned.emit(self, "dash")
		return
	elif InputUtils.is_action_just_double_pressed("left"):
		direction = body.basis * Vector3(-1, 0, 0)
		Transitioned.emit(self, "dash")
		return
	elif InputUtils.is_action_just_double_pressed("right"):
		direction = body.basis * Vector3(1, 0, 0)
		Transitioned.emit(self, "dash")
		return
	
	# Climb Rope
	if rope_check.is_colliding():
		for i in range(rope_check.get_collision_count()):
			if rope_check.get_collider(i).get_parent() is Rope:
				Transitioned.emit(self, "climb_rope")
				return
	
	# Vault State
	if input_dir.y < 0 and ledge_check.is_colliding() and not wall_check.is_colliding() and not head_check_2.is_colliding():
		if vault_state != null and vault_state.get_time_since_last_vault() > 500:
			# Verify we have enough head room
			var ledge_position = ledge_check.get_collision_point()
			var query = PhysicsRayQueryParameters3D.create(ledge_position + Vector3.UP * 0.01, ledge_position + Vector3.UP * 0.9)
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
		apply_fall_damage = true
		
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
	
	# Climb State
	if stats.stamina.get_value() >= 5 and climb_check.is_colliding() and input_dir.y < 0:
		Transitioned.emit(self, "climb")
		return
	
	prev_velocity = body.velocity
	

func Exit(body):
	body.last_direction = direction
	air_ended.emit()
	
	if apply_fall_damage:
		var velocity_over_threshold = fall_damage_threshold.x - prev_velocity.y
		var t = velocity_over_threshold  / abs(fall_damage_threshold.y - fall_damage_threshold.x)
		var damage = floori(t * fall_damage_death)
		state_machine.stats.deplete_health(damage)
	
	apply_fall_damage = false
	
