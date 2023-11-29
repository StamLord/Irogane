extends CharacterBody3D

@onready var step_check = $step_check

@export var speed = 2
@export var acceleration = 10
@export var rotation_speed = 30
@export var gravity = 9
@export var push_force = 15

@onready var nav = $NavigationAgent3D
@onready var nav_agent = $NavigationAgent3D
@onready var player = $"../player"

@export var max_step_height = .3
@export var max_step_angle = 10
@export var step_check_distance = 0.55

var prev_current_angle : float
var prev_target_angle : float

var next_position
var direction

func _process(delta):
	rotate_to_target(delta)

func _physics_process(delta):
	nav.target_position = player.position
	
	next_position = nav.get_next_path_position()
	direction = (next_position - global_position).normalized()
	
	nav_agent.set_velocity(direction * speed)
	
	# Apply gravity
	velocity.y -= gravity * delta
	
	move_and_slide()
	
	# The next position in local space is the direction we travel in
	var local_next_pos = to_local(next_position)
	# We use it to test if we are walking on steps
	is_step(self, Vector3(local_next_pos.x, 0, local_next_pos.z).normalized())
	
	# Collisions
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			collider.apply_central_impulse(-collision.get_normal() * push_force * delta)
			collider.apply_impulse(-collision.get_normal() * 0.01, collision.get_position())
		elif collider is CharacterBody3D:
				collider.velocity += -collision.get_normal() * push_force * delta

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	var flat_vector = velocity.move_toward(safe_velocity, .25)
	velocity.x = flat_vector.x
	velocity.z = flat_vector.z
	
func rotate_to_next_position(delta):
	rotate_to_position(next_position, delta)
	
func rotate_to_target(delta):
	rotate_to_position(nav.target_position, delta)
	
func rotate_to_position(target_position, delta):
	var forward = basis * Vector3.FORWARD
	var flat_target = Vector3(target_position.x, position.y, target_position.z)
	var new_forward = lerp(position + forward, flat_target, delta * rotation_speed)
	look_at(new_forward)

func rotate_angle(delta):
	var current_angle = rad_to_deg(basis.z.signed_angle_to(-Vector3.FORWARD, Vector3.UP))
	var target_angle = rad_to_deg(direction.signed_angle_to(Vector3.FORWARD, Vector3.UP))
	
	# Fix signed angle flipping from 360 to -360
	if abs(current_angle - prev_current_angle) > 180.0:
		if current_angle > 0.0:
			current_angle -= 360.0
		else:
			current_angle += 360.0
			
	if abs(target_angle - prev_target_angle) > 180.0:
		if target_angle > 0.0:
			target_angle -= 360.0
		else:
			target_angle += 360.0
	
	prev_current_angle = current_angle
	prev_target_angle = target_angle
	
	# Calculate new angle
	var angle = lerp(current_angle, target_angle, delta * rotation_speed)
	
	# Set rotation
	rotation_degrees.y = -angle
	
	#print("Target Angle: " + str(target_angle))
	#print("Angle: " + str(angle))
	#print("Dir: " + str(direction))

func is_step(body, input_dir):
	
	# Move raycast position according to direction
	step_check.position.x = input_dir.x * step_check_distance
	step_check.position.z = input_dir.z * step_check_distance

	if not step_check.is_colliding():
		return false
	
	# Surface must be flat enough to be considered a step
	var angle = rad_to_deg(step_check.get_collision_normal().angle_to(Vector3.UP))
	if angle > max_step_angle:
		return false
	
	var step_pos = step_check.get_collision_point()
	var height_diff = step_pos.y - body.global_position.y
	
	# Verify we can stand on the step
	#var shape_cast = ShapeCast3D.new()
	#shape_cast.collide_with_areas = true
	#shape_cast.collide_with_bodies = true
	#shape_cast.shape = stand_collider.shape
	#shape_cast.target_position = step_pos
	
	#if shape_cast.get_collision_count() > 0:
	#	return false
	
	# Not a step if we are same height
	if height_diff == 0:
		return false
	elif height_diff < -max_step_height:
		return false
	elif height_diff > max_step_height:
		return false
	
	# If we are moving, change height
	if input_dir.length() > 0.1:
		body.global_position.y += height_diff - 0.01
		
	return true