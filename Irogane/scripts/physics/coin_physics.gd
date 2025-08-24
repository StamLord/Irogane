extends Node3D

@onready var visual = $visual

const GRAVITY = -9.8
const CLIP_OFFSET = 0.01

var velocity = Vector3.ZERO
var max_bounces = 3
var bounces = 0
var bounce_damp = 0.5
var killed_momentum = false
var sleeping = false

signal on_collision(collision)

func start_force(force: Vector3):
	velocity = force
	bounces = 0
	killed_momentum = false
	

func _process(delta):
	if sleeping:
		return
	
	var old_position = global_position
	var new_position = global_position + velocity * delta
	velocity.y += GRAVITY * delta
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, new_position)
	var collision = space_state.intersect_ray(query)
	
	if collision:
		handle_collision(collision)
	else:
		global_position = new_position
	
	if not killed_momentum:
		spin(old_position, delta)
	

func handle_collision(collision):
	# Move to collision point to avoid clipping
	global_position = collision.position + collision.normal * CLIP_OFFSET
	
	# New velocity is bounced off of collision's normal
	if bounces < max_bounces:
		velocity = calculate_bounce_velocity(velocity, collision.normal)
		bounces += 1
	
	# If no more bounces, leave only y component for falling
	# Makes the coin fall if the last collision was against a wall
	elif not killed_momentum:
		velocity = Vector3(0, velocity.y, 0)
		killed_momentum = true
		rotate_to_rest()
	# If colliding after momentum is killed (final resting position)
	# go to sleep and stop processing further collisions and trying to move
	elif killed_momentum:
		sleeping = true
	
	on_collision.emit(collision)
	

func calculate_bounce_velocity(velocity: Vector3, normal: Vector3):
	return velocity.bounce(normal) * bounce_damp
	

func spin(old_position, delta):
	var actual_speed = (global_position - old_position).length()
	visual.rotation_degrees.x += actual_speed * 50000 * delta
	

func rotate_to_rest():
	var old_scale = visual.scale # For some reason scale resets when rotation changes
	visual.global_rotation_degrees.x = 0
	visual.scale = old_scale
