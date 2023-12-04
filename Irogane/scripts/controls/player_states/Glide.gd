extends PlayerState
class_name Glide

# Refs
@onready var ledge_check = $"../../ledge_check"
@onready var wall_check = $"../../wall_check"
@onready var rope_check = $"../../rope_check"
@onready var water_check = $"../../water_check"
@onready var head = $"../../head/"
@onready var main_camera = $"../../head/main_camera"
@onready var wind_check = $"../../wind_check"

# Variables
@export var air_acceleration = 0.1
@export var air_move_acceleration = 10
@export var air_move_speed = 8

@export var jump_force = 4

@export var gravity_multiplier = 0.3;

@export var push_force = 4;

@export var max_camera_tilt = 25
@export var  camera_tilt_speed = 2

@export var min_camera_fov = 75
@export var max_camera_fov = 90
@export var max_fov_at_velocity = 30
@export var camera_fov_speed = 2

var direction = Vector3.ZERO
var speed = 0
var wind = Vector3.ZERO
var wind_area = null

signal glide_started()
signal glide_ended()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_multiplier

var prev_forward_velocity = Vector3.ZERO

func _ready():
	wind_check.area_entered.connect(on_area_enter)
	wind_check.area_exited.connect(on_area_exit)
	

func Enter(body):
	direction = body.last_direction
	speed = body.last_speed
	
	# Reset falling
	#body.velocity.y = 0
	prev_forward_velocity = get_forward_comp(body.velocity).length()
	glide_started.emit()
	

func Update(delta):
	var mouse_x = Input.get_last_mouse_velocity().x / 10
	mouse_x = clampf(mouse_x, -max_camera_tilt, max_camera_tilt)
	head.set_tilt(lerp(head.get_tilt(), -mouse_x, delta * camera_tilt_speed))
	
	var fov = lerp(min_camera_fov, max_camera_fov, prev_forward_velocity / max_fov_at_velocity)
	head.set_fov(lerp(head.get_fov(), fov, delta * camera_fov_speed))

func PhysicsUpdate(body, delta):
	
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
#	direction = (main_camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var velocity = body.velocity
	
	# Apply wind
	if wind_area and wind:
		velocity = lerp(velocity, wind, delta)
	# Apply forward momentum
	else:
		# Lerp with prev velocity in forward direction for momentum retention
		velocity = lerp(velocity, -main_camera.global_transform.basis.z * prev_forward_velocity, delta * 40)
		# Save forward velocity
		prev_forward_velocity = get_forward_comp(velocity).length()
	
	# Apply gravity
	velocity.y -= gravity * delta
	
	# Jump to gain height
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_force
	
#	# If we are moving in air, we want snappy acceleration
#	if input_dir:
#		velocity.x = lerp(velocity.x, direction.x * speed, delta * air_move_acceleration)
#		velocity.z = lerp(velocity.z, direction.z * speed, delta * air_move_acceleration)
#	else:
#		velocity.x = lerp(velocity.x, direction.x * speed, delta * air_acceleration)
#		velocity.z = lerp(velocity.z, direction.z * speed, delta * air_acceleration)
	
	body.velocity = velocity
	body.move_and_slide()
	
	# Collisions
	PerformCollisions(body, speed, push_force, delta)
	
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
		var query = PhysicsRayQueryParameters3D.create(ledge_position, ledge_position + Vector3.UP * 1.9)
		var collision = body.get_world_3d().direct_space_state.intersect_ray(query)
		if not collision:
			Transitioned.emit(self, "vault")
			return
			
	# Back to Air.
	if not Input.is_action_pressed("crouch"):
		Transitioned.emit(self, "air")
		return
	
	# Ground State
	if body.is_on_floor():
		Transitioned.emit(self, "crouch")
		return
		
	# Water State
	if water_check.is_colliding():
		Transitioned.emit(self, "swim")
		return
	
	
	
func Exit(body):
	body.last_direction = body.velocity.normalized()
	head.reset_tilt(0.2)
	head.reset_fov(0.2)
	glide_ended.emit()

func on_area_enter(area):
	if area.wind_force_magnitude > 0:
		wind = area.get_node(area.wind_source_path).global_transform.basis.z * area.wind_force_magnitude
		wind_area = area

func on_area_exit(area):
	if area == wind_area:
		wind = Vector3.ZERO
		wind_area = null

func get_forward_comp(vector):
	# Flatten vector on x,y plane
	var plane = Plane(main_camera.global_transform.basis.z)
	var xy = plane.project(vector)
	# Return what's left, which is z
	return vector - xy
