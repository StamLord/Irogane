extends PlayerState
class_name Swim

# Refs
@onready var head = $"../../head"
@onready var ledge_check = $"../../ledge_check"
@onready var wall_check = $"../../wall_check"
@onready var water_check = $"../../water_check"
@onready var water_level_check = $"../../water_level_check"

@export var speed = 5
@export var acceleration = 10
@export var buoyancy = 20.0
@export var max_vertical_force = 100.0
@export var surface_offset = -1.0
@export var default_water_level = -0.75

var input_dir = Vector2.ZERO
var direction = Vector3.ZERO

signal swim_started()
signal swim_ended()

func Enter(body):
	direction = body.last_direction
	swim_started.emit()

func Update(delta):
	pass
	
func PhysicsUpdate(body, delta):
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	# Use head's transform to move in 3D
	direction = lerp(direction, (head.get_global_transform().basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * acceleration)
	
	# How far from water surface
	var water_level = default_water_level
	if water_level_check.is_colliding():
		water_level = water_level_check.get_collision_point().y
	
	var surface_delta = body.global_position.y - surface_offset - water_level
	
	# Can't swim above surface level
	if surface_delta > 0:
		direction.y = min(0, direction.y)
	
	var velocity = body.velocity
	if direction:
		velocity = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	# Slowly move to surface
	var vertical_force = lerp(buoyancy, 0.0, direction.length()) # Lerp towards 0 the bigger our input is
	var target_velocity_y = -vertical_force * surface_delta # Bigger surface_delta = bigger pull
	target_velocity_y = clamp(target_velocity_y, -max_vertical_force, max_vertical_force)
	velocity.y = lerp(velocity.y, target_velocity_y, delta)
	
	body.velocity = velocity
	body.move_and_slide()
	
	# Vault State
	if input_dir.y < 0 and ledge_check.is_colliding():
		# Verify we have enough head room
		var ledge_position = ledge_check.get_collision_point()
		var query = PhysicsRayQueryParameters3D.create(ledge_position, ledge_position + Vector3.UP * 0.9)
		var collision = body.get_world_3d().direct_space_state.intersect_ray(query)
		
		if not collision:
			Transitioned.emit(self, "vault")
			return
			
	# Air State
	if not water_check.is_colliding():
		Transitioned.emit(self, "air")
		return
	
func Exit(body):
	body.last_direction = direction
	swim_ended.emit()
